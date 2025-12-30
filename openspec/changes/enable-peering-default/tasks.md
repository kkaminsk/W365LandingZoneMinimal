## 1. Hub Discovery Implementation

- [x] 1.1 Add function to `2_Spoke/deploy.ps1` to discover hub VNet by naming convention
- [x] 1.2 Search for VNets matching pattern `vnet-hub*` in subscription
- [x] 1.3 Add fallback to search in known hub resource group `rg-hub-*`
- [x] 1.4 Return hub VNet resource ID if found

## 2. Deployment Script Updates

- [x] 2.1 Add `-DisablePeering` switch parameter to deploy.ps1
- [x] 2.2 Add `-HubVnetId` parameter for manual override
- [x] 2.3 Call hub discovery function during deployment
- [x] 2.4 Pass discovered hubVnetId to Bicep deployment automatically
- [x] 2.5 Display peering status in deployment output

## 3. Bicep Template Updates

- [x] 3.1 Update `2_Spoke/infra/envs/prod/main.bicep` parameter descriptions
- [x] 3.2 Update default behavior description in comments
- [x] 3.3 Ensure module handles both auto-discovered and manually provided hub IDs

## 4. Documentation Updates

- [x] 4.1 Update `2_Spoke/README.md` with auto-peering behavior
- [x] 4.2 Update `2_Spoke/QUICKSTART.md`
- [x] 4.3 Update `2_Spoke/Deployps1-Readme.md` with new parameter
- [x] 4.4 Update `2_Spoke/HUB-VS-SPOKE.md` with peering details
- [x] 4.5 Update `2_Spoke/CLAUDE.md`
- [x] 4.6 Update root documentation

## 5. Validation

- [x] 5.1 Hub discovery function implemented and tested
- [x] 5.2 -DisablePeering flag prevents peering
- [x] 5.3 -HubVnetId overrides auto-discovery
- [x] 5.4 Peering status displayed in deployment output
