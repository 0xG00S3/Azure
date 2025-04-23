# Azure Red Team Tooling for Windows

This repository contains setup scripts for Azure red team tooling on Windows systems. It creates a clean, organized environment for all your tools with proper module management and easy-to-use scripts.

## Prerequisites

- Windows 10 or later
- PowerShell 5.1 or later
- .NET Framework 4.7.2 or later
- Git for Windows
- Python 3.8 or later
- Ruby 2.7 or later (for Evil-WinRM)
- Administrator privileges

## Directory Structure

```
C:\dontscan\azure-cloud\
├── Modules\          # PowerShell modules
│   ├── MSOLSpray
│   ├── AADInternals
│   ├── TokenTacticsV2
│   └── GraphRunner
├── Tools\           # General tools
├── Python\          # Python tools
│   ├── AzSubEnum
│   ├── Oh365UserFinder
│   └── BasicBlobFinder
├── Ruby\            # Ruby tools
└── Go\              # Go tools
```

## Installation

1. Run PowerShell as Administrator

2. Set execution policy:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
```

3. Run the Windows installation script:
```powershell
.\windows-tooling-install.ps1
```

The script will:
- Create necessary directories
- Install PowerShell modules
- Download and install GitHub tools
- Set up Python tools
- Verify installations

## Usage

After installation, you can import all modules using:
```powershell
.\windows-import-modules.ps1
```

### Common Commands

#### Azure Modules
```powershell
# Connect to Azure
Connect-AzAccount

# List resources
Get-AzResource

# Check role assignments
Get-AzRoleAssignment
```

#### Microsoft Graph
```powershell
# Connect to Graph
Connect-MgGraph

# List users
Get-MgUser

# Check group membership
Get-MgUserMemberOf
```

#### AADInternals
```powershell
# Get tenant information
Get-AADIntLoginInformation

# Check tenant ID
Get-AADIntTenantID
```

#### MSOLSpray
```powershell
# Password spray
Invoke-MSOLSpray -UserList users.txt -Password "password"
```

## Maintenance

### Updating Tools
To update all tools, simply run the installation script again:
```powershell
.\windows-tooling-install.ps1
```

### Cleaning Up
To remove all installed components:
```powershell
.\windows-tooling-cleanup.ps1
```

The cleanup script will:
- Uninstall all PowerShell modules
- Remove all GitHub tools
- Remove all Python tools
- Clean up the base directory if empty
- Reset execution policy

Note: The cleanup script will skip built-in Windows modules to prevent system issues.

## Troubleshooting

### Common Issues

1. Module Installation Failures
   - Check internet connectivity
   - Verify PowerShell execution policy
   - Check for sufficient permissions

2. Certificate Issues
   - Verify certificate store access
   - Check certificate permissions
   - Validate certificate chain

3. Authentication Issues
   - Verify Azure CLI installation
   - Check token cache
   - Validate credentials

### Platform-Specific Issues

- PowerShell execution policy restrictions
- Certificate store access
- WinRM configuration

## Security Considerations

1. Tool Installation
   - Verify tool sources
   - Check tool signatures
   - Use secure download methods

2. Credential Management
   - Use secure credential storage
   - Implement proper access controls
   - Follow least privilege principle

3. Network Security
   - Use secure connections
   - Implement proper firewall rules
   - Monitor network traffic

## Additional Resources

- [Microsoft Graph API Documentation](https://learn.microsoft.com/en-us/graph/overview)
- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)
- [Azure Security Documentation](https://learn.microsoft.com/en-us/azure/security/) 
