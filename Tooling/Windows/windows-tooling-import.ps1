# Azure Red Team Module Import Script for Windows
# This script imports all PowerShell modules required for Azure red team operations on Windows

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Please run this script as Administrator" -ForegroundColor Red
    exit
}

# Increase function capacity limit
Write-Host "Adjusting PowerShell function capacity limit..." -ForegroundColor Yellow
try {
    # Create a new session state
    $sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    
    # Create a new runspace with the session state
    $runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($sessionState)
    $runspace.Open()
    
    # Create a new PowerShell instance with the runspace
    $powershell = [System.Management.Automation.PowerShell]::Create($runspace)
    
    # Set the current runspace to use the new one
    $currentRunspace = [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace
    [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace = $runspace
    
    Write-Host "Function capacity limit adjusted successfully" -ForegroundColor Green
}
catch {
    Write-Host "Warning: Could not adjust function capacity limit. Continuing with default limit." -ForegroundColor Yellow
    Write-Host "Error: $_" -ForegroundColor Red
}

# Set execution policy to allow script execution
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
    Write-Host "Execution policy set successfully" -ForegroundColor Green
}
catch {
    Write-Host "Warning: Could not set execution policy. Continuing with current policy." -ForegroundColor Yellow
}

# Define base directory
$baseDir = "C:\dontscan\azure-cloud"

# Define required modules in groups to avoid function capacity issues
$azureModules = @(
    "Az",
    "Az.Accounts",
    "Az.Resources",
    "Az.KeyVault",
    "Az.Storage",
    "Az.Websites",
    "Az.Functions",
    "Az.Compute",
    "Az.Network",
    "Az.Monitor",
    "Az.OperationalInsights",
    "Az.Security"
)

$graphModules = @(
    "Microsoft.Graph",
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Identity.DirectoryManagement",
    "Microsoft.Graph.Users",
    "Microsoft.Graph.Groups",
    "Microsoft.Graph.Teams",
    "Microsoft.Graph.Sites",
    "Microsoft.Graph.Identity.Governance",
    "Microsoft.Graph.Identity.SignIns",
    "Microsoft.Graph.Reports"
)

$legacyModules = @(
    "AzureAD",
    "AzureADPreview",
    "MSOnline"
)

$utilityModules = @(
    "PSFramework",
    "PSModuleDevelopment",
    "PSFTP",
    "PSScriptAnalyzer"
)

# Function to import modules with error handling
function Import-ModuleWithRetry {
    param (
        [string]$moduleName,
        [int]$maxRetries = 3
    )
    
    $retryCount = 0
    $success = $false
    
    while (-not $success -and $retryCount -lt $maxRetries) {
        try {
            Write-Host "Importing module: $moduleName" -ForegroundColor Green
            Import-Module -Name $moduleName -Force -ErrorAction Stop
            Write-Host "Successfully imported $moduleName" -ForegroundColor Green
            $success = $true
        }
        catch {
            $retryCount++
            if ($retryCount -eq $maxRetries) {
                Write-Host "Failed to import $moduleName after $maxRetries attempts. Error: $_" -ForegroundColor Red
            } else {
                Write-Host "Retry $retryCount of $maxRetries for $moduleName..." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
        }
    }
}

# Import modules in groups
Write-Host "`nImporting Azure modules..." -ForegroundColor Yellow
foreach ($module in $azureModules) {
    Import-ModuleWithRetry -moduleName $module
}

Write-Host "`nImporting Microsoft Graph modules..." -ForegroundColor Yellow
foreach ($module in $graphModules) {
    Import-ModuleWithRetry -moduleName $module
}

Write-Host "`nImporting legacy modules..." -ForegroundColor Yellow
foreach ($module in $legacyModules) {
    Import-ModuleWithRetry -moduleName $module
}

Write-Host "`nImporting utility modules..." -ForegroundColor Yellow
foreach ($module in $utilityModules) {
    Import-ModuleWithRetry -moduleName $module
}

# Import GitHub tools
$githubTools = @(
    @{
        Name = "MSOLSpray"
        Path = Join-Path $baseDir "Modules\MSOLSpray"
    },
    @{
        Name = "AADInternals"
        Path = Join-Path $baseDir "Modules\AADInternals"
    },
    @{
        Name = "TokenTacticsV2"
        Path = Join-Path $baseDir "Modules\TokenTacticsV2"
    },
    @{
        Name = "GraphRunner"
        Path = Join-Path $baseDir "Modules\GraphRunner"
    }
)

Write-Host "`nImporting GitHub tools..." -ForegroundColor Yellow
foreach ($tool in $githubTools) {
    if (Test-Path $tool.Path) {
        Write-Host "Importing $($tool.Name) from local path..." -ForegroundColor Green
        try {
            Import-Module -Name $tool.Path -Force -ErrorAction Stop
            Write-Host "Successfully imported $($tool.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to import $($tool.Name). Error: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "$($tool.Name) module not found at $($tool.Path)" -ForegroundColor Red
    }
}

# Verify imports
Write-Host "`nVerifying module imports..." -ForegroundColor Yellow
$allModules = $azureModules + $graphModules + $legacyModules + $utilityModules
foreach ($module in $allModules) {
    if (Get-Module -Name $module) {
        Write-Host "$module is imported" -ForegroundColor Green
    }
    else {
        Write-Host "$module is NOT imported" -ForegroundColor Red
    }
}

# Display available commands
Write-Host "`nAvailable commands from imported modules:" -ForegroundColor Yellow
Get-Command -Module $allModules | Group-Object -Property Source | Select-Object Name, Count | Sort-Object Count -Descending | Format-Table -AutoSize

Write-Host "`nModule import complete!" -ForegroundColor Green
Write-Host "All modules have been imported and are ready to use." -ForegroundColor Yellow 
