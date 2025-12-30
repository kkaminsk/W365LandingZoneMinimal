# Windows 365 Spoke Network Infrastructure

This folder contains Bicep infrastructure-as-code for deploying a Windows 365 spoke network to Azure.

## 🚀 Quick Start

```powershell
# Navigate to W365 folder
cd W365

# Deploy for spoke 1 (uses 192.168.1.0/24)
.\deploy.ps1 -SpokeNumber 1

# Deploy for spoke 5 (uses 192.168.5.0/24)
.\deploy.ps1 -SpokeNumber 5

# Validate template before deployment
.\deploy.ps1 -Validate -SpokeNumber 10

# Deploy to a specific subscription (e.g. Hub and Spoke in different subscriptions)
.\deploy.ps1 -SubscriptionId "<spoke-subscription-guid>" -SpokeNumber 1

# Deploy to a specific tenant and subscription (multi-tenant admins)
.\deploy.ps1 -TenantId "<tenant-guid>" -SubscriptionId "<subscription-guid>" -SpokeNumber 1
```

## 🌐 Subscription Flexibility

This solution supports deploying the **Spoke** network to:
1.  **The same subscription** as the Hub (simplest for testing)
2.  **A separate subscription** from the Hub (enterprise standard)

The deployment script `deploy.ps1` automatically handles the context switching if you provide the `-SubscriptionId` parameter. The optional VNet peering to the Hub works across subscriptions as long as your account has permissions on both VNets.

> **⚠️ Important**: Always specify `-SpokeNumber` (1-40) to ensure unique IP addressing for each spoke. See [IP-ADDRESSING.md](./IP-ADDRESSING.md) for details.

## 📦 What's Included

- **Resource Group**: `rg-w365-spokes-prod` (single consolidated RG for all spokes)
- **Consolidated Virtual Network**: `vnet-w365-spokes-prod` with `192.168.0.0/16` address space
- **Per-Spoke Subnets** (where {N} = spoke number 1-40):
  - `snet-spoke{N}-cloudpc`: `192.168.{N}.0/26` (62 usable IPs)
  - `snet-spoke{N}-mgmt`: `192.168.{N}.64/26` (62 usable IPs)
  - `snet-spoke{N}-avd`: `192.168.{N}.128/26` (optional, disabled by default)
- **Network Security Groups**: Per-spoke NSGs pre-configured for Windows 365
- **Service Endpoints**: Storage and KeyVault on Cloud PC subnets
- **Hub Peering**: Single peering from consolidated VNet to hub

## 📋 Prerequisites

### Required Permissions

You need **ONE** of these:
- ✅ **Contributor** role at subscription level
- ✅ **Network Contributor** role + resource group write permission
- ✅ **Custom role** (see PERMISSIONS-AND-RESTRICTIONS.md for least-privilege setup)

**📖 For detailed permission requirements and security setup:**
- See **[PERMISSIONS-AND-RESTRICTIONS.md](./PERMISSIONS-AND-RESTRICTIONS.md)** for minimum permissions, restrictions, and automated setup
- Use **[Setup-MinimumPermissions.ps1](./Setup-MinimumPermissions.ps1)** to automate security configuration

### Required Software

- Azure PowerShell (Az module)
- Microsoft Graph PowerShell modules
- Bicep CLI

```powershell
# RECOMMENDED: Install all required modules at once
cd ..
cd InstallStudentModules
.\InstallStudentModules.ps1

# Install Bicep CLI
winget install -e --id Microsoft.Bicep

# Verify Bicep installation
bicep --version
```

## 📖 Documentation

- **[IP-ADDRESSING.md](./IP-ADDRESSING.md)** - **Multi-spoke IP addressing scheme (IMPORTANT)**
- **[Deployps1-Readme.md](./Deployps1-Readme.md)** - Complete deployment guide with troubleshooting
- **[deploy.ps1](./deploy.ps1)** - PowerShell deployment script

## 🎯 IP Address Allocation (Per Spoke)

All spokes share a single consolidated VNet (`192.168.0.0/16`). Each spoke receives dedicated subnets:

**Pattern**: `snet-spoke{X}-{purpose}` with IP range `192.168.X.0/24` where `X` = Spoke Number (1-40)

**Example for Spoke 5**:

| Subnet | Range | CIDR | Usable IPs | Purpose |
|--------|-------|------|------------|---------|
| Cloud PC | 192.168.5.0 - 192.168.5.63 | /26 | 62 | Windows 365 Cloud PCs |
| Management | 192.168.5.64 - 192.168.5.127 | /26 | 62 | Management resources |
| AVD | 192.168.5.128 - 192.168.5.191 | /26 | 62 | Azure Virtual Desktop (optional) |
| Reserved | 192.168.5.192 - 192.168.5.255 | - | 64 | Future expansion |

