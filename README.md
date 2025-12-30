# Windows 365 Landing Zone - Hub & Spoke Network Deployment

This repository provides Infrastructure-as-Code (IaC) solutions for deploying a hub-and-spoke network architecture designed for **Windows 365** Cloud PC deployments with a basic **Azure Landing Zone** foundation.

## Overview

The repository contains two complementary solutions that work together to create a complete networking infrastructure:

1. **Hub Network (`1_Hub/`)** - Central connectivity and shared services
2. **Spoke Network (`2_Spoke/`)** - Windows 365 Cloud PC workload networks

These solutions use **Azure Bicep** templates and **PowerShell** deployment scripts to automate the provisioning of enterprise-ready networks for Windows 365.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Hub VNet (10.10.0.0/20)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Management   │  │   Private    │  │  Azure Firewall      │  │
│  │   Subnet     │  │  Endpoints   │  │  (Optional)          │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│                                                                 │
│  Shared Services: Firewall, Private DNS, Log Analytics          │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ VNet Peering (Auto-Enabled)
             │
┌────────────┴────────────────────────────────────────────────────┐
│           Consolidated Spoke VNet (192.168.0.0/16)              │
│                     vnet-w365-spokes-prod                       │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │    Spoke 1      │  │    Spoke 2      │  │    Spoke N      │ │
│  │ 192.168.1.0/24  │  │ 192.168.2.0/24  │  │ 192.168.N.0/24  │ │
│  │                 │  │                 │  │                 │ │
│  │ - cloudpc /26   │  │ - cloudpc /26   │  │ - cloudpc /26   │ │
│  │ - mgmt    /26   │  │ - mgmt    /26   │  │ - mgmt    /26   │ │
│  │ - avd     /26   │  │ - avd     /26   │  │ - avd     /26   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                                 │
│  Single Resource Group: rg-w365-spokes-prod                     │
└─────────────────────────────────────────────────────────────────┘

