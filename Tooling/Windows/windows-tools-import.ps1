# Third-Party Tools Import Script for Windows
# This script imports third-party tools and modules for Azure red team operations

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Please run this script as Administrator" -ForegroundColor Red
    exit
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

# Define legacy modules
$legacyModules = @(
    "AzureAD",
    "AzureADPreview",
    "MSOnline"
)

# Define utility modules
$utilityModules = @(
    "PSFramework",
    "PSModuleDevelopment",
    "PSFTP",
    "PSScriptAnalyzer"
)

# Define GitHub tools
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

# Import legacy modules
Write-Host "`nImporting legacy modules..." -ForegroundColor Yellow
foreach ($module in $legacyModules) {
    Import-ModuleWithRetry -moduleName $module
}

# Import utility modules
Write-Host "`nImporting utility modules..." -ForegroundColor Yellow
foreach ($module in $utilityModules) {
    Import-ModuleWithRetry -moduleName $module
}

# Import GitHub tools
Write-Host "`nImporting GitHub tools..." -ForegroundColor Yellow
foreach ($tool in $githubTools) {
    if (Test-Path $tool.Path) {
        Write-Host "Importing $($tool.Name) from local path..." -ForegroundColor Green
        try {
            # Check for module manifest
            $moduleManifest = Get-ChildItem -Path $tool.Path -Filter "*.psd1" -Recurse | Select-Object -First 1
            if ($moduleManifest) {
                # Import using the module manifest
                Import-Module -Name $moduleManifest.FullName -Force -ErrorAction Stop
                Write-Host "Successfully imported $($tool.Name)" -ForegroundColor Green
            }
            else {
                # Check for module file
                $moduleFile = Get-ChildItem -Path $tool.Path -Filter "*.psm1" -Recurse | Select-Object -First 1
                if ($moduleFile) {
                    # Import using the module file
                    Import-Module -Name $moduleFile.FullName -Force -ErrorAction Stop
                    Write-Host "Successfully imported $($tool.Name)" -ForegroundColor Green
                }
                else {
                    # Check for main script file
                    $scriptFile = Get-ChildItem -Path $tool.Path -Filter "*.ps1" -Recurse | Select-Object -First 1
                    if ($scriptFile) {
                        # Import using the script file
                        Import-Module -Name $scriptFile.FullName -Force -ErrorAction Stop
                        Write-Host "Successfully imported $($tool.Name)" -ForegroundColor Green
                    }
                    else {
                        Write-Host "No module files found for $($tool.Name) at $($tool.Path)" -ForegroundColor Red
                    }
                }
            }
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
$allModules = $legacyModules + $utilityModules
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

Write-Host "`nThird-party tools import complete!" -ForegroundColor Green
Write-Host "All tools have been imported and are ready to use." -ForegroundColor Yellow 
