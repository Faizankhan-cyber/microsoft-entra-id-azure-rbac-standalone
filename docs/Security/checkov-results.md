# Checkov Security Scan Results

## Overview

Checkov was used to scan the Terraform infrastructure configuration for Azure security misconfigurations.

Checkov version:

- 3.3.22

Scan command:

```powershell
checkov -d . --compact
```

The scan was performed from:

V2-Identity-Access-Security/infrastructure/terraform


### Initial Scan

The initial Checkov scan reported:
Result	Count
Passed checks	12
Failed checks	3
Skipped checks	0


The three findings were:
1. CKV2_AZURE_31
2. CKV_AZURE_50
3. CKV_AZURE_119


## Finding 1: CKV2_AZURE_31
Check: Ensure VNET subnet is configured with a Network Security Group (NSG)

#### Initial Result
Failed.
The subnet had an NSG protecting the VM through the network interface, but Checkov specifically required the subnet itself to have an NSG association.

#### Remediation
Added a Terraform subnet-level NSG association:

```
resource "azurerm_subnet_network_security_group_association" "v2" {
  subnet_id                 = azurerm_subnet.v2.id
  network_security_group_id = azurerm_network_security_group.v2.id
}
```

Terraform plan showed:
Plan: 1 to add, 0 to change, 0 to destroy.

The change was then applied successfully:
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

#### Final Result
PASSED

This finding was successfully remediated.

## Finding 2: CKV_AZURE_50
Check: Ensure Virtual Machine Extensions are not Installed

#### Result
Failed.
The finding points to the azurerm_linux_virtual_machine.v2 resource.
However, the Terraform configuration does not define an Azure VM extension resource. The VM configuration contains the Linux VM, SSH key authentication, managed OS disk and Ubuntu image, but no azurerm_virtual_machine_extension resource.
The relevant VM configuration includes:

```
disable_password_authentication = true

admin_ssh_key {
  username   = var.admin_username
  public_key = var.admin_ssh_public_key
}
```

#### Decision
This finding is treated as not applicable / scanner false positive for the current Terraform configuration.
No unnecessary VM extension configuration was added merely to satisfy the scanner.


## Finding 3: CKV_AZURE_119
Check: Ensure that Network Interfaces don't use public IPs

#### Result
Failed.
The V2 Linux VM currently uses a public IP address.
The public IP is intentionally part of the V2 lab architecture because it provides:
- Direct SSH access to the Linux VM
- Direct access for testing the web server
- A practical way to test the NSG's inbound access restrictions

The NIC configuration is:
```
ip_configuration {
  name                          = "internal"
  subnet_id                     = azurerm_subnet.v2.id
  private_ip_address_allocation = "Dynamic"
  public_ip_address_id          = azurerm_public_ip.v2.id
}
```

SSH access is restricted through the NSG using the administrator's source IP:
```
source_address_prefix = var.admin_source_ip
```
The NSG is also associated with the subnet and network interface.

#### Decision
The public IP is an intentional accepted risk for this V2 lab architecture.
Removing it would require an alternative management architecture such as Azure Bastion, VPN access or a jump host. Those options would add additional infrastructure, complexity and potentially additional Azure costs.
A future version of the project can eliminate direct public VM exposure by introducing a more enterprise-oriented management architecture.


### Final Scan

After remediating CKV2_AZURE_31, the final Checkov scan reported:
Result	Count
Passed checks	13
Failed checks	2
Skipped checks	0


### Final Findings
Check	Result	Decision
CKV2_AZURE_31	Passed	Remediated
CKV_AZURE_50	Failed	Not applicable / false positive
CKV_AZURE_119	Failed	Intentional architecture decision


###     Security Validation Summary
The Terraform configuration successfully passed checks covering several important security controls, including:
- SSH key-based authentication
- Disabled password authentication
- Managed VM disks
- VM agent configuration
- Restricted SSH access
- Network security group configuration
- Subnet-level NSG association
- VNET security configuration
The remaining findings were reviewed individually rather than blindly modifying the infrastructure to achieve a 100% scanner score.

This demonstrates a security engineering workflow of:
Scan → Analyze → Remediate → Rescan → Document → Accept justified risk

## Network Security Validation

The V2 network security configuration was validated using Azure CLI and direct connectivity testing.

### NSG Validation

The Network Security Group `nsg-v2-secure-web` contains an inbound SSH rule that permits TCP port 22 only from the administrator's public IP address:

- Source: `49.205.128.94/32`
- Destination port: `22`
- Protocol: `TCP`
- Direction: `Inbound`
- Access: `Allow`

The NSG is associated with the V2 network infrastructure and protects the Linux virtual machine.

### Connectivity Validation

SSH connectivity from the authorized administrator network was successfully tested:

```text
ssh azureadmin@20.219.186.73
```

The connection succeeded and provided access to the Ubuntu Linux VM.
An earlier connection failure was caused by the VM being deallocated rather than by an incorrect NSG rule. After starting the VM, SSH connectivity succeeded.

#### Host-Level Validation
Inside the VM, the SSH service was verified:
```
sudo sshd -T | grep -i passwordauthentication
```

#### Result:
```
passwordauthentication no
```
c
This confirms that password-based SSH authentication is disabled.

### Validation Result

| Security Control | Result |
|---|---|
| SSH restricted to administrator IP | Passed |
| SSH connectivity from authorized network | Passed |
| SSH service available | Passed |
| Password authentication disabled | Passed |
| NSG configuration verified | Passed |

## Final Checkov Validation

A final Checkov scan was performed after remediation of the subnet NSG configuration.

### Final Results

| Check | Result | Interpretation |
|---|---|---|
| CKV2_AZURE_31 | Passed | Subnet is associated with an NSG |
| CKV_AZURE_50 | Failed | VM extension check remains applicable to the lab VM |
| CKV_AZURE_119 | Failed | NIC uses a public IP for the V2 lab's direct SSH access |

The `CKV2_AZURE_31` finding identified during the initial scan was successfully remediated.

The remaining findings were reviewed and intentionally retained because the V2 lab currently uses a public IP for direct administrative access and does not require VM extensions.

These findings are documented security trade-offs rather than unresolved configuration errors.

### Phase 6 Validation Status

Infrastructure, network connectivity, VM health, SSH security, RBAC, Terraform drift, and Checkov validation were completed successfully.