# Change: Consolidate Spokes into Single VNet

## Why

Currently, each spoke creates its own isolated /24 VNet. This proposal consolidates all spoke subnets into a single large VNet (192.168.0.0/16), simplifying network management, reducing resource count, and enabling easier cross-spoke communication when needed.

## What Changes

- Replace per-spoke VNet creation with a single consolidated VNet
- Change deployment model from "create VNet per spoke" to "create subnets within shared VNet"
- Update IP addressing scheme to use spoke number for subnet allocation within the consolidated VNet
- Modify resource group strategy (single RG for all spokes vs per-spoke RG)
- Update NSG scoping to subnet level instead of VNet level
- Simplify VNet peering (one peering to hub instead of multiple)
- Update all documentation to reflect consolidated architecture

## Impact

- Affected specs: spoke-network
- Affected code:
  - `2_Spoke/infra/envs/prod/main.bicep` - complete restructure
  - `2_Spoke/infra/modules/spoke-network/main.bicep` - convert to subnet-based
  - `2_Spoke/deploy.ps1` - update deployment logic
  - `2_Spoke/infra/modules/w365-permissions/main.bicep` - adjust scope
  - All documentation files
- **BREAKING**: Major architectural change requiring infrastructure redeployment
