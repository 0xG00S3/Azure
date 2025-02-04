# Azure Command Reference Guide

A comprehensive collection of Azure commands and techniques for red team operations and security assessments.

## Table of Contents
1. [Initial Setup and Tools](#initial-setup-and-tools)
2. [Authentication and Connections](#authentication-and-connections)
3. [Basic Information Gathering](#basic-information-gathering)
4. [Identity and Access Management](#identity-and-access-management)
5. [Resource Enumeration](#resource-enumeration)
6. [Container and Kubernetes Services](#container-and-kubernetes-services)
7. [Key Vault Operations](#key-vault-operations)
8. [Email and Exchange Operations](#email-and-exchange-operations)
9. [Common API Endpoints and Client IDs](#common-api-endpoints-and-client-ids)
10. [Metadata and Instance Information](#metadata-and-instance-information)
11. [Security and Compliance](#security-and-compliance)

## Initial Setup and Tools

### AADInternals
| Operation | Command |
|-----------|---------|
| Install Module | `Install-Module AADInternals` |
| Import Module | `Import-Module AADInternals` |

### Azure PowerShell Modules
| Module | Install Command |
|--------|----------------|
| Az Resources | `Install-Module -Name Az.Resources -AllowClobber -Force` |
| Graph Intune | `Install-Module -Name Microsoft.Graph.Intune -AllowClobber -Force` |
| Graph Device Management | `Install-Module -Name Microsoft.Graph.DeviceManagement -AllowClobber -Force` |
| Microsoft Graph | `Install-Module Microsoft.Graph -AllowClobber -Force` |

### Enumeration Tools
| Tool | Setup Command | Usage |
|------|--------------|-------|
| AzSubEnum | `git clone https://github.com/yuyudhn/AzSubEnum` | `python3 ~/Tools/AzSubEnum/azsubenum.py -b domain --thread 10` |
| Cloud_Enum | `git clone [repo]` | `python3 cloud_enum.py -k "target" --disable-aws --disable-gcp` |
| Oh365UserFinder | `git clone https://github.com/dievus/Oh365UserFinder` | `python3 oh365userfinder.py -d domain.com` |
| RoadRecon | `pip install roadlib roadrecon --break-system-packages` | `roadrecon auth -u 'user@domain.com' -p 'password'` |
| ScoutSuite | N/A | `scout azure --user-account -u USERNAME -p PASS --tenant ID_HERE` |

### Azure CLI Setup
| Operation | Command |
|-----------|---------|
| Install Azure CLI | `python3 -m venv azure-cli-env && source azure-cli-env/bin/activate && pip install azure-cli` |
| Set User Agent (PowerShell) | `$env:AZURE_HTTP_USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"` |
| Set User Agent (Linux) | `export AZURE_HTTP_USER_AGENT="Mozilla/5.0 (Linux; Android 4.0.2)"` |

## Authentication and Connections

### Basic Connection Methods
| Method | Command | Notes |
|--------|---------|-------|
| Interactive Login | `Connect-AzAccount` | Standard interactive login |
| Device Code Auth | `Connect-AzAccount -UseDeviceAuthentication` | Useful for MFA bypass |
| Token Auth | `Connect-AzAccount -AccessToken TOKEN -TenantId TID -AccountId EMAIL` | Direct token usage |
| Azure CLI Login | `az login -u user@domain.com -p password` | Use -u -p to bypass 2FA |
| Graph Connection | `Connect-MgGraph -ClientId "<ClientId>" -ClientSecret "<Secret>" -TenantId "<TenantId>"` | Graph API connection |

### Credential-Based Login
```powershell
$Username = "user@domain.com"
$Password = ConvertTo-SecureString "Password123" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($Username, $Password)
Connect-AzAccount -Credential $Credential
```

### Context and Subscription Management
| Operation | Command |
|-----------|---------|
| List Subscriptions | `Get-AzSubscription` |
| Get Current Context | `Get-AzContext` |
| Set Subscription | `Set-AzContext -SubscriptionId "SubID"` |
| List All Subscriptions (CLI) | `az account list --all --output table` |
| Set Subscription (CLI) | `az account set --subscription ID` |

## Basic Information Gathering

### Tenant and Domain Information
| Operation | Command |
|-----------|---------|
| Check Entra ID Management | `https://login.microsoftonline.com/getuserrealm.srf?login=domain.com&xml=1` |
| Get Tenant ID | `Get-AADIntTenantID -Domain domain.com` |
| Get Access Token Info | `Get-AzAccessToken` |
| List Resources | `Get-AzResource` |
| Get Login Information | `Get-AADIntLoginInformation -Domain domain.com` |
| Get OpenID Config | `https://login.microsoftonline.com/domain.com/.well-known/openid-configuration` |

### Token Management
| Operation | Command |
|-----------|---------|
| Get Graph Token | `Get-GraphTokens` |
| Get MS Graph Token | `Invoke-RefreshToMSGraphToken -domain domain.com -refreshToken "TOKEN"` |
| Get Azure Core Token | `Invoke-RefreshToAzureCoreManagementToken` |
| Get Key Vault Token | `Invoke-RefreshToAzureKeyVaultToken -domain domain.com -refreshToken "TOKEN"` |
| Get Storage Token | `Invoke-RefreshToAzureStorageToken -domain domain.com -refreshToken "TOKEN"` |
| Get Teams Token | `Invoke-RefreshToMSTeamsToken` |
| Get Office Apps Token | `Invoke-RefreshToOfficeAppsToken` |
| Get SharePoint Token | `Invoke-RefreshToSharePointToken` |

## Identity and Access Management

### User Management
| Operation | Command | Notes |
|-----------|---------|--------|
| Get User Object ID | `Get-UserObjectID -Token $tokens -upn user@domain.com` | Requires Graph Runner |
| Get Password Policy | `Get-MgBetaDirectorySetting \| where {$_.templateId -eq "5cf42378-d67d-4f36-ba46-e8b86229381d"}` | Requires Beta Module |
| List User Roles | `Get-MgUserMemberOf -userid "user@domain.com" \| select * -ExpandProperty additionalProperties` | Shows role names |
| Get User Info (CLI) | `az ad signed-in-user show` | Shows current user info |
| List All Users (CLI) | `az ad user list --output table` | Lists all users |

### Group Management
| Operation | Command |
|-----------|---------|
| List All Groups | `Get-AzADGroup \| Select-Object -Property *` |
| Get Group Info | `Get-AzADGroup -DisplayName "GROUP-NAME"` |
| List Group Members | `Get-AzADGroupMember -GroupObjectId "GroupID"` |
| Find User's Groups | `Get-AzADGroup \| Where-Object { ($_ \| Get-AzADGroupMember).UserPrincipalName -contains "user@domain.com" }` |
| List All Groups (CLI) | `az ad group list --output table` |
| Get Group Members (CLI) | `az ad group member list --group "GROUP-NAME" --output table` |

### Role Assignments
| Operation | Command |
|-----------|---------|
| List Tenant Roles | `Get-AzRoleAssignment -Scope "/"` |
| List Subscription Roles | `Get-AzRoleAssignment -Scope "/subscriptions/<ID>"` |
| Get User's Roles | `Get-AzRoleAssignment -ObjectId (Get-AzADUser -UserPrincipalName "user@domain.com").Id` |
| Find Resource Scope Access | `Get-AzRoleAssignment \| Where-Object { $_.Scope -eq $ResourceScope }` |
| List All Roles (CLI) | `az role assignment list --all --output table` |
| Get Role Permissions | `az role definition list --custom-role-only true --query "[?roleName=='ROLE-NAME']"` |

## Resource Enumeration

### Storage Account Enumeration
| Operation | Command |
|-----------|---------|
| List Storage Accounts | `Get-AzStorageAccount` |
| List Containers | `Get-AzStorageContainer -Context $StorageContext` |
| List Tables | `az storage table list --account-name ACCOUNT --output table --auth-mode login` |
| Get Table Data | `az storage entity query --account-name ACCOUNT --table-name TABLE --auth-mode login --output table` |

### Network Resource Enumeration
| Operation | Command |
|-----------|---------|
| List VNets | `az network vnet list --output table` |
| List Public IPs | `az network public-ip list --output table` |
| List NSGs | `az network nsg list --output table` |
| Get NSG Rules | `Get-AzNetworkSecurityRuleConfig -Name NSG-NAME` |

### App Service Enumeration
| Operation | Command |
|-----------|---------|
| List Web Apps | `Get-AzWebApp` |
| Get App Settings | `Get-AzWebApp -Name APP-NAME -ResourceGroupName RG-NAME` |
| List App Services | `az webapp list` |
| Get App Configuration | `az webapp config appsettings list --name APP-NAME --resource-group RG-NAME` |

## Container and Kubernetes Services

### AKS Operations
| Operation | Command |
|-----------|---------|
| List AKS Clusters | `Get-AzAksCluster` |
| Get Cluster Details | `Get-AzAksCluster -Name CLUSTER-NAME -ResourceGroupName RG-NAME` |
| Get AKS Credentials | `az aks get-credentials --resource-group RG-NAME --name CLUSTER-NAME` |

### Container Apps
| Operation | Command |
|-----------|---------|
| Get Container App Info | `Get-AzContainerApp -ResourceGroupName "RG-NAME" -Name "APP-NAME"` |
| Get Environment Variables | `(Get-AzContainerApp -ResourceGroupName "RG-NAME" -Name "APP-NAME").Configuration.EnvironmentVariables` |
| Get Managed Identity | `Get-AzContainerAppManagedIdentity -ResourceGroupName "RG-NAME" -Name "APP-NAME"` |
| Get Container Secrets | `Invoke-AzRestMethod -Method POST -Path "/subscriptions/{subscriptionId}/resourceGroups/RG-NAME/providers/Microsoft.App/containerApps/APP-NAME/listSecrets?api-version=2022-03-01"` |

## Key Vault Operations

### Basic Key Vault Access
| Operation | Command |
|-----------|---------|
| List Key Vaults | `Get-AzKeyVault` |
| Get Vault Info | `Get-AzKeyVault -ResourceGroupName "RG-NAME" -VaultName "VAULT-NAME"` |
| Get Access Policy | `Get-AzKeyVaultAccessPolicy -VaultName "VAULT-NAME"` |
| List Secrets | `Get-AzKeyVaultSecret -VaultName "VAULT-NAME"` |

### Secret Management
| Operation | Command |
|-----------|---------|
| Get Secret Value | `Get-AzKeyVaultSecret -VaultName "VAULT-NAME" -Name "SECRET-NAME" \| Select-Object -ExpandProperty SecretValueText` |
| Get Secret Versions | `Get-AzKeyVaultSecret -VaultName "VAULT-NAME" -Name "SECRET-NAME" -IncludeVersions` |
| Get All Secret Values | `Get-AzKeyVaultSecret -VaultName "VAULT-NAME" \| ForEach-Object { Get-AzKeyVaultSecret -VaultName "VAULT-NAME" -Name $_.Name \| Select-Object -ExpandProperty SecretValueText }` |

## Email and Exchange Operations

### Microsoft Graph Mail Access
| Operation | Command |
|-----------|---------|
| Get Graph Token | `Get-GraphTokens` |
| Get Inbox | `Get-Inbox -Tokens $Tokens` |
| Search Mailbox | `Invoke-SearchMailbox -Tokens $Tokens` |
| Get Teams Chat | `Get-TeamsChat -Tokens $Tokens` |

### Token Management for Mail Access
| Operation | Command |
|-----------|---------|
| Get MS Graph Token | `Invoke-RefreshToMSGraphToken -domain domain.com -refreshToken "TOKEN"` |
| Get Outlook Token | `Invoke-RefreshToOutlookToken` |
| Get Teams Token | `Invoke-RefreshToMSTeamsToken` |

## Common API Endpoints and Client IDs

### Important Microsoft Client IDs
| Application | Client ID | Purpose |
|-------------|-----------|---------|
| Azure PowerShell | `1950a258-227b-4e31-a9cf-717495945fc2` | PowerShell Authentication |
| Azure CLI | `04b07795-8ddb-461a-bbee-02f9e1bf7b46` | CLI Authentication |
| Azure Portal | `c44b4083-3bb0-49c1-b47d-974e53cbdf3c` | Portal Access |
| Microsoft Graph API | `00000003-0000-0000-c000-000000000000` | Graph API Access |
| Device Code Flow | `d3590ed6-52b3-4102-aeff-aad2292ab01c` | Device Code Auth |
| Exchange Online | `00000002-0000-0ff1-ce00-000000000000` | Exchange Services |
| Microsoft Teams | `1fec8e78-bce4-4aaf-ab1b-5451cc387264` | Teams Access |
| SharePoint Online | `00000003-0000-0ff1-ce00-000000000000` | SharePoint Access |

### Common API Endpoints
| Service | Endpoint |
|---------|----------|
| Graph API | `https://graph.microsoft.com` |
| Azure Management | `https://management.azure.com` |
| Key Vault | `https://vault.azure.net` |
| Storage | `https://storage.azure.com` |
| Microsoft Teams | `https://api.spaces.skype.com` |
| Exchange Online | `https://outlook.office365.com` |
| SharePoint | `https://sharepoint.com` |
| OneDrive | `https://storage.live.com` |

## Metadata and Instance Information

### Azure Instance Metadata
| Operation | Command |
|-----------|---------|
| Get Instance Metadata | `curl -H "Metadata:true" "http://169.254.169.254/metadata/instance?api-version=2021-01-01"` |
| Get Identity Token | `curl -H "Metadata:true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2021-01-01&resource=https://management.azure.com/"` |
| Get Graph Token | `curl -H "Metadata:true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2021-01-01&resource=https://graph.microsoft.com/"` |

### Resource Management
| Operation | Command |
|-----------|---------|
| Get Resource Groups | `Get-AzResourceGroup` |
| Get Resources in RG | `Get-AzResource -ResourceGroupName "RG-NAME"` |
| Get Resource by ID | `Get-AzResource -ResourceId "/subscriptions/{id}/resourceGroups/{rg}/providers/{provider}/{resource}"` |
| List Resources (CLI) | `az resource list --output table` |

## Security and Compliance

### Security Assessment
| Operation | Command |
|-----------|---------|
| Get Password Policy | `Get-MgBetaDirectorySetting` |
| Get Conditional Access | `Invoke-DumpCAPS -Tokens $Tokens` |
| Get Security Groups | `Get-SecurityGroups` |
| Get Dynamic Groups | `Get-DynamicGroups -Tokens $Tokens` |
| Get Service Principals | `az ad sp list --output table` | 
