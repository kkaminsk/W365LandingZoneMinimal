targetScope = 'subscription'

@description('Primary Azure region for deployment')
param location string = 'southcentralus'

@description('Environment name (prod, dev, test)')
param env string = 'prod'

@description('Spoke number (1-40) for unique subnet addressing within consolidated VNet')
@minValue(1)
@maxValue(40)
param spokeNumber int = 1

@description('Common tags applied to all resources')
param tags object = {
  env: env
  workload: 'Windows365'
  owner: 'platform-team'
  costCenter: '1000'
}

// Consolidated VNet uses 192.168.0.0/16 address space
// Each spoke gets subnets within: 192.168.{spokeNumber}.0/24
var consolidatedVnetAddressSpace = '192.168.0.0/16'
var thirdOctet = spokeNumber
var cloudPCSubnetPrefix = '192.168.${thirdOctet}.0/26'
var mgmtSubnetPrefix = '192.168.${thirdOctet}.64/26'
var avdSubnetPrefix = '192.168.${thirdOctet}.128/26'

@description('Enable Azure Virtual Desktop subnet')
param enableAvdSubnet bool = false

@description('Hub VNet resource ID for peering (optional)')
param hubVnetId string = ''

@description('Allow forwarded traffic from hub')
param allowForwardedTraffic bool = true

@description('Use remote gateways in hub VNet')
param useRemoteGateways bool = false

@description('Windows 365 Service Principal Object ID (required for permissions)')
param windows365ServicePrincipalId string

// Single consolidated resource group and VNet for all spokes
var rgName = 'rg-w365-spokes-${env}'
var vnetName = 'vnet-w365-spokes-${env}'

// Resource Group (will be created once, reused for subsequent spokes)
module rg '../../modules/rg/main.bicep' = {
  name: 'rg-w365-spokes-${env}'
  scope: subscription()
  params: {
    location: location
    rgName: rgName
    tags: tags
  }
}

// Consolidated Spoke Network - adds subnets for this spoke
module spokeNetwork '../../modules/spoke-network/main.bicep' = {
  name: 'spoke-network-spoke${spokeNumber}'
  scope: resourceGroup(rgName)
  dependsOn: [ rg ]
  params: {
    location: location
    vnetName: vnetName
    vnetAddressSpace: consolidatedVnetAddressSpace
    spokeNumber: spokeNumber
    cloudPCSubnetPrefix: cloudPCSubnetPrefix
    mgmtSubnetPrefix: mgmtSubnetPrefix
    avdSubnetPrefix: avdSubnetPrefix
    enableAvdSubnet: enableAvdSubnet
    hubVnetId: hubVnetId
    allowForwardedTraffic: allowForwardedTraffic
    useRemoteGateways: useRemoteGateways
    tags: tags
  }
}

// Windows 365 Permissions
module w365Permissions '../../modules/w365-permissions/main.bicep' = {
  name: 'w365-permissions-spoke${spokeNumber}'
  scope: resourceGroup(rgName)
  dependsOn: [ spokeNetwork ]
  params: {
    resourceGroupName: rgName
    vnetName: vnetName
    windows365ServicePrincipalId: windows365ServicePrincipalId
  }
}

// Outputs
@description('Resource Group name')
output resourceGroupName string = rg.outputs.resourceGroupName

@description('Virtual Network ID')
output vnetId string = spokeNetwork.outputs.vnetId

@description('Virtual Network name')
output vnetName string = spokeNetwork.outputs.vnetName

@description('Cloud PC subnet ID for spoke')
output cloudPCSubnetId string = spokeNetwork.outputs.cloudPCSubnetId

@description('Management subnet ID for spoke')
output mgmtSubnetId string = spokeNetwork.outputs.mgmtSubnetId

@description('AVD subnet ID for spoke')
output avdSubnetId string = spokeNetwork.outputs.avdSubnetId

@description('Peering status to hub')
output peeringStatus string = spokeNetwork.outputs.peeringStatus

@description('Windows 365 permissions status')
output w365PermissionsStatus string = w365Permissions.outputs.status
