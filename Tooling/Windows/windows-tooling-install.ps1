# Azure Red Team Module Installation Script for Windows
# This script installs all PowerShell modules and tools required for Azure red team operations on Windows

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

# Create base directory
$baseDir = "C:\dontscan\azure-cloud"
if (!(Test-Path $baseDir)) {
    New-Item -ItemType Directory -Path $baseDir -Force
}

# Create subdirectories
$dirs = @(
    "Modules",
    "Tools",
    "Python",
    "Ruby",
    "Go"
)

foreach ($dir in $dirs) {
    $path = Join-Path $baseDir $dir
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force
    }
}

# Install NuGet package provider if not already installed
if (!(Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -Force
}

# Install PowerShellGet if not already installed
if (!(Get-Module -ListAvailable -Name PowerShellGet)) {
    Install-Module -Name PowerShellGet -Force
}

# Define required modules
$requiredModules = @(
    # Azure Modules
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
    "Az.Security",
    
    # Additional Security Modules
    "Microsoft.Graph",
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Identity.DirectoryManagement",
    "Microsoft.Graph.Users",
    "Microsoft.Graph.Groups",
    "Microsoft.Graph.Teams",
    "Microsoft.Graph.Sites",
    "Microsoft.Graph.Identity.Governance",
    "Microsoft.Graph.Identity.SignIns",
    "Microsoft.Graph.Reports",
    
    # Legacy Azure AD Modules
    "AzureAD",
    "AzureADPreview",
    "MSOnline",
    
    # Utility Modules
    "PSFramework",
    "PSModuleDevelopment",
    "PSFTP",
    "PSScriptAnalyzer",
    "PSReadLine"
)

# Install each module
foreach ($module in $requiredModules) {
    $installedModule = Get-Module -ListAvailable -Name $module
    if ($installedModule) {
        Write-Host "Module $module is already installed (Version: $($installedModule.Version)). Skipping..." -ForegroundColor Yellow
    }
    else {
        Write-Host "Installing module: $module" -ForegroundColor Green
        try {
            Install-Module -Name $module -Force -AllowClobber -Scope AllUsers
            Write-Host "Successfully installed $module" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to install $module. Error: $_" -ForegroundColor Red
        }
    }
}

# Install additional tools from GitHub
$githubTools = @(
    @{
        Name = "MSOLSpray"
        URL = "https://github.com/dafthack/MSOLSpray/archive/master.zip"
        Path = Join-Path $baseDir "Modules\MSOLSpray"
    },
    @{
        Name = "AADInternals"
        URL = "https://github.com/Gerenios/AADInternals/archive/master.zip"
        Path = Join-Path $baseDir "Modules\AADInternals"
    },
    @{
        Name = "TokenTacticsV2"
        URL = "https://github.com/f-bader/TokenTacticsV2/archive/master.zip"
        Path = Join-Path $baseDir "Modules\TokenTacticsV2"
    },
    @{
        Name = "GraphRunner"
        URL = "https://github.com/dafthack/GraphRunner/archive/master.zip"
        Path = Join-Path $baseDir "Modules\GraphRunner"
    }
)

# Download and install GitHub tools
foreach ($tool in $githubTools) {
    if (Test-Path $tool.Path) {
        Write-Host "$($tool.Name) is already installed at $($tool.Path). Skipping..." -ForegroundColor Yellow
    }
    else {
        Write-Host "Installing $($tool.Name) from GitHub..." -ForegroundColor Green
        try {
            # Create temporary directory
            $tempDir = Join-Path $env:TEMP $tool.Name
            if (Test-Path $tempDir) {
                Remove-Item -Path $tempDir -Recurse -Force
            }
            New-Item -ItemType Directory -Path $tempDir -Force

            # Download and extract
            Invoke-WebRequest -Uri $tool.URL -OutFile "$tempDir\master.zip"
            Expand-Archive -Path "$tempDir\master.zip" -DestinationPath $tempDir -Force

            # Move to modules directory
            if (Test-Path $tool.Path) {
                Remove-Item -Path $tool.Path -Recurse -Force
            }
            Move-Item -Path "$tempDir\*-master\*" -Destination $tool.Path -Force

            # Verify installation
            if (Test-Path $tool.Path) {
                Write-Host "Successfully installed $($tool.Name)" -ForegroundColor Green
            }
            else {
                Write-Host "Failed to install $($tool.Name) - Directory not created" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "Failed to install $($tool.Name). Error: $_" -ForegroundColor Red
        }
        finally {
            # Cleanup
            if (Test-Path $tempDir) {
                Remove-Item -Path $tempDir -Recurse -Force
            }
        }
    }
}

# Install Python tools
$pythonTools = @(
    @{
        Name = "AzSubEnum"
        URL = "https://github.com/yuyudhn/AzSubEnum/archive/master.zip"
        Path = Join-Path $baseDir "Python\AzSubEnum"
    },
    @{
        Name = "Oh365UserFinder"
        URL = "https://github.com/dievus/Oh365UserFinder/archive/master.zip"
        Path = Join-Path $baseDir "Python\Oh365UserFinder"
    },
    @{
        Name = "BasicBlobFinder"
        URL = "https://github.com/joswr1ght/basicblobfinder/archive/master.zip"
        Path = Join-Path $baseDir "Python\BasicBlobFinder"
    }
)

# Download and install Python tools
foreach ($tool in $pythonTools) {
    if (Test-Path $tool.Path) {
        Write-Host "$($tool.Name) is already installed at $($tool.Path). Skipping..." -ForegroundColor Yellow
    }
    else {
        Write-Host "Installing $($tool.Name) from GitHub..." -ForegroundColor Green
        try {
            # Create temporary directory
            $tempDir = Join-Path $env:TEMP $tool.Name
            if (Test-Path $tempDir) {
                Remove-Item -Path $tempDir -Recurse -Force
            }
            New-Item -ItemType Directory -Path $tempDir -Force

            # Download and extract
            Invoke-WebRequest -Uri $tool.URL -OutFile "$tempDir\master.zip"
            Expand-Archive -Path "$tempDir\master.zip" -DestinationPath $tempDir -Force

            # Move to tools directory
            if (Test-Path $tool.Path) {
                Remove-Item -Path $tool.Path -Recurse -Force
            }
            Move-Item -Path "$tempDir\*-master\*" -Destination $tool.Path -Force

            # Install Python dependencies
            if (Test-Path "$($tool.Path)\requirements.txt") {
                python -m pip install -r "$($tool.Path)\requirements.txt"
            }

            # Verify installation
            if (Test-Path $tool.Path) {
                Write-Host "Successfully installed $($tool.Name)" -ForegroundColor Green
            }
            else {
                Write-Host "Failed to install $($tool.Name) - Directory not created" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "Failed to install $($tool.Name). Error: $_" -ForegroundColor Red
        }
        finally {
            # Cleanup
            if (Test-Path $tempDir) {
                Remove-Item -Path $tempDir -Recurse -Force
            }
        }
    }
}

# Verify installations
Write-Host "`nVerifying module installations..." -ForegroundColor Yellow
foreach ($module in $requiredModules) {
    if (Get-Module -ListAvailable -Name $module) {
        Write-Host "$module is installed" -ForegroundColor Green
    }
    else {
        Write-Host "$module is NOT installed" -ForegroundColor Red
    }
}

# Verify GitHub tools
Write-Host "`nVerifying GitHub tool installations..." -ForegroundColor Yellow
foreach ($tool in $githubTools) {
    if (Test-Path $tool.Path) {
        Write-Host "$($tool.Name) is installed" -ForegroundColor Green
    }
    else {
        Write-Host "$($tool.Name) is NOT installed" -ForegroundColor Red
    }
}

Write-Host "`nModule installation complete!" -ForegroundColor Green
Write-Host "Please run import-modules.ps1 to import all modules." -ForegroundColor Yellow 
