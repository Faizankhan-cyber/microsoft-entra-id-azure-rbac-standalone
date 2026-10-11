# 🔐 V2 - Identity & Access Security

## 📌 Overview

V2 of the Azure Enterprise Infrastructure project focuses on securing Azure infrastructure through identity management, role-based access control, least-privilege access, Infrastructure as Code, and automated security validation.

V2 builds on the Secure Linux Web Server from V1 by introducing Microsoft Entra ID, Azure RBAC, Terraform, and Checkov.

The infrastructure was intentionally kept small to provide a realistic security lab while controlling Azure student-credit usage.

---

## 🎯 Objectives

The main objectives of V2 are:

- Implement identity-based access to Azure resources
- Apply the principle of least privilege
- Separate administrative, development, and security responsibilities
- Deploy Azure infrastructure using Terraform
- Restrict administrative network access
- Disable password-based SSH authentication
- Validate infrastructure security using Checkov
- Test and document access-control behavior

---

## 🏗️ Architecture

The V2 architecture consists of three main layers:

```text
Microsoft Entra ID
        |
        v
Users & Groups
        |
        v
Azure RBAC
        |
        +-----------------------+
        |           |           |
        v           v           v
   Developers   Security    Administrators
        |           |           |
        +-----------+-----------+
                    |
                    v
            V2 Resource Group
                    |
        +-----------+-----------+
        |           |           |
       VNet       NSG        Linux VM
        |
      Subnet
        |
    Public IP
```

The identity layer controls who receives access.

Azure RBAC determines what each identity is allowed to do.

The network layer restricts administrative access to the Linux VM.

---

## 👤 Identity & Access Model

Microsoft Entra ID is used to organize users into security groups.

### 👥 Groups

| Entra ID Group | Purpose |
|---|---|
| `Cloud-Developers` | Manage the project VM while being restricted from RBAC administration |
| `Security-Team` | Monitor resources and security configuration without modifying infrastructure |
| `Cloud-Administrators` | Manage the V2 Azure infrastructure |

### 🔑 RBAC Assignments

| Group | Azure RBAC Role | Scope |
|---|---|---|
| `Cloud-Developers` | Virtual Machine Contributor | V2 Resource Group |
| `Cloud-Developers` | Reader | V2 Resource Group |
| `Security-Team` | Security Reader | V2 Resource Group |
| `Security-Team` | Reader | V2 Resource Group |
| `Cloud-Administrators` | Contributor | V2 Resource Group |

Privileged roles such as `Owner`, `User Access Administrator`, and `Role Based Access Control Administrator` were intentionally not assigned.

---

## 🛡️ Least Privilege

V2 follows the principle of least privilege.

Each group receives only the permissions required for its intended responsibility.

For example:

- Developers can manage the project VM but cannot modify RBAC assignments.
- The Security Team can inspect resources and security configuration but cannot start or stop the VM.
- Cloud Administrators can manage infrastructure but cannot modify role assignments because the `Contributor` role does not provide RBAC administration permissions.

This provides separation between infrastructure management, development, and security monitoring.

---

## ☁️ Azure Infrastructure

The V2 environment contains:

- Azure Resource Group
- Virtual Network
- Subnet
- Network Security Group
- Public IP
- Network Interface
- Ubuntu Linux Virtual Machine

### 🌐 Network Configuration

The V2 virtual network uses:

```text
VNet: 10.20.0.0/16
Subnet: 10.20.1.0/24
```

SSH access is restricted to the administrator's public IP address.

The SSH NSG rule allows:

```text
Protocol: TCP
Port: 22
Source: Administrator public IP /32
Direction: Inbound
Access: Allow
```

HTTP port 80 remains defined in the NSG for the lab environment, although no web server is deployed on the V2 VM.

---

## 🔐 SSH Security

The Linux VM uses SSH key authentication.

Password-based SSH authentication is disabled.

Validation was performed on the VM using:

```bash
sudo sshd -T | grep -i passwordauthentication
```

Result:

```text
passwordauthentication no
```

SSH connectivity was successfully tested from the authorized administrator network.

---

## 🧱 Infrastructure as Code

Terraform is used to define and deploy the Azure infrastructure.

### Terraform Components

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

