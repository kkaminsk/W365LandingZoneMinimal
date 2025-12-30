# Change: Enable VNet Peering by Default

## Why

Currently, VNet peering to the hub requires manually providing the `hubVnetId` parameter. This proposal enables automatic hub discovery and peering by default, reducing deployment complexity and ensuring spokes are connected to centralized services automatically.

## What Changes

- Add hub VNet auto-discovery logic to deployment scripts
- Enable peering by default when hub VNet is detected in the subscription
- Add parameter to explicitly disable peering if not wanted
- Update documentation to clarify the auto-peering behavior
- Add validation to verify hub exists before attempting peering

## Impact

- Affected specs: spoke-network
- Affected code:
  - `2_Spoke/deploy.ps1` - add hub discovery logic
  - `2_Spoke/infra/envs/prod/main.bicep` - update peering defaults
  - `2_Spoke/infra/modules/spoke-network/main.bicep` - no changes to module itself
  - Documentation files
- **BREAKING**: Default behavior changes from "no peering" to "auto-peer if hub exists"
