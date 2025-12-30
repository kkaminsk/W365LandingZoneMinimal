## ADDED Requirements

### Requirement: Windows 365 Permission Assignment

The `Set-W365Permissions.ps1` script SHALL assign Windows 365 service principal permissions to the consolidated spoke VNet and resource group using spoke terminology.

#### Scenario: Assign permissions to consolidated VNet

- **WHEN** running `Set-W365Permissions.ps1` and selecting resource group `rg-w365-spokes-prod`
- **THEN** the script assigns "Windows 365 Network User" role to the consolidated VNet `vnet-w365-spokes-prod`

#### Scenario: Resource group permission scope

- **WHEN** assigning "Windows 365 Network Interface Contributor" role
- **THEN** the role is scoped to the consolidated resource group `rg-w365-spokes-{env}`

### Requirement: Windows 365 Permission Verification

The `Check-W365Permissions.ps1` script SHALL verify Windows 365 permissions on the consolidated spoke infrastructure using spoke terminology.

#### Scenario: Check consolidated VNet permissions

- **WHEN** running `Check-W365Permissions.ps1` and selecting consolidated VNet
- **THEN** the script checks for "Windows 365 Network User" role on the VNet

#### Scenario: Display spoke-focused output

- **WHEN** permission check completes
- **THEN** output messages use "spoke" terminology instead of "student"

### Requirement: Minimum Permissions Setup

The `Setup-MinimumPermissions.ps1` script SHALL configure permissions for the consolidated spoke resource group pattern.

#### Scenario: Default resource group name

- **WHEN** running script without ResourceGroupName parameter
- **THEN** the default is `rg-w365-spokes-prod`

#### Scenario: IP range defaults

- **WHEN** running script without AllowedIPRanges parameter
- **THEN** the default includes `192.168.0.0/16` for consolidated VNet space
