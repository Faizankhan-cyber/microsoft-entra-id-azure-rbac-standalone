# RBAC Design

## 1. Purpose

This document defines the Azure Role-Based Access Control (RBAC) model for the V2 environment.

The objective is to provide users with the minimum permissions required for their responsibilities while maintaining separation between development, security, and administrative functions.

---

## 2. RBAC Model

Access will follow this structure:

```text
Microsoft Entra ID
        |
        v
Security Group
        |
        v
Azure RBAC Role
        |
        v
Resource Scope
```
RBAC assignments will primarily be made to groups rather than individual users.


## 3. Access Groups

The project uses three groups:

Group	Responsibility
Cloud-Developers	Development and application-related operations
Security-Team	Security and configuration review
Cloud-Administrators	Azure infrastructure administration


## 4. Role Assignment Strategy
Cloud-Developers

The developer group will receive only the permissions required to perform development-related operations.

The group will not receive highly privileged administrative roles unless a specific project requirement demonstrates that such access is necessary.

Security-Team

The security group will primarily receive permissions required to inspect resources and evaluate security configuration.

The group should not receive broad infrastructure-management permissions when read or security-specific access is sufficient.

Cloud-Administrators

The administrator group will receive the permissions required to manage the Azure infrastructure.

Administrative access will be assigned at the narrowest practical scope.


## 5. Scope Strategy

RBAC assignments will use the smallest practical scope.

The preferred hierarchy is:
```
Subscription
    |
    └── Resource Group
            |
            ├── VNet
            ├── NSG
            ├── Public IP
            └── VM
```
When access to an individual resource is sufficient, resource-level scope should be preferred over broader subscription-level access.


## 6. Separation of Responsibilities

The project separates responsibilities between the three groups.
```
Cloud-Developers
        |
        └── Development operations

Security-Team
        |
        └── Security review

Cloud-Administrators
        |
        └── Infrastructure administration
```
This separation reduces unnecessary privilege and demonstrates role-based access control.


## 7. Privilege Principles

The RBAC design follows these principles:

Grant only required permissions.
Prefer group-based assignments.
Avoid unnecessary Owner assignments.
Avoid subscription-wide permissions when narrower scope is sufficient.
Separate development, security, and administration responsibilities.
Document the reason for each role assignment.
Validate permissions after deployment.


## 8. Validation

After RBAC is implemented, the project will validate both:

Authorized access

Users should be able to perform operations required by their assigned role.

Unauthorized access

Users should be prevented from performing operations outside their assigned responsibilities.

The results of these tests will be documented as evidence in the project.


## 9. Role Selection

The exact Azure built-in roles and scopes will be finalized in the permission matrix before implementation.

No RBAC role will be assigned solely for convenience.


### Why we're doing this before Azure

We are deliberately **not assigning roles yet**.

First:

```text
Identity Design
      ↓
RBAC Design
      ↓
Permission Matrix
      ↓
Azure Implementation
``` 