Supports up to 40 spokes within consolidated VNet
```

## Repository Structure

```
W365LandingZone/
├── 1_Hub/                          # Hub network solution
│   ├── deploy.ps1                  # Hub deployment script
│   ├── verify.ps1                  # Post-deployment verification
│   ├── QUICKSTART.md               # Quick start guide
│   ├── README.md                   # Detailed hub documentation
│   ├── Deployps1-Readme.md         # Deployment script documentation
│   ├── ExecutionFlow.md            # Script execution flow details
│   ├── ImplementationPlan.md       # Implementation planning docs
│   ├── infra/                      # Bicep templates
│   │   ├── modules/                # Reusable Bicep modules
│   │   │   ├── budget/             # Azure budget module
│   │   │   ├── diagnostics/        # Diagnostic settings modules
│   │   │   ├── hub-network/        # Hub VNet and subnets
│   │   │   ├── log-analytics/      # Log Analytics workspace
│   │   │   ├── policy/             # Azure Policy assignments
│   │   │   ├── private-dns/        # Private DNS zones
│   │   │   ├── rbac/               # RBAC assignments
│   │   │   └── rg/                 # Resource group module
│   │   └── envs/prod/              # Production environment config
│   └── scripts/entra/              # Entra ID helper scripts
│       ├── 1-Setup-RbacGroups.ps1  # RBAC group creation
│       └── 2-Setup-LabUsers.ps1    # Lab user provisioning
│
├── 2_Spoke/                        # Windows 365 spoke solution
│   ├── deploy.ps1                  # Spoke deployment script
│   ├── QUICKSTART.md               # Quick start guide
│   ├── README.md                   # Detailed spoke documentation
│   ├── Deployps1-Readme.md         # Deployment script documentation
│   ├── ExecutionFlow.md            # Script execution flow details
│   ├── Setup-MinimumPermissions.ps1 # Security configuration script
│   ├── Set-W365Permissions.ps1     # Windows 365 permission setup
│   ├── Check-W365Permissions.ps1   # Permission verification script
│   ├── W365-MinimumRole.json       # Custom RBAC role definition
│   ├── ARCHITECTURE-DIAGRAM.md     # Network topology diagrams
│   ├── IP-ADDRESSING.md            # Multi-spoke IP allocation
│   ├── HUB-VS-SPOKE.md             # Comparison and integration guide
│   ├── PERMISSIONS-AND-RESTRICTIONS.md # Security configuration
│   ├── DEPLOYMENT-SUMMARY.md       # Deployment overview
│   ├── INDEX.md                    # Documentation index
│   ├── infra/                      # Bicep templates
│   │   ├── modules/                # Reusable Bicep modules
│   │   │   ├── rg/                 # Resource group module
│   │   │   ├── spoke-network/      # Spoke VNet and subnets
│   │   │   └── w365-permissions/   # W365 permission assignments
│   │   └── envs/prod/              # Production environment config
│   └── Readme-W365Permissions.md   # W365 permissions documentation
│
├── Graphics/                       # Documentation diagrams
│   ├── Hub.png                     # Hub architecture diagram
│   ├── Overview.png                # Solution overview diagram
│   └── SpokeIPAndSubnet.png        # Spoke IP addressing diagram
│
├── openspec/                       # Spec-driven development framework
│   ├── changes/                    # Proposed changes
│   └── specs/                      # Current specifications
│
├── CLAUDE.md                       # Claude Code project guide
├── AGENTS.md                       # AI agent configuration
├── LICENSE                         # License file
└── README.md                       # This file
```

## Quick Start

### Option 1: Deploy Complete Hub-Spoke Solution

**Step 1: Deploy Hub Network**
```powershell
cd 1_Hub
.\deploy.ps1
```

**Step 2: Deploy Windows 365 Spoke Network**
```powershell
cd ..\2_Spoke
.\deploy.ps1 -SpokeNumber 1
```

The spoke deployment automatically discovers the hub VNet and configures peering.

### Option 2: Deploy Spoke Only (Standalone)

If you already have existing network infrastructure or want a standalone Windows 365 network:

```powershell
cd 2_Spoke
.\deploy.ps1 -SpokeNumber 1 -DisablePeering
```

## Solution 1: Hub Network (`1_Hub/`)

### Purpose
Provides centralized connectivity, security, and shared services for a hub-and-spoke network topology following Azure Landing Zone design principles.

### What Gets Deployed

#### Resource Groups
- `rg-hub-net` - Network resources
- `rg-hub-ops` - Operations and monitoring resources

#### Networking (10.10.0.0/20)
- **Virtual Network** with subnets:
  - Management Subnet: 10.10.0.0/24
  - Private Endpoints Subnet: 10.10.1.0/24
  - Azure Firewall Subnet: 10.10.2.0/26 (optional)
  - Gateway Subnet: 10.10.3.0/27 (optional)
- **Network Security Groups** (2)
- **Azure Firewall** (Basic tier) - optional
- **Public IP** for Firewall

#### Shared Services
- **Private DNS Zones**:
  - privatelink.azurewebsites.net
  - privatelink.blob.core.windows.net
  - Virtual Network Links
- **Log Analytics Workspace** for centralized monitoring
- **Diagnostic Settings** for subscription activity logs

#### Governance
- **Azure Policy** assignment (Allowed Locations)
- **Azure Budget** ($200/month with alerts) - optional
- **RBAC Assignments** (if group IDs provided)

### Deployment

```powershell
# Navigate to hub folder
cd 1_Hub

# Validate Bicep templates
.\deploy.ps1 -Validate

# Preview changes (what-if)
.\deploy.ps1 -WhatIf

# Deploy hub network
.\deploy.ps1

# Verify deployment
.\verify.ps1
```

### Configuration

Edit `1_Hub/infra/envs/prod/parameters.prod.json`:
```json
{
  "location": "canada-central",
  "env": "prod",
  "allowedLocations": ["canadacentral", "canadaeast"],
  "networkAdminsGroupObjectId": "<your-aad-group-id>",
  "opsGroupObjectId": "<your-aad-group-id>"
}
```

### Documentation
- **[QUICKSTART.md](1_Hub/QUICKSTART.md)** - Quick deployment guide
- **[README.md](1_Hub/README.md)** - Comprehensive hub documentation
- **[Deployps1-Readme.md](1_Hub/Deployps1-Readme.md)** - Detailed deployment documentation
- **[ExecutionFlow.md](1_Hub/ExecutionFlow.md)** - Script execution flow details
- **[verifyps1-readme.md](1_Hub/verifyps1-readme.md)** - Verification script documentation

**Estimated Deployment Time:** 5-10 minutes

## Solution 2: Windows 365 Spoke Network (`2_Spoke/`)

### Purpose
Provides dedicated network infrastructure for Windows 365 Cloud PC deployments with multi-spoke support (up to 40 spokes) using a consolidated VNet architecture.

### What Gets Deployed

#### Resource Group
- `rg-w365-spokes-prod` - Single consolidated resource group for all spokes

#### Networking (192.168.0.0/16 Consolidated VNet)
- **Consolidated Virtual Network** (`vnet-w365-spokes-prod`) shared by all spokes
- **Per-spoke subnets** with automatic IP addressing based on spoke number:
  - **Cloud PC Subnet**: `snet-spoke{N}-cloudpc` - 192.168.{N}.0/26 (62 usable IPs)
  - **Management Subnet**: `snet-spoke{N}-mgmt` - 192.168.{N}.64/26 (62 usable IPs)
  - **AVD Subnet**: `snet-spoke{N}-avd` - 192.168.{N}.128/26 (optional)
  - **Reserved**: 192.168.{N}.192/26 (future expansion)

#### Security
- **Network Security Groups** (per spoke) pre-configured for Windows 365:
  - Cloud PC NSG (RDP allowed from VNet, HTTPS outbound)
  - Management NSG
  - AVD NSG (if enabled)
- **Service Endpoints**: Storage and KeyVault

#### Hub Integration (Auto-Enabled)
- **Automatic Hub Discovery**: Finds VNets matching `vnet-hub*` pattern
- **VNet Peering**: Automatically configured when hub is discovered

### Deployment

```powershell
# Navigate to spoke folder
cd 2_Spoke

