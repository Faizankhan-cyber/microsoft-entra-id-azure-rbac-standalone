# Microsoft Entra ID and Azure RBAC

**Repository:** https://github.com/Faizankhan-cyber/microsoft-entra-id-azure-rbac-standalone

**Related project:** [Secure Linux Web Server on Azure](https://github.com/Faizankhan-cyber/secure-linux-web-server-azure)


## Overview

This standalone SC-900 learning project demonstrates identity and access management for Azure infrastructure using Microsoft Entra ID, Azure role-based access control (RBAC), Terraform, and Checkov.

Test users are organized into security groups for development, security monitoring, and infrastructure administration. Terraform defines the Azure infrastructure, and Checkov scans its configuration for potential security issues.

This lab was built after completing the Microsoft SC-900 exam to apply security, compliance, and identity concepts in practice.

The Azure resources used for validation were deleted after testing to avoid ongoing charges. This repository retains the Terraform configuration, documentation, security findings, and screenshots as evidence of the implementation.

> **Project structure:** This project was previously part of a combined Azure Enterprise Infrastructure repository that also contained a Secure Linux Web Server project. The projects now have separate repositories and documentation. Some resource names, folder names, and historical screenshots may retain the original V1/V2 labels; these labels do not mean the projects are still combined.

## Project Scope

The lab focuses on:

- Microsoft Entra ID users and security groups
- Azure RBAC and least-privilege access
- Separation of development, security-monitoring, and infrastructure-administration responsibilities
- Terraform-defined Azure infrastructure
- Restricted administrative network access and SSH key authentication
- Checkov scanning and access-control validation

It is separate from the Secure Linux Web Server project, which focuses on foundational Azure infrastructure concepts relevant to AZ-900. A future Azure Enterprise Infrastructure project may build on both learning projects, but it will have its own repository, architecture, and implementation history.

## Architecture

The lab has three logical layers:

1. **Identity:** Microsoft Entra ID users and security groups
2. **Authorization:** Azure RBAC role assignments that control access at the assigned scope
3. **Infrastructure and networking:** An Azure resource group containing a virtual network, subnet, network security group, public IP, network interface, and Linux virtual machine

```text
Microsoft Entra ID
        |
        v
Users and Security Groups
        |
        v
Azure RBAC Role Assignments
        |
        +--------------------------+
        |             |            |
        v             v            v
 Cloud-Developers  Security-Team  Cloud-Administrators
        |             |            |
        +-------------+------------+
                      |
                      v
             Azure Resource Group
                      |
        Virtual Network, Subnet, NSG,
        Public IP, Network Interface,
               and Linux VM
```

Microsoft Entra ID organizes identities, Azure RBAC controls their permissions at the assigned scope, and network security rules restrict access to the virtual machine.

## Identity and Access Model

Microsoft Entra ID was used to organize test users into security groups.

### Security Groups

| Group | Responsibility |
|---|---|
| `Cloud-Developers` | Manage the lab virtual machine without administering RBAC assignments |
| `Security-Team` | Read resource and security configuration without managing infrastructure |
| `Cloud-Administrators` | Manage lab infrastructure; the `Contributor` role alone does not grant RBAC administration permissions |

### RBAC Assignments

The following roles were assigned at the lab resource-group scope.

| Group | Azure RBAC role | Scope |
|---|---|---|
| `Cloud-Developers` | `Virtual Machine Contributor` | Lab resource group |
| `Cloud-Developers` | `Reader` | Lab resource group |
| `Security-Team` | `Security Reader` | Lab resource group |
| `Security-Team` | `Reader` | Lab resource group |
| `Cloud-Administrators` | `Contributor` | Lab resource group |

The developer roles apply to eligible virtual-machine resources within the assigned resource-group scope, rather than to only one individual VM.

The groups were not assigned privileged roles such as `Owner`, `User Access Administrator`, or `Role Based Access Control Administrator`.

## Azure Infrastructure and Network Configuration

Terraform defines the following lab infrastructure:

- Azure resource group
- Virtual network
- Subnet
- Network security group (NSG)
- Public IP address
- Network interface
- Ubuntu Linux virtual machine

```text
VNet:    10.20.0.0/16
Subnet:  10.20.1.0/24
```

SSH access was restricted to the administrator's public IP address using a `/32` source range. The inbound SSH rule used TCP port 22.

HTTP port 80 was also defined in the NSG, but **no web server was deployed on the VM**.

## SSH Security

The Linux VM used SSH key authentication, with password-based SSH authentication disabled. The configuration was checked on the VM using:

```bash
sudo sshd -T | grep -i passwordauthentication
```

Observed result:

```text
passwordauthentication no
```

SSH connectivity was successfully tested from the authorized administrator network during validation.

## Infrastructure as Code

Terraform was used to define and deploy the Azure infrastructure rather than creating each resource manually through the Azure portal.

### Terraform Files

```text
infrastructure/
└── terraform/
    ├── main.tf
    ├── providers.tf
    ├── versions.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars.example
    └── .terraform.lock.hcl
```

### Terraform Workflow

```text
Terraform Configuration
        |
        v
terraform fmt
        |
        v
terraform validate
        |
        v
terraform plan
        |
        v
terraform apply
        |
        v
Azure Resources
```

The infrastructure was validated during deployment. The resources have since been removed, so running Terraform again may create billable Azure resources.

## Security Scanning with Checkov

Checkov was used to scan the Terraform configuration for potential security issues.

### Remediated Finding

The initial scan identified a missing subnet-to-NSG association:

```text
CKV2_AZURE_31
Ensure VNET subnet is configured with a Network Security Group
```

The subnet was explicitly associated with the NSG, and the final scan reported this check as passed.

### Remaining Findings

Two findings remained in the final scan and were documented for review:

```text
CKV_AZURE_50
Ensure virtual Machine Extensions are not Installed

CKV_AZURE_119
Ensure that Network Interfaces don't use public IPs
```

The public IP was used for direct administrative SSH access in this lab. These findings were documented as remaining risks or trade-offs in the lab context, not represented as fixed.

Details and reasoning are recorded in `docs/Security/checkov-results.md`.

## Validation and Testing

Validation was performed while the Azure environment was deployed.

### Terraform

Commands used:

```bash
terraform fmt -check
terraform validate
terraform plan
```

The recorded validation showed successful Terraform validation and a plan with no changes at the time of the check.

### Virtual Machine and SSH

During testing, the VM was verified as running and its Azure VM agent was ready. SSH access was established using key-based authentication:

```bash
ssh azureadmin@<public-ip>
```

Replace `<public-ip>` with the VM's actual public IP when the environment is deployed. The historical public IP should not be assumed to remain available.

### RBAC and Security Controls

The role assignments and access boundaries for `Cloud-Developers`, `Security-Team`, and `Cloud-Administrators` were tested:

- **Cloud Developers:** Could view and manage the lab VM but could not modify RBAC role assignments.
- **Security Team:** Could inspect resources and security configuration but could not start or stop the VM.
- **Cloud Administrators:** Could manage infrastructure, but `Contributor` did not grant permission to assign RBAC roles.

The following controls were checked:

- SSH restricted by source IP
- Password-based SSH authentication disabled
- RBAC assignments applied at resource-group scope
- Intended least-privilege boundaries tested
- NSG associated with the subnet
- Terraform configuration validated
- Checkov scan performed and findings documented

These tests demonstrate separation of responsibilities in this lab; they do not establish that the configuration is suitable for every production environment.

## Evidence and Documentation

Project evidence is stored in `docs/`, including architecture documentation, identity and RBAC design, permission matrices, security scan results, and screenshots.

The screenshots document:

- Microsoft Entra users and groups
- Group membership
- Azure RBAC assignments
- Security-team read-only access
- Developer access
- Administrator access
- RBAC permission boundaries
- The lab resource group and Azure resources during deployment

Some screenshot filenames and resource names may retain the original V1/V2 naming. See the project-structure notice above.

## Repository Structure

```text
.
├── README.md
├── docs/
│   ├── architecture/
│   │   ├── v2-architecture.md
│   │   └── v2-architecture.png
│   ├── identity/
│   │   ├── identity-design.md
│   │   ├── rbac-design.md
│   │   └── permission-matrix.md
│   ├── screenshots/
│   └── Security/
│       └── checkov-results.md
├── infrastructure/
│   ├── modules/
│   └── terraform/
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── terraform.tfvars.example
│       ├── variables.tf
│       ├── versions.tf
│       └── .terraform.lock.hcl
├── scripts/
└── tests/
```

Folder names shown in historical screenshots or documentation may differ slightly from the current repository layout.

## Limitations and Security Trade-offs

This was a controlled learning lab, not a production-ready enterprise deployment.

- The VM used a public IP for direct administrative access.
- Azure Bastion or a private-only administration path was not deployed.
- No web server was deployed on the lab VM.
- VM extensions were not used.
- The infrastructure was kept small to control Azure student-credit usage.
- RBAC assignments were made at resource-group scope, which is broader than assigning permissions to a single VM.
- Two Checkov findings remained and were documented rather than marked as remediated.

Potential areas for future improvement include private VM access or Azure Bastion, tighter resource-level RBAC scopes where practical, additional Azure security controls, security monitoring and alerting, an improved administrative access architecture, expanded automated security checks, and enterprise-scale architecture patterns.

## Skills Demonstrated

- Microsoft Entra ID users and security groups
- Azure role-based access control (RBAC)
- Least-privilege design and permission testing
- Azure networking and network security groups
- Linux VM administration and SSH hardening
- Terraform infrastructure as code
- Checkov infrastructure security scanning
- Technical documentation and security trade-off analysis

## Project Status

**Completed and documented.** The Azure infrastructure was deployed and validated. Testing covered identity configuration, group-based RBAC assignments, permission boundaries, SSH key-based access, Terraform validation, and Checkov security scanning.

The infrastructure resources were deleted after validation to avoid unnecessary cloud charges. Documentation, configuration files, architecture diagrams, and screenshots remain in this repository. The Azure infrastructure is not currently running; resources would need to be redeployed to repeat infrastructure validation tests.

## Author

**Faizan Khan Khaleel**  
BCA | Cloud Architecture & Cybersecurity

Areas explored through this project include cloud computing, cybersecurity fundamentals, Microsoft Entra ID and identity management, Azure RBAC, Terraform, and Checkov.

## License

No license is currently specified in this repository. Until a license is added, do not assume the source is licensed for reuse.
