## 1. Set-W365Permissions.ps1 Updates

- [x] 1.1 Update script help text terminology (student -> spoke)
- [x] 1.2 Add consolidated architecture messaging
- [x] 1.3 Update resource group discovery hints for consolidated pattern `rg-w365-spokes-*`
- [x] 1.4 Update VNet selection hints for consolidated VNet `vnet-w365-spokes-*`
- [x] 1.5 Update log output messages
- [x] 1.6 Permission scope correctly handles consolidated VNet

## 2. Check-W365Permissions.ps1 Updates

- [x] 2.1 Update script messaging for consolidated architecture
- [x] 2.2 Add hints for consolidated resource group
- [x] 2.3 Add hints for consolidated VNet
- [x] 2.4 Update output messages and log entries

## 3. Setup-MinimumPermissions.ps1 Updates

- [x] 3.1 Update default ResourceGroupName parameter to `rg-w365-spokes-prod`
- [x] 3.2 Update script help text and examples
- [x] 3.3 Update resource group tagging (remove "student" references)
- [x] 3.4 Update AllowedIPRanges default to 192.168.0.0/16 for consolidated VNet
- [x] 3.5 Update policy scope descriptions
- [x] 3.6 Update summary output

## 4. Documentation Updates

- [x] 4.1 Update `2_Spoke/PERMISSIONS-AND-RESTRICTIONS.md`
- [x] 4.2 Update script help examples in README files
- [x] 4.3 Update `2_Spoke/CLAUDE.md` permission script section

## 5. Validation

- [x] 5.1 Scripts updated with consolidated architecture hints
- [x] 5.2 Default parameters aligned with consolidated model
- [x] 5.3 Script functionality verified compatible with new structure
