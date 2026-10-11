# Identity Design

## 1. Purpose

The purpose of this design is to define how identities and access will be managed in the Azure environment for V2.

The project follows the principle of least privilege, where users receive only the permissions required for their responsibilities.

---

## 2. Identity Architecture

The V2 environment uses Microsoft Entra ID as the identity layer.

Users are organized into groups based on their responsibilities. Azure RBAC is then used to control access to Azure resources.

```text
                    Microsoft Entra ID
                           |
                    Users + Groups
                           |
                           v
                       Azure RBAC
                           |
                    Least Privilege
                           |
                           v
                    Azure Resources
```
## 3. User Groups

The project will use three primary security groups:

Cloud-Developers

Represents users responsible for application and development activities.

Expected access:

Manage resources required for development
Access required Azure resources within their assigned scope
No unnecessary administrative privileges
Security-Team

Represents users responsible for reviewing and validating the security of the Azure environment.

Expected access:

Inspect Azure resources and security configuration
Review relevant configurations
No unnecessary infrastructure modification privileges
Cloud-Administrators

Represents users responsible for administering the Azure infrastructure.

Expected access:

Manage Azure infrastructure
Perform administrative operations required by their responsibilities
Access will still be assigned according to the required scope

## 4. Identity-to-Access Model

The project follows this model:
```
User
  |
  v
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
Permissions will be assigned to groups wherever practical rather than directly to individual users.


## 5. Least Privilege

The project will avoid granting excessive permissions.

Users will receive only the level of access required for their responsibilities.

The project will specifically avoid using highly privileged roles simply for convenience.

Each RBAC assignment will have:

A defined user group
A defined role
A defined resource scope
A documented reason

## 6. Security Objectives

The identity design aims to:

Centralize identity management using Microsoft Entra ID.
Organize users using security groups.
Implement role-based access control.
Apply the principle of least privilege.
Separate development, security, and administrative responsibilities.
Minimize direct user-to-resource role assignments.
Test that authorized operations succeed.
Test that unauthorized operations are denied.
Document all access decisions.

## 7. Scope

The identity design covers:

Microsoft Entra ID users
Microsoft Entra ID security groups
Azure RBAC
Role assignments
Resource scopes
Permission validation

Advanced paid identity features are intentionally outside the scope of this version.

```
### Don't create the users or groups yet.

For now, we're only **designing** the identity model.

Once this file is saved, the next step will be `rbac-design.md`, where we'll decide **exactly which Azure roles each group gets and at what scope**.

That part matters considerably more than it looks, because handing out `Owner` like free candy would make the entire "least privilege" project rather embarrassing.
```
