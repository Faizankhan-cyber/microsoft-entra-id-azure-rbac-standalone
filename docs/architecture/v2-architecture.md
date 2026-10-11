# V2 Architecture

## 1. Overview

V2 extends the Azure infrastructure concepts demonstrated in V1 by introducing centralized identity management, role-based access control, least-privilege access, and Infrastructure as Code.

The environment will use Microsoft Entra ID for identity management and Azure RBAC for authorization.

The Azure infrastructure will be deployed and managed using Terraform.

---

## 2. Architecture Objectives

The architecture is designed to:

1. Centralize identity management using Microsoft Entra ID.
2. Separate users according to their responsibilities.
3. Apply least-privilege access using Azure RBAC.
4. Deploy Azure infrastructure consistently using Terraform.
5. Validate infrastructure security before deployment.
6. Test authorized and unauthorized access.
7. Keep the environment small enough for Azure for Students resources.

---

## 3. High-Level Architecture

```text
                         Microsoft Entra ID
                                |
                         Users + Groups
                                |
                                v
                           Azure RBAC
                                |
                       Least-Privilege Access
                                |
                                v
                       V2 Resource Group
                                |
             +------------------+------------------+
             |                  |                  |
             v                  v                  v
            VNet               NSG           Public IP
             |
           Subnet
             |
             v
        Linux Virtual Machine
```

## 4. Identity Layer

Microsoft Entra ID provides the identity layer for the environment.

The project uses three security groups:
```
Microsoft Entra ID
       |
       +-- Cloud-Developers
       |
       +-- Security-Team
       |
       +-- Cloud-Administrators
```
Users will be assigned to groups according to their responsibilities.

Permissions will primarily be assigned to groups rather than individual users.

## 5. Authorization Layer

Azure RBAC provides authorization for Azure resources.

The planned model is:
```
Cloud-Developers
        |
        +-- Virtual Machine Contributor
        +-- Reader
        |
        v
   V2 Resource Group


Security-Team
        |
        +-- Security Reader
        |
        v
   V2 Resource Group


Cloud-Administrators
        |
        +-- Contributor
        |
        v
   V2 Resource Group
```
The exact permissions and scope are documented in:

docs/identity/permission-matrix.md

## 6. Azure Infrastructure Layer

The V2 environment will contain a dedicated resource group with the following core resources:
```
V2 Resource Group
│
├── Virtual Network
│   └── Subnet
│
├── Network Security Group
│
├── Public IP
│
└── Linux Virtual Machine
```
The infrastructure is intentionally kept small to minimize Azure resource consumption while still demonstrating identity, access control, networking, and infrastructure management.

## 7. Infrastructure as Code

Terraform will be used to define and deploy the Azure infrastructure.

The intended workflow is:
```
Terraform Configuration
          |
          v
    Terraform Plan
          |
          v
    Security Scan
          |
          v
    Azure Deployment
```
Terraform configuration will be stored in:

infrastructure/terraform/

Reusable Terraform components will be stored under:

infrastructure/modules/

Modules will only be introduced where they provide meaningful reuse or separation.

## 8. Security Validation

Security validation will be performed before and after deployment.

Pre-deployment

Terraform configuration will be validated and scanned for common infrastructure security issues.

Post-deployment

RBAC permissions will be tested to verify:

Authorized operations are allowed.
Unauthorized operations are denied.
Users do not receive unnecessary administrative access.

Evidence from these tests will be documented in:

docs/screenshots/


## 9. Deployment and Security Workflow

The intended engineering workflow is:
```
              GitHub
                 |
                 v
             Terraform
                 |
                 v
          Configuration Check
                 |
                 v
          Security Scan
                 |
                 v
          Terraform Plan
                 |
                 v
          Azure Deployment
                 |
                 v
        Identity + RBAC Setup
                 |
                 v
          Security Testing
                 |
                 v
          Evidence + Reports
  ```


## 10. V1 to V2 Evolution

V1 focused on deploying and securing a Linux web server on Azure.

V2 builds on that foundation by introducing identity and access management.
```
V1
Infrastructure
    +
Linux Server
    +
Networking
    +
Basic Security

             ↓

V2
Infrastructure
    +
Identity
    +
Azure RBAC
    +
Least Privilege
    +
Terraform
    +
Security Validation
```
V2 is therefore a new deployment rather than a modification of the original V1 environment.

## 11. Security Boundaries

The project intentionally excludes advanced or paid Azure services that are not required for demonstrating the core identity and access-control objectives.

The design focuses on:

Microsoft Entra ID
Azure RBAC
Least privilege
Azure networking
Linux infrastructure
Terraform
Security validation


## 12. Architecture Status
 Identity architecture defined - Completed
 RBAC model defined - Completed
 Resource structure defined - Completed
 Terraform workflow defined - Completed
 Architecture diagram created
 Azure infrastructure deployed
 RBAC implemented
 Security validation completed
