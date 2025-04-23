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

Due to PowerShell's function capacity limit (4096 functions per session), the modules are split into three separate import scripts. You'll need to use three different PowerShell sessions to import all modules:

1. Azure Modules Session:
```powershell
.\windows-azure-import.ps1
```
This imports all Azure-related modules (Az.*).

2. Microsoft Graph Session:
```powershell
.\windows-graph-import.ps1
```
This imports all Microsoft Graph modules (Microsoft.Graph.*).

3. Third-Party Tools Session:
```powershell
.\windows-tools-import.ps1
```
This imports legacy modules, utility modules, and GitHub tools.

### Common Commands

#### Azure Modules (First Session)
```powershell
# Connect to Azure
Connect-AzAccount

# List resources
Get-AzResource

# Check role assignments
Get-AzRoleAssignment
```

#### Microsoft Graph (Second Session)
```powershell
# Connect to Graph
Connect-MgGraph

# List users
Get-MgUser

# Check group membership
Get-MgUserMemberOf
```

#### Third-Party Tools (Third Session)
```powershell
# AADInternals
Get-AADIntLoginInformation
Get-AADIntTenantID

# MSOLSpray
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

4. Function Capacity Issues
   - If you see "Function capacity 4096 has been exceeded" errors
   - Ensure you're using separate PowerShell sessions for each import script
   - Do not try to import all modules in a single session

### Platform-Specific Issues

- PowerShell execution policy restrictions
- Certificate store access
- WinRM configuration
- Function capacity limitations

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
