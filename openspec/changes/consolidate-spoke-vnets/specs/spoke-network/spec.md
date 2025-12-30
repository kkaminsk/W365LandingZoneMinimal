## ADDED Requirements

### Requirement: Consolidated Spoke VNet

The spoke deployment SHALL create or use a single consolidated VNet (192.168.0.0/16) for all spoke subnets instead of individual VNets per spoke.

#### Scenario: First spoke deployment creates VNet

- **WHEN** deploying spoke 1 and no consolidated VNet exists
- **THEN** the deployment creates VNet `vnet-w365-spokes-prod` with address space 192.168.0.0/16 and subnets for spoke 1

#### Scenario: Subsequent spoke deployment adds subnets

- **WHEN** deploying spoke 5 and consolidated VNet already exists
- **THEN** the deployment adds subnets for spoke 5 to the existing VNet without recreating it

### Requirement: Spoke Subnet Allocation

Each spoke SHALL receive dedicated subnets within the consolidated VNet using the pattern 192.168.{SpokeNumber}.0/24.

#### Scenario: Subnet naming convention

- **WHEN** deploying spoke 3
- **THEN** subnets are named `snet-spoke3-cloudpc`, `snet-spoke3-mgmt`, and optionally `snet-spoke3-avd`

#### Scenario: Subnet CIDR allocation

- **WHEN** deploying spoke 10
- **THEN** the Cloud PC subnet is 192.168.10.0/26, Management subnet is 192.168.10.64/26, and AVD subnet is 192.168.10.128/26

### Requirement: Single Spoke Resource Group

All spoke resources SHALL be deployed to a single shared resource group named `rg-w365-spokes-{env}`.

#### Scenario: Resource group reuse

- **WHEN** deploying any spoke number
- **THEN** resources are created in `rg-w365-spokes-prod` resource group

## REMOVED Requirements

### Requirement: Per-Spoke VNet

**Reason**: Replaced by consolidated VNet approach for simplified management.

**Migration**: Migrate existing Cloud PCs to subnets in consolidated VNet, then delete old per-spoke VNets and resource groups.

### Requirement: Per-Spoke Resource Group

**Reason**: Single resource group simplifies RBAC and management.

**Migration**: After migrating workloads, delete old resource groups `rg-w365-spoke-student{N}-{env}`.
