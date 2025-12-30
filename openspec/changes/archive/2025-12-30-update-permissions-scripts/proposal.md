# Change: Update Permissions Scripts for Architecture Changes

## Why

The permissions scripts need to be updated to align with the other proposed changes:
1. Terminology change from "student" to "spoke"
2. Consolidated VNet architecture (single VNet instead of per-spoke)
3. Single resource group for all spokes

These scripts are critical for Windows 365 service principal configuration and must work correctly with the new architecture.

## What Changes

- Update all scripts to use "spoke" terminology
- Modify resource group selection to work with consolidated `rg-w365-spokes-{env}` pattern
- Update VNet selection to handle consolidated VNet with multiple subnets
- Add spoke number parameter for subnet-level permission scoping
- Update documentation and help text
- Update `Setup-MinimumPermissions.ps1` for new resource group naming

## Impact

- Affected specs: spoke-permissions
- Affected code:
  - `2_Spoke/Set-W365Permissions.ps1` - terminology and scope changes
  - `2_Spoke/Check-W365Permissions.ps1` - terminology and scope changes
  - `2_Spoke/Setup-MinimumPermissions.ps1` - resource group naming
  - `2_Spoke/W365-MinimumRole.json` - no changes needed (role actions remain same)
- **Note**: This change depends on proposals `rename-student-to-spoke` and `consolidate-spoke-vnets`
