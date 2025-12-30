# spoke-deployment Specification

## Purpose
TBD - created by archiving change rename-student-to-spoke. Update Purpose after archive.
## Requirements
### Requirement: Spoke Number Parameter

The spoke deployment script SHALL accept a `SpokeNumber` parameter (range 1-40) to identify the spoke instance for unique IP addressing.

#### Scenario: Deploy with spoke number parameter

- **WHEN** user runs `.\deploy.ps1 -SpokeNumber 5`
- **THEN** the deployment creates resources for spoke 5 with IP range 192.168.5.0/24

#### Scenario: Interactive spoke number prompt

- **WHEN** user runs `.\deploy.ps1` without the SpokeNumber parameter
- **THEN** the script prompts "Enter Spoke Number (1-40)"

