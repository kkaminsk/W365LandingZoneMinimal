## ADDED Requirements

### Requirement: Automatic Hub VNet Discovery

The spoke deployment SHALL automatically discover the hub VNet in the subscription and enable peering by default when a hub is found.

#### Scenario: Hub VNet exists in subscription

- **WHEN** deploying a spoke and a VNet matching pattern `vnet-hub*` exists in the subscription
- **THEN** the deployment automatically configures VNet peering to the discovered hub

#### Scenario: No hub VNet exists

- **WHEN** deploying a spoke and no hub VNet is found in the subscription
- **THEN** the deployment completes without peering and displays a warning message

#### Scenario: Multiple hub VNets exist

- **WHEN** deploying a spoke and multiple VNets match the hub pattern
- **THEN** the deployment prompts the user to select which hub to peer with or uses the first match

### Requirement: Disable Peering Option

The spoke deployment script SHALL provide a `-DisablePeering` switch to explicitly skip hub peering even when a hub VNet is discovered.

#### Scenario: Explicit disable peering

- **WHEN** user runs `.\deploy.ps1 -SpokeNumber 1 -DisablePeering`
- **THEN** the deployment skips hub discovery and VNet peering

### Requirement: Peering Configuration Display

The deployment output SHALL clearly indicate the peering status and hub VNet details when peering is configured.

#### Scenario: Peering status in output

- **WHEN** spoke deployment completes with peering enabled
- **THEN** the output displays "Peered to: vnet-hub-prod (10.10.0.0/20)"

## MODIFIED Requirements

### Requirement: Hub VNet Peering

VNet peering to hub SHALL be enabled by default when hub VNet is auto-discovered, replacing the previous opt-in behavior requiring manual hubVnetId parameter.

#### Scenario: Default peering behavior

- **WHEN** deploying a spoke without specifying peering parameters
- **THEN** the deployment attempts to auto-discover and peer with hub VNet

#### Scenario: Manual hub ID override

- **WHEN** user provides explicit `-HubVnetId` parameter
- **THEN** the deployment uses the provided ID instead of auto-discovery
