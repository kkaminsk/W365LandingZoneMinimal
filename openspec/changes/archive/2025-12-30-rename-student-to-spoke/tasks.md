## 1. Script Updates

- [x] 1.1 Update `2_Spoke/deploy.ps1` - rename `StudentNumber` parameter to `SpokeNumber`
- [x] 1.2 Update all `StudentNumber` variable references in deploy.ps1
- [x] 1.3 Update user prompts and output messages from "Student" to "Spoke"

## 2. Bicep Template Updates

- [x] 2.1 Update `2_Spoke/infra/envs/prod/main.bicep` - rename `studentNumber` parameter to `spokeNumber`
- [x] 2.2 Update variable references (`thirdOctet = studentNumber` -> `thirdOctet = spokeNumber`)
- [x] 2.3 Update resource naming patterns (`student${studentNumber}` -> `spoke${spokeNumber}`)
- [x] 2.4 Update module deployment names

## 3. Parameter File Updates

- [x] 3.1 Update `2_Spoke/infra/envs/prod/parameters.prod.json` - renamed studentNumber to spokeNumber

## 4. Documentation Updates

- [x] 4.1 Update `2_Spoke/README.md`
- [x] 4.2 Update `2_Spoke/QUICKSTART.md`
- [x] 4.3 Update `2_Spoke/Deployps1-Readme.md`
- [x] 4.4 Update `2_Spoke/IP-ADDRESSING.md`
- [x] 4.5 Update `2_Spoke/CLAUDE.md`
- [x] 4.6 Update `2_Spoke/HUB-VS-SPOKE.md`
- [x] 4.7 Update `2_Spoke/DEPLOYMENT-SUMMARY.md`
- [x] 4.8 Update `2_Spoke/ExecutionFlow.md`
- [x] 4.9 Update `2_Spoke/vNET_Config.md`
- [x] 4.10 Update `2_Spoke/PERMISSIONS-AND-RESTRICTIONS.md`
- [x] 4.11 Update root `CLAUDE.md`
- [x] 4.12 Update root `README.md` (if exists)
- [x] 4.13 Update `openspec/project.md`

## 5. Validation

- [x] 5.1 Template syntax verified with updated parameter names
- [x] 5.2 All documentation consistent with new spoke terminology
