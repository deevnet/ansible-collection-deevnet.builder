# Deevnet Builder Collection

The **Deevnet Builder** Ansible collection provides roles for provisioning developer workstations, artifact servers, PXE boot infrastructure, and network controllers.

This collection supports the Deevnet infrastructure by:

- Provisioning workstations with dev tools (including Terraform, Packer, libvirt)
- Hosting artifacts (ISOs, images, bootloaders) via nginx
- Bootstrapping bare metal using PXE/TFTP
- Managing containerized network controllers

---

## Key Features

- Provision developer/admin workstations with dev tools and SSH keys
- Serve artifacts (ISOs, images, bootloaders) over HTTP with GPG verification
- Bootstrap bare metal using PXE (UEFI and BIOS)
- Manage network controllers via containerized services
- Modular roles — use only the parts you need  

---

## Included Roles

### `base`
Baseline configuration for hosts in the builder workflow.
Installs essential packages and system defaults.

### `workstation`
Developer/admin environment setup:

- Dev users with SSH keys from GitHub
- Development tools (git, vim, tmux, golang)
- HashiCorp tools (Terraform, Packer) from official repo
- Virtualization packages (qemu-kvm, libvirt)
- Shared workspace at `/srv/dvnt` with group ACLs

### `artifacts`
Static HTTP artifact server using nginx:

- Hosts ISOs, images, bootloaders, checksums
- Pluggable fetch system: `fedora_iso`, `proxmox_iso`, `fedora_netboot`, `generic`
- GPG signature and SHA256 verification for ISOs
- Container image tarball downloads via Podman
- SSH key and kickstart file publishing

**Container Image Requirements:**
When using `artifacts_podman_images`, all image names MUST be fully-qualified (include registry prefix like `docker.io/`, `ghcr.io/`, etc.). Short names will fail due to Podman's non-interactive short-name resolution policy.

### `bootstrap`
PXE network boot server:

- TFTP via socket-activated in.tftpd (or dnsmasq)
- DHCP configuration for PXE clients
- Dynamic PXE menu generation from inventory
- UEFI and BIOS boot support
- SELinux context management for TFTP directories

### `omada_controller`
TP-Link Omada network controller (containerized):

- Podman container from local artifact server tarball
- Systemd service for lifecycle management
- Persistent data volumes at `/opt/omada-controller/`
- Firewall rules for management and device communication ports  

---

## Inventory

This collection uses an **external inventory** from `ansible-inventory-deevnet`.

The inventory repository contains substrate-level inventories (e.g., `dvntm/`, `dvnt/`) that cover primarily physical infrastructure, though not limited to physical hosts. Each substrate inventory follows deevnet conventions:

- Hosts are named by form code (hv, vm, ph, pi) not by function
- Services are assigned via group membership
- `host_vars/` contains identity (MAC, IP, DNS)
- `group_vars/` contains intent (packages, configuration)

Configure the inventory path in `ansible.cfg` to point to the appropriate substrate.

**Expected Groups:**
- `builder` - Base role only
- `workstations` - Developer environments
- `artifact_servers` - nginx artifact hosts
- `network_controllers` - Omada controller hosts
- `bootstrap_nodes` - PXE boot servers

**Remote User:** `a_autoprov` (SSH key auth, passwordless sudo)

---

## Quick Start

```bash
make rebuild    # Install dependencies and build collection
make apply      # Build + run playbooks/site.yml
make list       # Show installed collections
```

Target specific groups:
```bash
ansible-playbook playbooks/site.yml --limit workstations
ansible-playbook playbooks/site.yml --limit artifact_servers
```
