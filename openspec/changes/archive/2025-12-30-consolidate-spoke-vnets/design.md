## Context

The current architecture deploys a separate VNet for each spoke (student/tenant). This creates management overhead and limits scalability. A consolidated VNet approach reduces complexity and aligns with common enterprise patterns.

### Current State
- Each spoke: separate VNet (192.168.{N}.0/24)
- Separate resource groups per spoke
- Individual VNet peerings to hub per spoke

### Proposed State
- Single consolidated VNet: 192.168.0.0/16
- Subnets per spoke within the VNet
- Single resource group for spoke infrastructure
- Single VNet peering to hub

## Goals / Non-Goals

### Goals
- Reduce Azure resource count
- Simplify network management
- Enable easier cross-spoke communication if needed
- Single peering connection to hub
- Maintain Windows 365 compatibility

### Non-Goals
- Changing the hub architecture
- Modifying the IP address range allocations per spoke
- Removing spoke isolation at the subnet/NSG level

## Decisions

### Decision 1: Consolidated VNet Address Space
- **What**: Use 192.168.0.0/16 as the consolidated VNet CIDR
- **Why**: Accommodates all 40 spokes with /24 subnet allocation per spoke
- **Alternative**: 192.168.0.0/17 or /18 - rejected as less headroom

### Decision 2: Subnet Naming Convention
- **What**: Use `snet-spoke{N}-{purpose}` naming (e.g., `snet-spoke5-cloudpc`)
- **Why**: Clear identification of spoke and purpose
- **Alternative**: `snet-{purpose}-spoke{N}` - rejected for consistency with spoke-first grouping

### Decision 3: Resource Group Strategy
- **What**: Single resource group `rg-w365-spokes-prod` for all spoke resources
- **Why**: Simpler management, single peering, easier RBAC
- **Alternative**: Keep per-spoke RGs - rejected as defeats consolidation purpose

### Decision 4: First Deployment Creates VNet
- **What**: First spoke deployment creates the VNet; subsequent deployments add subnets
- **Why**: Maintains idempotent deployment pattern
- **Alternative**: Separate VNet deployment - adds operational complexity

## Risks / Trade-offs

### Risk 1: Blast Radius
- **Risk**: Issue with VNet affects all spokes
- **Mitigation**: NSG isolation at subnet level, proper RBAC controls

### Risk 2: Migration Complexity
- **Risk**: Existing deployments require migration
- **Mitigation**: Document migration path, provide cleanup scripts

### Risk 3: RBAC Granularity
- **Risk**: Single RG means less granular permission control
- **Mitigation**: Use subnet-level RBAC where needed

## Migration Plan

1. Deploy new consolidated VNet in parallel
2. Migrate Windows 365 deployments to new subnets
3. Update DNS/peering as needed
4. Decommission old per-spoke VNets
5. Clean up old resource groups

## Open Questions

- Should existing per-spoke deployments be supported alongside consolidated model?
- What is the rollback strategy if consolidation causes issues?
