# Change: Rename StudentNumber to SpokeNumber

## Why

The term "StudentNumber" is too specific and implies this infrastructure is only for educational/lab environments. "SpokeNumber" is more generic and accurately reflects the hub-spoke architecture pattern, making the project suitable for any multi-tenant deployment scenario.

## What Changes

- Rename all `StudentNumber` parameter references to `SpokeNumber` in scripts
- Update all `studentNumber` parameter references in Bicep templates
- Rename resource naming patterns from `student{N}` to `spoke{N}`
- Update all documentation references from "student" to "spoke"
- Update IP addressing documentation to use spoke terminology
- Update example commands and help text

## Impact

- Affected specs: spoke-deployment
- Affected code:
  - `2_Spoke/deploy.ps1` - parameter rename
  - `2_Spoke/infra/envs/prod/main.bicep` - parameter and variable renames
  - `2_Spoke/infra/envs/prod/parameters.prod.json` - parameter rename
  - All documentation files in `2_Spoke/` directory
  - Root `CLAUDE.md` and `README.md`
  - `openspec/project.md`
- **BREAKING**: Parameter name change requires users to update deployment scripts
