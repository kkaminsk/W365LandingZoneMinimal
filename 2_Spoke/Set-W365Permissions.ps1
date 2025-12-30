<#
.SYNOPSIS
    Assigns Windows 365 permissions to the Windows 365 service principal

.DESCRIPTION
    This script assigns the required permissions for Windows 365 to work with your Azure resources.
    It supports tenant selection to ensure you're connecting to the correct tenant.

.PARAMETER TenantId
    Optional Azure AD tenant ID. If not provided, you'll be prompted to select from available tenants.

.EXAMPLE
    .\Set-W365Permissions.ps1
    Run with interactive tenant selection

.EXAMPLE
    .\Set-W365Permissions.ps1 -TenantId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    Run with specific tenant ID
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$TenantId
)

# Setup logging
$timestamp = Get-Date -Format "MM-dd-HH-mm"
$logPath = "$env:USERPROFILE\Documents\Set-W365Permissions-$timestamp.log"

# Function to write to both console and log file
function Write-LogOutput {
    param(
        [string]$Message,
        [string]$ForegroundColor = "White"
    )
    Write-Host $Message -ForegroundColor $ForegroundColor
    Add-Content -Path $logPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
}

Write-LogOutput "Starting Windows 365 Permission Assignment Script" "Cyan"
Write-LogOutput "⚠️  WARNING: This script will MODIFY role assignments in your Azure environment" "Yellow"
Write-LogOutput "Log file: $logPath" "Gray"
Write-LogOutput "`n📌 Note: This deployment uses a consolidated architecture:" "Cyan"
Write-LogOutput "   - Resource Group: rg-w365-spokes-prod (single RG for all spokes)" "Gray"
Write-LogOutput "   - VNet: vnet-w365-spokes-prod (consolidated VNet with 192.168.0.0/16)" "Gray"

# Connect to your Azure Account
Write-LogOutput "`nConnecting to Azure Account..." "Cyan"
Write-LogOutput "⚠️  A browser window will open for authentication. Please complete the sign-in process." "Yellow"
Write-LogOutput "    (The browser window may open behind other windows - check your taskbar)" "Gray"

# Initial connection to enumerate tenants
Connect-AzAccount | Out-Null

# Get available tenants
Write-LogOutput "`n🔍 Retrieving available tenants..." "Cyan"
$tenants = @(Get-AzTenant)

if ($tenants.Count -eq 0) {
    Write-LogOutput "❌ No accessible tenants found." "Red"
    return
}

$selectedTenant = $null

if ($TenantId) {
    # Use specified tenant ID
    $selectedTenant = $tenants | Where-Object { $_.Id -eq $TenantId }
    if (-not $selectedTenant) {
        Write-LogOutput "❌ Specified tenant ID '$TenantId' is not accessible." "Red"
        return
    }
    Write-LogOutput "✅ Using specified tenant: $($selectedTenant.Name) ($($selectedTenant.Id))" "Green"
}
elseif ($tenants.Count -eq 1) {
    # Only one tenant available
    $selectedTenant = $tenants[0]
    Write-LogOutput "✅ Single tenant detected: $($selectedTenant.Name) ($($selectedTenant.Id))" "Green"
}
else {
    # Prompt user to select a tenant
    Write-LogOutput "`nAvailable Tenants:" "Yellow"
    for ($i = 0; $i -lt $tenants.Count; $i++) {
        $tenant = $tenants[$i]
        Write-LogOutput "  [$($i + 1)] $($tenant.Name) ($($tenant.Id))"
    }
    
    do {
        $tenantChoice = Read-Host "`nEnter the number of the tenant you want to use (1-$($tenants.Count))"
        Add-Content -Path $logPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): User selected tenant option: $tenantChoice"
        $tenantIndex = [int]$tenantChoice - 1
    } while ($tenantIndex -lt 0 -or $tenantIndex -ge $tenants.Count)
    
    $selectedTenant = $tenants[$tenantIndex]
    Write-LogOutput "✅ Selected tenant: $($selectedTenant.Name) ($($selectedTenant.Id))" "Green"
}

# Connect to the selected tenant
Write-LogOutput "`nAuthenticating to tenant..." "Cyan"
Connect-AzAccount -TenantId $selectedTenant.Id | Out-Null
Write-LogOutput "✅ Successfully connected to Azure" "Green"

