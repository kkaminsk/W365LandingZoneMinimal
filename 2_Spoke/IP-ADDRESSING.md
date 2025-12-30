# IP Addressing Scheme for Multiple Spokes

## Overview

The W365 spoke network deployment uses a **parameterized IP addressing scheme** to support multiple spokes without IP conflicts. Each spoke receives a unique `/24` network based on their spoke number.

## Addressing Pattern

- **Spoke Number Range**: 1-40
- **IP Pattern**: `192.168.X.0/24` where `X` = Spoke Number
- **Hub Network**: `10.10.0.0/20` (shared across all spokes)

## Per-Spoke Allocation

Each spoke gets a `/24` network (256 IP addresses) subdivided into three `/26` subnets (64 IPs each):

| Spoke | VNet Range | Cloud PC Subnet | Management Subnet | AVD Subnet |
|---------|------------|-----------------|-------------------|------------|
| 1 | 192.168.1.0/24 | 192.168.1.0/26 | 192.168.1.64/26 | 192.168.1.128/26 |
| 2 | 192.168.2.0/24 | 192.168.2.0/26 | 192.168.2.64/26 | 192.168.2.128/26 |
| 3 | 192.168.3.0/24 | 192.168.3.0/26 | 192.168.3.64/26 | 192.168.3.128/26 |
| ... | ... | ... | ... | ... |
| 40 | 192.168.40.0/24 | 192.168.40.0/26 | 192.168.40.64/26 | 192.168.40.128/26 |

### Subnet Breakdown

For each spoke's `/24` network:

- **Cloud PC Subnet** (`/26`): 64 IPs
  - Network: `.0`
  - Usable: `.1` - `.62` (62 IPs)
  - Broadcast: `.63`
  - **Purpose**: Windows 365 Cloud PCs

- **Management Subnet** (`/26`): 64 IPs
  - Network: `.64`
  - Usable: `.65` - `.126` (62 IPs)
  - Broadcast: `.127`
  - **Purpose**: Management resources, jump boxes

- **AVD Subnet** (`/26`): 64 IPs
  - Network: `.128`
  - Usable: `.129` - `.190` (62 IPs)
  - Broadcast: `.191`
  - **Purpose**: Azure Virtual Desktop (optional)

- **Reserved** (`/26`): 64 IPs
  - Range: `.192` - `.255`
  - **Purpose**: Future expansion

## Hub Network

The hub network is shared across all spokes and uses a separate address space:

- **VNet**: `10.10.0.0/20` (4,096 IPs)
- **Management Subnet**: `10.10.0.0/24` (256 IPs)
- **Private Endpoints**: `10.10.1.0/24` (256 IPs)
- **Firewall**: `10.10.2.0/26` (64 IPs)

## VNet Peering

Each spoke spoke network can peer with the hub network:

- ✅ **No IP conflicts**: Hub uses `10.10.x.x`, spokes use `192.168.x.x`
- ✅ **No spoke-to-spoke conflicts**: Each spoke has unique third octet
- ✅ **Scalable**: Supports up to 40 spokes without overlap

## Deployment Examples

### Deploy for Spoke 1
```powershell
.\deploy.ps1 -SpokeNumber 1
# Creates: 192.168.1.0/24
```

### Deploy for Spoke 5
```powershell
.\deploy.ps1 -SpokeNumber 5
# Creates: 192.168.5.0/24
```

### Deploy for Spoke 40
```powershell
.\deploy.ps1 -SpokeNumber 40
# Creates: 192.168.40.0/24
```

### Deploy with Tenant/Subscription
```powershell
.\deploy.ps1 -TenantId "xxx-xxx" -SubscriptionId "yyy-yyy" -SpokeNumber 10
# Creates: 192.168.10.0/24
```

## Capacity Planning

### Per Spoke
- **Total IPs**: 256 (one `/24`)
- **Cloud PCs**: Up to 62 per spoke
- **Management VMs**: Up to 62 per spoke
- **AVD Hosts**: Up to 62 per spoke (if enabled)

### Overall Capacity
- **Spokes**: 40 maximum
- **Total VNets**: 40 spoke networks + 1 hub
- **Total IP Space**: 10,240 IPs (40 × 256)
- **No conflicts**: All ranges are non-overlapping

## Configuration Files

### Bicep Template
The IP addresses are calculated dynamically in `infra/envs/prod/main.bicep`:

```bicep
@description('Spoke number (1-40) for unique IP addressing')
@minValue(1)
@maxValue(40)
param spokeNumber int = 1

var thirdOctet = spokeNumber
var vnetAddressSpace = '192.168.${thirdOctet}.0/24'
var cloudPCSubnetPrefix = '192.168.${thirdOctet}.0/26'
var mgmtSubnetPrefix = '192.168.${thirdOctet}.64/26'
var avdSubnetPrefix = '192.168.${thirdOctet}.128/26'
```

### Parameters File
The `parameters.prod.json` file only needs to specify the spoke number:

```json
{
  "parameters": {
    "spokeNumber": {
      "value": 1
    }
  }
}
```

## Validation

Before deploying, validate the template:

```powershell
.\deploy.ps1 -Validate -SpokeNumber 5
```

This will show:
- Spoke Number: 5
- VNet Address Space: 192.168.5.0/24
- Validation results

## Troubleshooting

### IP Conflict Errors
If you see IP conflicts, verify:
1. Each spoke has a unique spoke number (1-40)
2. No manual IP overrides in parameters file
3. No existing VNets with overlapping ranges

### Peering Failures
If VNet peering fails:
1. Verify hub VNet ID is correct
2. Ensure no IP overlap between hub and spoke
3. Check that both VNets are in the same subscription or have proper permissions

## Migration from Fixed IPs

If you have existing deployments with fixed IPs (e.g., `192.168.100.0/24`):

1. **Option 1: Redeploy** - Delete and redeploy with spoke number
2. **Option 2: Keep as-is** - Assign that deployment to a specific spoke number that matches (e.g., spoke 100)

## Best Practices

1. ✅ **Always specify SpokeNumber** when deploying
2. ✅ **Use sequential numbers** (1, 2, 3...) for easier tracking
3. ✅ **Document assignments** - Keep a list of which spoke has which number
4. ✅ **Validate before deploy** - Use `-Validate` flag to check configuration
5. ✅ **Test peering** - Verify hub-spoke connectivity after deployment

## Related Documentation

- [W365 Deployment Guide](README.md)
- [Hub Network Architecture](../1_Hub/README.md)
- [Spoke Deployment Process](./README.md)
