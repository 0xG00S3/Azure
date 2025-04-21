Below is a list of custom Azure Bloodhound queries courtesy of `https://raw.githubusercontent.com/LuemmelSec/Custom-BloodHound-Queries/main/README.md` and formatted by ChatGPT. To install `Bloodhound CE` the commands are at the bottom of this document.

## 🏛️ Legacy Active Directory

### 🔍 Domain Admin to OU Mapping
```ruby
MATCH p = (n:Domain)-[:Contains*1..]->(u:User)-[:MemberOf*1..]->(g:Group)
WHERE g.name CONTAINS "DOMAIN ADMINS@"
RETURN p
```

## ☁️ Azure - General

### 👥 Return All Members of 'Global Administrator'
```ruby
MATCH p =(n)-[r:AZGlobalAdmin*1..]->(m)
RETURN p
```

### 👤 Return All Members of High Privileged Roles
```ruby
MATCH p=(n)-[:AZHasRole|AZMemberOf*1..2]->(r:AZRole)
WHERE r.displayname =~ '(?i)Global Administrator|User Administrator|Cloud Application Administrator|Authentication Policy Administrator|Exchange Administrator|Helpdesk Administrator|PRIVILEGED AUTHENTICATION ADMINISTRATOR|Domain Name Administrator|Hybrid Identity Administrator|External Identity Provider Administrator|Privileged Role Administrator|Partner Tier2 Support|Application Administrator|Directory Synchronization Accounts'
RETURN p
```

### 🔁 Synced High Privileged Role Members
```ruby
MATCH p=(n WHERE n.onpremisesyncenabled = true)-[:AZHasRole|AZMemberOf*1..2]->(r:AZRole WHERE r.displayname =~ '(?i)Global Administrator|User Administrator|Cloud Application Administrator|Authentication Policy Administrator|Exchange Administrator|Helpdesk Administrator|PRIVILEGED AUTHENTICATION ADMINISTRATOR')
RETURN p
```

### 👑 Owners of Privileged Groups (OnPrem Synced)
```ruby
MATCH p = (u:AZUser)-[r:AZOwns]->(g:AZGroup)
WHERE NOT (u)-[:AZMemberOf|AZHasRole*1..]->(:AZRole)
  AND (g)-[:AZMemberOf|AZHasRole*1..]->(:AZRole)
  AND u.onpremisesyncenabled
RETURN p
```

### 🔁 All Azure Users Synced from OnPrem
```ruby
MATCH (n:AZUser WHERE n.onpremisesyncenabled = true)
RETURN n
```

### 🔁 All Azure Groups Synced from OnPrem
```ruby
MATCH (g:AZGroup {onpremsyncenabled: True})
RETURN g
```

### 👨‍💻 Owners of Azure Applications
```ruby
MATCH p = (n)-[r:AZOwns]->(g:AZApp)
RETURN p
```

### 📦 Azure Subscriptions
```ruby
MATCH (n:AZSubscription)
RETURN n
```

### 🧑‍✈️ Controllers of Subscriptions
```ruby
MATCH p = (n)-[r:AZOwns|AZUserAccessAdministrator]->(g:AZSubscription)
RETURN p
```

### 🧑 Principals with UserAccessAdministrator Role (on Subs)
```ruby
MATCH p = (u)-[r:AZUserAccessAdministrator]->(n:AZSubscription)
RETURN p
```

### 👥 Principals with UserAccessAdministrator Role
```ruby
MATCH p = (u)-[r:AZUserAccessAdministrator]->(n)
RETURN p
```

### 👤 Users with ONLY UserAccessAdministrator (no AZRole)
```ruby
MATCH (u:AZUser)
WHERE NOT EXISTS((u)-[:AZMemberOf|AZHasRole*1..]->(:AZRole))
  AND EXISTS((u)-[:AZUserAccessAdministrator]->())
RETURN u
```

### 👤 Principals with ONLY UserAccessAdministrator (no AZRole)
```ruby
MATCH (u)
WHERE NOT EXISTS((u)-[:AZMemberOf|AZHasRole*1..]->(:AZRole))
  AND EXISTS((u)-[:AZUserAccessAdministrator]->())
RETURN u
```

## ⚔️ Azure - Attack Paths