Write-LogOutput "`n🔍 Retrieving available subscriptions..." "Cyan"
$subscriptions = Get-AzSubscription
if ($subscriptions.Count -eq 0) {
    Write-LogOutput "❌ No subscriptions found." "Red"
    return
}

# Prompt user to select a subscription
Write-LogOutput "`nAvailable Subscriptions:" "Yellow"
for ($i = 0; $i -lt $subscriptions.Count; $i++) {
    Write-LogOutput "  [$($i + 1)] $($subscriptions[$i].Name) (ID: $($subscriptions[$i].Id))"
}
$subChoice = Read-Host "`nEnter the number of the subscription you want to use"
Add-Content -Path $logPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): User selected subscription option: $subChoice"
$selectedSub = $subscriptions[$subChoice - 1]
$subscriptionId = $selectedSub.Id

# Set the active subscription context
Set-AzContext -Subscription $subscriptionId
Write-LogOutput "✅ Selected subscription: $($selectedSub.Name)" "Green"

# Get available resource groups
Write-LogOutput "`n🔍 Retrieving available resource groups..." "Cyan"
$resourceGroups = Get-AzResourceGroup
if ($resourceGroups.Count -eq 0) {
    Write-LogOutput "❌ No resource groups found." "Red"
    return
}

# Prompt user to select a resource group
Write-LogOutput "`nAvailable Resource Groups:" "Yellow"
Write-LogOutput "  💡 TIP: For consolidated spoke architecture, select 'rg-w365-spokes-prod'" "Cyan"
for ($i = 0; $i -lt $resourceGroups.Count; $i++) {
    $rgName = $resourceGroups[$i].ResourceGroupName
    $suffix = ""
    if ($rgName -like "rg-w365-spokes-*") {
        $suffix = " ← Consolidated spoke RG"
    }
    Write-LogOutput "  [$($i + 1)] $rgName (Location: $($resourceGroups[$i].Location))$suffix"
}
$rgChoice = Read-Host "`nEnter the number of the resource group you want to use"
Add-Content -Path $logPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): User selected resource group option: $rgChoice"
$selectedRg = $resourceGroups[$rgChoice - 1]
$resourceGroupName = $selectedRg.ResourceGroupName
Write-LogOutput "✅ Selected resource group: $resourceGroupName" "Green"

# Get available virtual networks in the selected resource group
Write-LogOutput "`n🔍 Retrieving available virtual networks in '$resourceGroupName'..." "Cyan"
$virtualNetworks = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName
if ($virtualNetworks.Count -eq 0) {
    Write-LogOutput "❌ No virtual networks found in resource group '$resourceGroupName'." "Red"
    return
}

# Prompt user to select a virtual network
Write-LogOutput "`nAvailable Virtual Networks:" "Yellow"
Write-LogOutput "  💡 TIP: For consolidated spoke architecture, select 'vnet-w365-spokes-prod'" "Cyan"
for ($i = 0; $i -lt $virtualNetworks.Count; $i++) {
    $vnetName = $virtualNetworks[$i].Name
    $suffix = ""
    if ($vnetName -like "vnet-w365-spokes-*") {
        $suffix = " ← Consolidated spoke VNet"
    }
    Write-LogOutput "  [$($i + 1)] $vnetName (Location: $($virtualNetworks[$i].Location))$suffix"
}
$vnetChoice = Read-Host "`nEnter the number of the virtual network you want to use"
Add-Content -Path $logPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): User selected virtual network option: $vnetChoice"
$selectedVnet = $virtualNetworks[$vnetChoice - 1]
$virtualNetworkName = $selectedVnet.Name
$vnetId = $selectedVnet.Id
Write-LogOutput "✅ Selected virtual network: $virtualNetworkName" "Green"

Write-LogOutput "`n========================================" "Cyan"
Write-LogOutput "Starting Windows 365 Permission Assignment" "Cyan"
Write-LogOutput "========================================`n" "Cyan"

# Get the Windows 365 Service Principal
try {
    $sp = Get-AzADServicePrincipal -ApplicationId '0af06dc6-e4b5-4f28-818e-e78e62d137a5' -ErrorAction Stop
    Write-LogOutput "✅ Found Windows 365 Service Principal (ID: $($sp.Id))" "Green"
}
catch {
    Write-LogOutput "❌ Error: Could not find the Windows 365 Service Principal." "Red"
    Write-LogOutput "   Make sure the Windows 365 service is available in your tenant." "Yellow"
    return
}