# Deploy for Spoke 1 (uses 192.168.1.0/24 subnet range)
.\deploy.ps1 -SpokeNumber 1

# Deploy for Spoke 5 (uses 192.168.5.0/24 subnet range)
.\deploy.ps1 -SpokeNumber 5

# Validate before deploying
.\deploy.ps1 -Validate -SpokeNumber 10

# Deploy without hub peering
.\deploy.ps1 -SpokeNumber 1 -DisablePeering

# Specify hub VNet manually (overrides auto-discovery)
.\deploy.ps1 -SpokeNumber 1 -HubVnetId "/subscriptions/{sub-id}/resourceGroups/rg-hub-net/providers/Microsoft.Network/virtualNetworks/vnet-hub"
```

### IP Address Allocation

All spokes share a single consolidated VNet (`192.168.0.0/16`). Each spoke receives dedicated subnets within its `/24` range:

| Spoke | Subnet Range | Cloud PC Subnet | Management Subnet | AVD Subnet |
|-------|--------------|-----------------|-------------------|------------|
| Spoke 1 | 192.168.1.0/24 | 192.168.1.0/26 | 192.168.1.64/26 | 192.168.1.128/26 |
| Spoke 5 | 192.168.5.0/24 | 192.168.5.0/26 | 192.168.5.64/26 | 192.168.5.128/26 |
| Spoke N | 192.168.{N}.0/24 | 192.168.{N}.0/26 | 192.168.{N}.64/26 | 192.168.{N}.128/26 |

### Configuration

Edit `2_Spoke/infra/envs/prod/parameters.prod.json`:
```json
{
  "location": { "value": "southcentralus" },
  "spokeNumber": { "value": 1 },
  "enableAvdSubnet": { "value": false },
  "hubVnetId": { "value": "" }
}
```

### Hub Peering Options

| Option | Command | Behavior |
|--------|---------|----------|
| Auto-discovery (default) | `.\deploy.ps1 -SpokeNumber 1` | Finds `vnet-hub*` and peers automatically |
| Disable peering | `.\deploy.ps1 -SpokeNumber 1 -DisablePeering` | No hub peering |
| Manual hub ID | `.\deploy.ps1 -SpokeNumber 1 -HubVnetId "..."` | Uses specified hub VNet |

### Security & Permissions

For enterprise deployments with minimum privilege requirements, use the provided security setup scripts in the `2_Spoke/` directory.

### Documentation
- **[QUICKSTART.md](2_Spoke/QUICKSTART.md)** - Quick deployment guide
- **[README.md](2_Spoke/README.md)** - Comprehensive spoke documentation
- **[Deployps1-Readme.md](2_Spoke/Deployps1-Readme.md)** - Deployment script documentation
- **[ExecutionFlow.md](2_Spoke/ExecutionFlow.md)** - Script execution flow details
- **[IP-ADDRESSING.md](2_Spoke/IP-ADDRESSING.md)** - Multi-spoke IP allocation details
- **[ARCHITECTURE-DIAGRAM.md](2_Spoke/ARCHITECTURE-DIAGRAM.md)** - Network topology diagrams
- **[HUB-VS-SPOKE.md](2_Spoke/HUB-VS-SPOKE.md)** - Comparison and integration guide
- **[PERMISSIONS-AND-RESTRICTIONS.md](2_Spoke/PERMISSIONS-AND-RESTRICTIONS.md)** - Security configuration
- **[Readme-W365Permissions.md](2_Spoke/Readme-W365Permissions.md)** - Windows 365 permissions guide
- **[DEPLOYMENT-SUMMARY.md](2_Spoke/DEPLOYMENT-SUMMARY.md)** - Deployment overview
- **[INDEX.md](2_Spoke/INDEX.md)** - Documentation index

**Estimated Deployment Time:** 3-5 minutes per spoke

## Connecting Hub and Spoke

### Automatic Peering (Recommended)

When you deploy spokes after the hub, peering is configured automatically:

```powershell
# Step 1: Deploy Hub
cd 1_Hub
./deploy.ps1

