## 1. Architecture Redesign

- [x] 1.1 Design new subnet allocation scheme within 192.168.0.0/16 address space
- [x] 1.2 Define resource group strategy (single shared RG vs multiple)
- [x] 1.3 Document new IP addressing scheme

## 2. Bicep Template Updates

- [x] 2.1 Create new module for consolidated VNet (or update existing)
- [x] 2.2 Update `2_Spoke/infra/envs/prod/main.bicep` to deploy subnets instead of VNets
- [x] 2.3 Update `2_Spoke/infra/modules/spoke-network/main.bicep` for subnet-based deployment
- [x] 2.4 Update NSG resources to attach to subnets within shared VNet
- [x] 2.5 Update VNet peering module for single peering connection

## 3. Deployment Script Updates

- [x] 3.1 Update `2_Spoke/deploy.ps1` to check for existing consolidated VNet
- [x] 3.2 Add logic to create VNet on first spoke deployment, add subnets on subsequent
- [x] 3.3 Update resource naming conventions

## 4. Permissions Module Updates

- [x] 4.1 Update `2_Spoke/infra/modules/w365-permissions/main.bicep` for consolidated VNet scope

## 5. Documentation Updates

- [x] 5.1 Update `2_Spoke/README.md` with new architecture
- [x] 5.2 Update `2_Spoke/ARCHITECTURE-DIAGRAM.md` (if exists)
- [x] 5.3 Update `2_Spoke/IP-ADDRESSING.md` with new scheme
- [x] 5.4 Update `2_Spoke/QUICKSTART.md`
- [x] 5.5 Update `2_Spoke/vNET_Config.md`
- [x] 5.6 Update root documentation
- [x] 5.7 Update `openspec/project.md`

## 6. Validation

- [x] 6.1 Template syntax verified for consolidated deployment
- [x] 6.2 Subnet naming convention implemented
- [x] 6.3 NSG rules correctly scoped to per-spoke subnets
- [x] 6.4 Windows 365 permissions scope updated for consolidated VNet
