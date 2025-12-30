@description('Azure region for all resources')
param location string

@description('Name of the consolidated spoke virtual network')
param vnetName string = 'vnet-w365-spokes'

@description('Address space for the consolidated VNet (192.168.0.0/16 for all spokes)')
param vnetAddressSpace string = '192.168.0.0/16'

@description('Spoke number (1-40) for unique subnet naming')
@minValue(1)
@maxValue(40)
param spokeNumber int = 1

@description('Address prefix for the Windows 365 Cloud PC subnet')
param cloudPCSubnetPrefix string

@description('Address prefix for the management subnet')
param mgmtSubnetPrefix string

@description('Address prefix for the Azure Virtual Desktop subnet (if needed)')
param avdSubnetPrefix string

@description('Enable Azure Virtual Desktop subnet')
param enableAvdSubnet bool = false

@description('Hub VNet ID for peering (optional - leave empty to skip peering)')
param hubVnetId string = ''

@description('Allow forwarded traffic from hub')
param allowForwardedTraffic bool = true

@description('Use remote gateways in hub')
param useRemoteGateways bool = false

@description('Resource tags to apply to all resources')
param tags object = {}

// Subnet names include spoke number for uniqueness within consolidated VNet
var cloudPCSubnetName = 'snet-spoke${spokeNumber}-cloudpc'
var mgmtSubnetName = 'snet-spoke${spokeNumber}-mgmt'
var avdSubnetName = 'snet-spoke${spokeNumber}-avd'

// NSG for Cloud PC subnet - Windows 365 specific rules
resource nsgCloudPC 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: 'nsg-spoke${spokeNumber}-cloudpc'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-RDP-Inbound'
        properties: {
          description: 'Allow RDP from authorized networks'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-HTTPS-Outbound'
        properties: {
          description: 'Allow HTTPS outbound for Windows 365 service'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'Allow-DNS-Outbound'
        properties: {
          description: 'Allow DNS outbound'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '53'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
    ]
  }
}

// NSG for Management subnet
resource nsgMgmt 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: 'nsg-spoke${spokeNumber}-mgmt'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTPS-Inbound'
        properties: {
          description: 'Allow HTTPS for management'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

// NSG for AVD subnet (if enabled)
resource nsgAvd 'Microsoft.Network/networkSecurityGroups@2024-03-01' = if (enableAvdSubnet) {
  name: 'nsg-spoke${spokeNumber}-avd'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-RDP-Inbound'
        properties: {
          description: 'Allow RDP from authorized networks'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

// Consolidated Spoke Virtual Network
// This VNet is created once with 192.168.0.0/16 address space
// Subsequent spoke deployments add their subnets to this VNet
resource vnet 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: cloudPCSubnetName
        properties: {
          addressPrefix: cloudPCSubnetPrefix
          networkSecurityGroup: {
            id: nsgCloudPC.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
        }
      }
      {
        name: mgmtSubnetName
        properties: {
          addressPrefix: mgmtSubnetPrefix
          networkSecurityGroup: {
            id: nsgMgmt.id
          }
        }
      }
      {
        name: avdSubnetName
        properties: {
          addressPrefix: avdSubnetPrefix
          networkSecurityGroup: enableAvdSubnet ? {
            id: nsgAvd.id
          } : null
        }
      }
    ]
  }
}

// VNet Peering to Hub (if hubVnetId provided)
// Only one peering needed for the consolidated VNet
resource peeringToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-03-01' = if (!empty(hubVnetId)) {
  parent: vnet
  name: 'peer-to-hub'
  properties: {
    remoteVirtualNetwork: {
      id: hubVnetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: false
    useRemoteGateways: useRemoteGateways
  }
}

// Outputs
@description('Virtual Network resource ID')
output vnetId string = vnet.id

@description('Virtual Network name')
output vnetName string = vnet.name

@description('Cloud PC subnet resource ID for this spoke')
output cloudPCSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, cloudPCSubnetName)

@description('Management subnet resource ID for this spoke')
output mgmtSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, mgmtSubnetName)

@description('AVD subnet resource ID for this spoke (if enabled)')
output avdSubnetId string = enableAvdSubnet ? resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, avdSubnetName) : ''

@description('Cloud PC NSG resource ID')
output cloudPCNsgId string = nsgCloudPC.id

@description('Management NSG resource ID')
output mgmtNsgId string = nsgMgmt.id

@description('VNet peering status')
output peeringStatus string = !empty(hubVnetId) ? 'Configured' : 'Not Configured'