# Step 2: Deploy Spoke (auto-discovers hub and peers)
cd ../2_Spoke
./deploy.ps1 -SpokeNumber 1
```

The deployment script:
1. Searches for VNets matching `vnet-hub*` pattern
2. Automatically configures bidirectional VNet peering
3. Displays peering status in deployment output

### Manual Hub Specification

If auto-discovery doesn't find your hub or you have multiple hubs:

```powershell
.\deploy.ps1 -SpokeNumber 1 -HubVnetId "/subscriptions/{sub-id}/resourceGroups/rg-hub-net/providers/Microsoft.Network/virtualNetworks/vnet-hub"
```

### Standalone Deployment (No Peering)

For isolated spoke networks without hub connectivity:

```powershell
.\deploy.ps1 -SpokeNumber 1 -DisablePeering
```

## Prerequisites

### Required Software
- **Azure PowerShell** (Az module)
- **Bicep CLI** - `winget install -e --id Microsoft.Bicep`
- **PowerShell 5.1+** or **PowerShell 7+**

### Azure Requirements
- **Azure Subscription** with appropriate permissions
- **Permissions** (Hub): Owner or Contributor at subscription level
- **Permissions** (Spoke): Contributor or Network Contributor at subscription level

### Quick Setup
```powershell
# Install Bicep CLI
winget install -e --id Microsoft.Bicep

# Verify installation
bicep --version

# Login to Azure
Connect-AzAccount

# Verify subscription
Get-AzContext
```

## Use Cases

### Scenario 1: Enterprise Hub-Spoke with Windows 365
Deploy centralized hub infrastructure with multiple Windows 365 spoke subnets for different teams or environments.

### Scenario 2: Standalone Windows 365 Network
Quick Windows 365 deployment without hub infrastructure using `-DisablePeering`.

### Scenario 3: Multi-Tenant/Lab Environment
Support multiple isolated environments (up to 40 spokes) with automated IP addressing within a single consolidated VNet.

## Security Features

### Hub Network
- Azure Firewall for centralized traffic inspection (optional)
- Private DNS zones for Azure services
- Centralized Log Analytics workspace
- Azure Policy enforcement
- RBAC assignments for governance

### Spoke Networks
- Pre-configured NSG rules for Windows 365
- RDP restricted to VirtualNetwork scope
- HTTPS outbound for Windows 365 service connectivity
- Service endpoints for Storage and KeyVault
- Subnet segmentation (Cloud PCs, Management, AVD)
- Optional custom RBAC roles with minimum privileges

## Best Practices

1. **Deploy Hub First** - Always deploy the hub network before spoke networks for automatic peering
2. **Use Validation** - Run `.\deploy.ps1 -Validate` before actual deployment
3. **Document Spoke Assignments** - Maintain a record of which spoke numbers are assigned to which teams/environments
4. **Version Control** - Store all configuration files in Git
5. **Test in Dev** - Deploy to dev/test environments first

## Next Steps

1. Review architecture and IP addressing scheme
2. Deploy hub network (if using hub-spoke topology)
3. Deploy spoke network(s) for Windows 365
4. Verify automatic hub peering in deployment output
5. Set up Windows 365 provisioning policies
6. Deploy Cloud PCs to spoke subnet

## Additional Resources

- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Windows 365 Documentation](https://learn.microsoft.com/en-us/windows-365/)
- [Hub-Spoke Network Topology](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Azure Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)

## License

See [LICENSE](LICENSE) file for details.

---

**Ready to deploy?** Start with the [Hub QUICKSTART](1_Hub/QUICKSTART.md) or [Spoke QUICKSTART](2_Spoke/QUICKSTART.md)!