### 🔎 Azure Users → High Value Targets
```ruby
MATCH (m:AZUser),(n {highvalue:true}),
p=shortestPath((m)-[r*1..]->(n))
WHERE NONE (r IN relationships(p) WHERE type(r)= "GetChanges")
  AND NONE (r IN relationships(p) WHERE type(r)="GetChangesAll")
  AND NOT m=n
RETURN p
```

### 🔁 Synced Users → High Value Targets
```ruby
MATCH (m:AZUser WHERE m.onpremisesyncenabled = true),(n {highvalue:true}),
p=shortestPath((m)-[r*1..]->(n))
WHERE NONE (r IN relationships(p) WHERE type(r)= "GetChanges")
  AND NONE (r IN relationships(p) WHERE type(r)="GetChangesAll")
  AND NOT m=n
RETURN p
```

### 🔎 Paths to High Privileged Roles
```ruby
MATCH (n:AZRole WHERE n.displayname =~ '(?i)Global Administrator|User Administrator|Cloud Application Administrator|Authentication Policy Administrator|Exchange Administrator|Helpdesk Administrator|PRIVILEGED AUTHENTICATION ADMINISTRATOR'),
(m),
p=shortestPath((m)-[r*1..]->(n))
WHERE NOT m=n
RETURN p
```

### 📦 Azure Apps → High Value Targets
```ruby
MATCH (m:AZApp),(n {highvalue:true}),
p=shortestPath((m)-[r*1..]->(n))
WHERE NONE (r IN relationships(p) WHERE type(r)="GetChanges")
  AND NONE (r IN relationships(p) WHERE type(r)="GetChangesAll")
  AND NOT m=n
RETURN p
```

### 🧭 Azure Users → Subscriptions
```ruby
MATCH (n:AZUser)
WITH n
MATCH p = shortestPath((n)-[r*1..]->(g:AZSubscription))
RETURN p
```

## 📘 Azure - Microsoft Graph

### 🔐 Service Principals with GrantAppRoles
```ruby
MATCH p=(n)-[r:AZMGGrantAppRoles]->(o:AZTenant)
RETURN p
```

### 📖 MS Graph App Role Assignments
```ruby
MATCH p=(m:AZServicePrincipal)-[r:AZMGAppRoleAssignment_ReadWrite_All|AZMGApplication_ReadWrite_All|AZMGDirectory_ReadWrite_All|AZMGGroupMember_ReadWrite_All|AZMGGroup_ReadWrite_All|AZMGRoleManagement_ReadWrite_Directory|AZMGServicePrincipalEndpoint_ReadWrite_All]->(n:AZServicePrincipal)
RETURN p
```

### 🧑‍✈️ Controllers of MS Graph SP
```ruby
MATCH p = (n)-[r:AZAddOwner|AZAddSecret|AZAppAdmin|AZCloudAppAdmin|AZMGAddOwner|AZMGAddSecret|AZOwns]->(g:AZServicePrincipal {appdisplayname: "Microsoft Graph"})
RETURN p
```

### 🔍 Shortest Paths to MS Graph
```ruby
MATCH (n) WHERE NOT n.displayname="Microsoft Graph"
WITH n
MATCH p = shortestPath((n)-[r*1..]->(g:AZServicePrincipal {appdisplayname: "Microsoft Graph"}))
WHERE n<>g
RETURN p
```

## 🤖 Azure - Service Principals & Managed Identities

### 🔎 All Azure Service Principals
```ruby
MATCH (sp:AZServicePrincipal)
RETURN sp
```

### 🔐 Privileged Azure Service Principals
```ruby
MATCH p=(n:AZServicePrincipal)-[:AZHasRole|AZMemberOf*1..2]->(r:AZRole)
WHERE r.displayname =~ '(?i)Global Administrator|User Administrator|Cloud Application Administrator|Authentication Policy Administrator|Exchange Administrator|Helpdesk Administrator|PRIVILEGED AUTHENTICATION ADMINISTRATOR|Domain Name Administrator|Hybrid Identity Administrator|External Identity Provider Administrator|Privileged Role Administrator|Partner Tier2 Support|Application Administrator|Directory Synchronization Accounts'
RETURN p
```

### 💾 VMs with Managed Identities
```ruby
MATCH p=(:AZVM)-[:AZManagedIdentity]->(n)
RETURN p
```

### 🤖 Managed Identity SPs
```ruby
MATCH (sp:AZServicePrincipal {serviceprincipaltype: 'ManagedIdentity'})
RETURN sp
```