> **📘 See [IP-ADDRESSING.md](./IP-ADDRESSING.md)** for complete details on multi-spoke deployments, capacity planning, and troubleshooting.

## ⚙️ Configuration

Edit `infra/envs/prod/parameters.prod.json` to customize:

```json
{
  "location": { "value": "southcentralus" },
  "spokeNumber": { "value": 1 },
  "enableAvdSubnet": { "value": false },
  "hubVnetId": { "value": "" }
}
```

> **Note**: IP addresses are calculated automatically based on `spokeNumber`. You no longer need to specify `vnetAddressSpace`, `cloudPCSubnetPrefix`, etc.

## 🔗 Hub Peering (Auto-Enabled by Default)

The deployment script automatically discovers hub VNets and enables peering:

**Default Behavior:**
- Searches for VNets matching pattern `vnet-hub*` in the subscription
- Automatically configures peering if a hub VNet is found
- Displays peering status during deployment

**Control Peering:**
```powershell
# Auto-peering (default) - discovers and peers with hub
.\deploy.ps1 -SpokeNumber 1

# Disable auto-peering explicitly
.\deploy.ps1 -SpokeNumber 1 -DisablePeering

# Manually specify hub VNet ID (overrides auto-discovery)
.\deploy.ps1 -SpokeNumber 1 -HubVnetId "/subscriptions/{sub-id}/resourceGroups/rg-hub-net/providers/Microsoft.Network/virtualNetworks/vnet-hub"
```

⚠️ **Note**: You must also create the reverse peering from hub to spoke.

## 🔐 Security Features

- **NSG Rules**: Pre-configured for Windows 365 traffic
- **Service Endpoints**: Storage and KeyVault enabled
- **Subnet Segmentation**: Isolated Cloud PC, management, and AVD subnets
- **RDP Controls**: Limited to VirtualNetwork scope

## 📁 Folder Structure

```
W365/
├── deploy.ps1                    # Deployment script
├── Deployps1-Readme.md           # Full documentation
├── README.md                     # This file
└── infra/
    ├── modules/
    │   ├── rg/                   # Resource group module
    │   └── spoke-network/        # VNet and subnets module
    └── envs/
        └── prod/
            ├── main.bicep        # Main template
            └── parameters.prod.json  # Configuration
```

## 🎓 Next Steps

1. **Deploy the spoke network**: `.\deploy.ps1`
2. **Configure Windows 365**:
   - Set up Azure AD join
   - Create provisioning policy
   - Deploy Cloud PCs to `snet-cloudpc` subnet
3. **Optional: Connect to hub**:
   - Update `hubVnetId` parameter
   - Create reverse peering from hub

## 💡 Tips

- Always run `-Validate` before deploying
- Use `-WhatIf` to preview changes
- Customize NSG rules for your security requirements
- Document your IP address assignments

## 🔐 Security & Minimum Permissions

For enterprise deployments with strict security requirements:

### Automated Security Setup

```powershell
# Run as subscription owner/admin
.\Setup-MinimumPermissions.ps1 `
    -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -AdminEmail "networkadmin@contoso.com" `
    -UseCustomRole `
    -MonthlyBudget 50 `
    -CreateResourceGroup
```

This configures:
- ✅ Least-privilege RBAC role (custom or Network Contributor)
- ✅ Azure Policies (region, IP range, tagging restrictions)
- ✅ Budget alerts ($50/month default)
- ✅ Resource locks (prevent accidental deletion)
- ✅ Scoped permissions (single resource group only)

### Windows 365 Service Permissions

After deploying the network, configure Windows 365 service:

```powershell
# Assign required permissions for Windows 365
.\Set-W365Permissions.ps1

# Verify permissions are correct
.\Check-W365Permissions.ps1
```

### Documentation

- **[PERMISSIONS-AND-RESTRICTIONS.md](./PERMISSIONS-AND-RESTRICTIONS.md)** - Complete security guide
- **[W365-MinimumRole.json](./W365-MinimumRole.json)** - Custom RBAC role definition
- **[Setup-MinimumPermissions.ps1](./Setup-MinimumPermissions.ps1)** - Automated setup script

---

## 📞 Need Help?

See the **[Deployps1-Readme.md](./Deployps1-Readme.md)** for:
- Detailed troubleshooting guide
- Permission requirements
- Common deployment errors
- Configuration examples

---

**Ready to deploy?** Start with `.\deploy.ps1 -Validate` 🚀
