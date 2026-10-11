# Permission Matrix

## 1. Purpose

This document defines the planned access permissions for the V2 Azure environment.

The matrix maps each Entra ID security group to the Azure RBAC role and resource scope required for its responsibilities.

The design follows the principle of least privilege.

---

## 2. Resource Scope

The V2 environment will use a dedicated resource group:

```text
V2 Resource Group
│
├── Virtual Network
├── Subnet
├── Network Security Group
├── Public IP
└── Linux Virtual Machine
```
The primary RBAC scope will therefore be the V2 resource group unless a narrower resource-level scope is required.


## 3. Planned Permission Matrix

| Entra ID Group       | RBAC Role                            | Scope             | Purpose                                                        |
| -------------------- | ------------------------------------ | ----------------- | -------------------------------------------------------------- |
| Cloud-Developers     | Virtual Machine Contributor + Reader | V2 Resource Group | Manage the project VM and inspect related Azure resources      |
| Security-Team        | Security Reader + Reader             | V2 Resource Group | Review security configuration and security-related information |
| Cloud-Administrators | Contributor                          | V2 Resource Group | Manage the V2 Azure infrastructure                             |


The exact built-in Azure RBAC roles will be selected and justified before implementation.

## 4. Access Requirements

#### Cloud-Developers

Required capabilities:

Work with resources required for development
Inspect relevant resource configuration
Perform necessary VM management operations
No unnecessary identity-management privileges
No unnecessary subscription-level administrative access

#### Security-Team

Required capabilities:

Inspect Azure resources
Review security configuration
Validate network and infrastructure security
Perform security-related checks
No unnecessary infrastructure-management privileges

#### Cloud-Administrators

Required capabilities:

Manage the V2 infrastructure
Create and modify required Azure resources
Troubleshoot infrastructure
Perform administrative operations required by the project

## 5. Privilege Boundaries

The following boundaries will be maintained:
| Group                | Should NOT automatically receive            |
| -------------------- | ------------------------------------------- |
| Cloud-Developers     | Tenant-wide administrative access           |
| Security-Team        | Broad infrastructure modification access    |
| Cloud-Administrators | Unnecessary tenant-wide identity privileges |


## 6. Assignment Principles

RBAC assignments will follow these rules:

Prefer group-based assignments over individual assignments.
Use the narrowest practical scope.
Avoid Owner unless explicitly required.
Avoid subscription-wide access when resource-group or resource-level access is sufficient.
Use built-in Azure roles where they satisfy the requirement.
Document the reason for each role assignment.
Validate both allowed and denied operations.


## 7. Final Role Selection

#### Cloud-Developers

Roles:

Virtual Machine Contributor
Reader

Scope:

V2 Resource Group

The Virtual Machine Contributor role provides VM management capabilities without granting Azure RBAC role-assignment permissions. Reader provides read-only visibility into the remaining resources required for development and troubleshooting.

#### Security-Team

Role:

Security Reader

Scope:

V2 Resource Group

Security Reader provides security-focused visibility without granting general infrastructure management permissions.

#### Cloud-Administrators

Role:

Contributor

Scope:

V2 Resource Group

Contributor provides the infrastructure-management capabilities required for the project without automatically granting Azure RBAC role-assignment permissions.


## 8. Privileged Role Decision

The following roles are intentionally not assigned to the project groups:

Owner
User Access Administrator
Role Based Access Control Administrator

These roles are excluded because the project does not require the groups to manage Azure RBAC assignments themselves.


## 9. Implementation Status

| Component | Status | Details |
|---|---|---|
| Entra ID users | ✅ Complete | Created test identities for Developer, Security, Cloud Administrator, and Lab Administrator roles |
| Entra ID groups | ✅ Complete | Created Cloud-Developers, Security-Team, and Cloud-Administrators security groups |
| Group membership | ✅ Complete | Assigned each test identity to its corresponding security group |
| Azure RBAC assignments | ✅ Complete | Assigned Reader, Security Reader, Virtual Machine Contributor, and Contributor roles at resource-group scope |
| Least-privilege design | ✅ Complete | Privileged roles such as Owner and User Access Administrator were intentionally excluded |
| Cloud-Developers access testing | ✅ Passed | Can view resources and manage the VM, but cannot modify RBAC assignments |
| Security-Team access testing | ✅ Passed | Can view resources and security information, but cannot manage the VM or modify RBAC assignments |
| Cloud-Administrators access testing | ✅ Passed | Can manage Azure resources, but cannot modify RBAC assignments |
| Access control validation | ✅ Complete | Allowed and denied actions were tested against the intended permission model |
| Evidence screenshots | ✅ Complete | Screenshots will be captured and added to the project evidence directory |


 ## Access Testing Results

| Identity Group | Test | Expected Result | Actual Result | Status |
|---|---|---|---|---|
| Cloud-Developers | View resources | Allowed | Allowed | Passed |
| Cloud-Developers | Start/stop VM | Allowed | Allowed | Passed |
| Cloud-Developers | Modify RBAC role assignments | Denied | Denied | Passed |
| Security-Team | View resources | Allowed | Allowed | Passed |
| Security-Team | Start/stop VM | Denied | Denied | Passed |
| Security-Team | Modify RBAC role assignments | Denied | Denied | Passed |
| Cloud-Administrators | View resources | Allowed | Allowed | Passed |
| Cloud-Administrators | Start/stop VM | Allowed | Allowed | Passed |
| Cloud-Administrators | Modify RBAC role assignments | Denied | Denied | Passed |