### 📱 App-Based SPs
```ruby
MATCH (sp:AZServicePrincipal {serviceprincipaltype: 'Application'})
RETURN sp
```

### 🔎 Generic SP Path Enumeration
```ruby
MATCH p = (g:AZServicePrincipal)-[r]->(n)
RETURN p
```

### 🧭 Owned Users → Azure SPs
```ruby
MATCH (u:AZUser {owned: true}), (m:AZServicePrincipal)
MATCH p = shortestPath((u)-[*..]->(m))
RETURN p
```

### 🧭 Owned Users → Managed Identity SPs
```ruby
MATCH (u:AZUser {owned: true}), (m:AZServicePrincipal {serviceprincipaltype: 'ManagedIdentity'})
MATCH p = shortestPath((u)-[*..]->(m))
RETURN p
```

### 🧭 All Users → Managed Identity SPs
```ruby
MATCH (u:AZUser), (m:AZServicePrincipal {serviceprincipaltype: 'ManagedIdentity'})
MATCH p = shortestPath((u)-[*..]->(m))
RETURN p
```

### 🔒 Managed Identity SPs → KeyVault
```ruby
MATCH (m:AZServicePrincipal {serviceprincipaltype: 'ManagedIdentity'})-[*]->(kv:AZKeyVault)
WITH collect(m) AS managedIdentities
MATCH p = (n)-[r]->(kv:AZKeyVault)
WHERE n IN managedIdentities
RETURN p
```

### 🧭 VM-tied MIs → KeyVault Paths
```ruby
MATCH p1 = (:AZVM)-[:AZManagedIdentity]->(n)
WITH collect(n) AS managedIdentities
MATCH p2 = (m:AZServicePrincipal {serviceprincipaltype: 'ManagedIdentity'})-[*]->(kv:AZKeyVault)
WHERE m IN managedIdentities
RETURN p2
```

## 🔄 Azure - AADConnect

### 👥 AADConnect Related Accounts
```ruby
MATCH (u)
WHERE (u:User OR u:AZUser)
  AND (u.name =~ '(?i)^MSOL_|.*AADConnect.*' OR u.userprincipalname =~ '(?i)^sync_.*')
OPTIONAL MATCH (u)-[:HasSession]->(s:Session)
RETURN u, s
```

### 🖥️ Sessions of AADConnect Accounts
```ruby
MATCH p=(m:Computer)-[:HasSession]->(n)
WHERE (n:User OR n:AZUser)
  AND ((n.name =~ '(?i)^MSOL_|.*AADConnect.*') OR (n.userPrincipalName =~ '(?i)^sync_.*'))
RETURN p
```

### 📦 Find AADConnect Servers from SYNC_ UPN
```ruby
MATCH (n:AZUser)
WHERE n.name =~ '(?i)^SYNC_(.*?)_(.*?)@.*'
WITH n, split(n.name, '_')[1] AS computerNamePattern
MATCH (c:Computer)
WHERE c.name CONTAINS computerNamePattern
RETURN c
```

### 🧭 Owned Users → AADConnect Servers
```ruby
MATCH (n:AZUser)
WHERE n.name =~ '(?i)^SYNC_(.*?)_(.*?)@.*'
WITH n, split(n.name, '_')[1] AS computerNamePattern
MATCH (c:Computer)
WHERE c.name CONTAINS computerNamePattern
WITH collect(c) AS computers
MATCH p = shortestPath((u:User)-[*]-(c:Computer))
WHERE c IN computers AND length(p) > 0 AND u.owned = true
RETURN u, p
```

---

## Install Docker and Docker Compose
```ruby
# Update your system
sudo apt update && sudo apt upgrade
# Install Docker
sudo apt install docker.io
# Enable Docker
sudo systemctl enable docker --now
# Install Docker Compose
sudo apt install docker-compose
```

## Setup Bloodhound
```ruby
# Once Docker and Docker Compose are installed, download and launch BloodHound CE
curl -L https://ghst.ly/getbhce -o /opt/bloodhound-CE/bloodhound.yml
sudo docker-compose -f bloodhound.yml up
# The temporary admin password will output during the above docker command. Make note of this.
```

- Bloodhound can be accessed via `http://localhost:8080/ui/login` as the `admin` user and the previously noted temp passsword.