### 🔄 Terraform Workflow

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
Azure Infrastructure
```

Terraform was used to create the Azure infrastructure instead of manually creating the resources through the Azure portal.

---

## 🔎 Security Automation

Checkov was used to scan the Terraform configuration for security issues.

The initial scan identified three findings.

### ✅ Remediated Finding

```text
CKV2_AZURE_31
Ensure VNET subnet is configured with a Network Security Group
```

The subnet was explicitly associated with the Network Security Group.

The final scan confirmed:

```text
CKV2_AZURE_31
PASSED
```

### ⚠️ Remaining Findings

Two findings remained and were reviewed as intentional/contextual findings:

```text
CKV_AZURE_50
Ensure virtual Machine Extensions are not Installed

CKV_AZURE_119
Ensure that Network Interfaces don't use public IPs
```

The public IP is currently used for direct administrative SSH access in this lab environment.

The Checkov results and reasoning are documented in:

```text
docs/Security/checkov-results.md
```

---

## 🧪 Validation & Testing

The V2 environment was tested across infrastructure, networking, identity, access control, and host security.

### Terraform Validation

```text
terraform validate
```

Result:

```text
Success
```

Terraform drift validation was also performed:

```text
terraform plan
```

Result:

```text
No changes
```

This confirmed that the deployed infrastructure matched the Terraform configuration.

### 🖥️ VM Validation

The Azure VM was verified as:

```text
PowerState: Running
VMAgent: Ready
```

### 🔑 SSH Validation

SSH connectivity was successfully established using:

```bash
ssh azureadmin@<public-ip>
```

### 👥 RBAC Validation

Role assignments were verified for:

- `Cloud-Developers`
- `Security-Team`
- `Cloud-Administrators`

Access tests confirmed the expected permission boundaries.

### 🛡️ Security Validation

The following controls were validated:

- SSH restricted by source IP
- Password authentication disabled
- RBAC assignments applied at resource-group scope
- Least-privilege access model
- NSG association with the subnet
- Terraform configuration consistency
- Checkov security scanning

---

## 📸 Evidence

Supporting evidence is stored in the project documentation.

```text
docs/
├── architecture/
├── identity/
├── screenshots/
└── Security/
```

The screenshots document:

- Microsoft Entra users
- Microsoft Entra groups
- Group membership
- Azure RBAC assignments
- Security Team access
- Developer access
- Administrator access
- RBAC permission boundaries
- Azure V2 resource deployment

---

## 📂 Project Structure

```text
V2-Identity-Access-Security/
│
├── docs/
│   ├── architecture/
│   │   ├── v2-architecture.md
│   │   └── v2-architecture.png
│   │
│   ├── identity/
│   │   ├── identity-design.md
│   │   ├── rbac-design.md
│   │   └── permission-matrix.md
│   │
│   ├── screenshots/
│   └── Security/
│       └── checkov-results.md
│
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
│
├── Portfolio/
└── scripts/
```

---

## 🔄 V1 → V2 Evolution

### 🖥️ V1 - Secure Linux Web Server

V1 established the basic Azure infrastructure:

- Virtual Network
- Subnet
- NSG
- Linux VM
- SSH access
- Nginx web server

### 🔐 V2 - Identity & Access Security

V2 extends the infrastructure with:

- Microsoft Entra ID
- Entra ID groups
- Azure RBAC
- Least-privilege access
- Terraform Infrastructure as Code
- Checkov security scanning
- Security validation and access testing

The primary change from V1 to V2 is the introduction of identity-based access control and repeatable infrastructure deployment.

---

## ⚠️ Limitations & Security Trade-offs

This project is a controlled security lab rather than a production enterprise environment.

Current limitations include:

- The Linux VM uses a public IP for direct administrative access.
- No Azure Bastion or private-only administration path is deployed.
- No web server is deployed in V2.
- VM extensions are not used.
- The environment is intentionally small to limit Azure student-credit consumption.

These limitations provide clear areas for improvement in future versions.

---

## 🚀 Future Improvements

Future versions can introduce:

- Stronger network segmentation
- Private VM access
- More advanced Azure security controls
- Security monitoring
- Improved administrative access architecture
- Additional cloud security automation
- Enterprise-scale architecture patterns

---