# 1. Check and Assign Subscription-Level 'Reader' Role
Write-LogOutput "`n🔍 1. Checking Subscription-Level 'Reader' Permission..." "Cyan"
$subScope = "/subscriptions/$subscriptionId"
$subRoles = Get-AzRoleAssignment -ObjectId $sp.Id -Scope $subScope -ErrorAction SilentlyContinue

if ($subRoles | Where-Object { $_.RoleDefinitionName -eq "Reader" }) {
    Write-LogOutput "  ✅ Already exists: 'Reader' role on the subscription." "Green"
} else {
    Write-LogOutput "  ⚠️  Missing: 'Reader' role on the subscription. Attempting to assign..." "Yellow"
    try {
        New-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName "Reader" -Scope $subScope -ErrorAction Stop | Out-Null
        Write-LogOutput "  ✅ SUCCESS: Assigned 'Reader' role on the subscription." "Green"
    }
    catch {
        Write-LogOutput "  ❌ FAILED: Could not assign 'Reader' role on the subscription." "Red"
        Write-LogOutput "     Error: $($_.Exception.Message)" "Red"
    }
}

# 2. Check and Assign Resource Group-Level 'Windows 365 Network Interface Contributor' Role
Write-LogOutput "`n🔍 2. Checking Resource Group-Level 'Windows 365 Network Interface Contributor' Permission..." "Cyan"
$rgScope = (Get-AzResourceGroup -Name $resourceGroupName).ResourceId
$rgRoles = Get-AzRoleAssignment -ObjectId $sp.Id -Scope $rgScope -ErrorAction SilentlyContinue

if ($rgRoles | Where-Object { $_.RoleDefinitionName -eq "Windows 365 Network Interface Contributor" }) {
    Write-LogOutput "  ✅ Already exists: 'Windows 365 Network Interface Contributor' role on the resource group." "Green"
} else {
    Write-LogOutput "  ⚠️  Missing: 'Windows 365 Network Interface Contributor' role on the resource group. Attempting to assign..." "Yellow"
    try {
        New-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName "Windows 365 Network Interface Contributor" -Scope $rgScope -ErrorAction Stop | Out-Null
        Write-LogOutput "  ✅ SUCCESS: Assigned 'Windows 365 Network Interface Contributor' role on the resource group." "Green"
    }
    catch {
        Write-LogOutput "  ❌ FAILED: Could not assign 'Windows 365 Network Interface Contributor' role on the resource group." "Red"
        Write-LogOutput "     Error: $($_.Exception.Message)" "Red"
    }
}

# 3. Check and Assign Virtual Network-Level 'Windows 365 Network User' Role
Write-LogOutput "`n🔍 3. Checking Virtual Network-Level 'Windows 365 Network User' Permission..." "Cyan"
$vnetRoles = Get-AzRoleAssignment -ObjectId $sp.Id -Scope $vnetId -ErrorAction SilentlyContinue

if ($vnetRoles | Where-Object { $_.RoleDefinitionName -eq "Windows 365 Network User" }) {
    Write-LogOutput "  ✅ Already exists: 'Windows 365 Network User' role on the virtual network." "Green"
} else {
    Write-LogOutput "  ⚠️  Missing: 'Windows 365 Network User' role on the virtual network. Attempting to assign..." "Yellow"
    try {
        New-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName "Windows 365 Network User" -Scope $vnetId -ErrorAction Stop | Out-Null
        Write-LogOutput "  ✅ SUCCESS: Assigned 'Windows 365 Network User' role on the virtual network." "Green"
    }
    catch {
        Write-LogOutput "  ❌ FAILED: Could not assign 'Windows 365 Network User' role on the virtual network." "Red"
        Write-LogOutput "     Error: $($_.Exception.Message)" "Red"
    }
}

Write-LogOutput "`n========================================" "Cyan"
Write-LogOutput "Permission assignment completed!" "Green"
Write-LogOutput "========================================" "Cyan"
Write-LogOutput "`n📋 Summary:" "Cyan"
Write-LogOutput "  • Log file: $logPath" "Gray"
Write-LogOutput "  • Run the Check-W365Permissions.ps1 script to verify all permissions are now in place." "Yellow"
Write-LogOutput "`n✅ Done!" "Green"
