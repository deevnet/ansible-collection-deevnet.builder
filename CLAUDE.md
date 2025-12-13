# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the `deevnet.builder` Ansible collection for infrastructure automation. It provides roles for setting up developer workstations, artifact servers (nginx-based), and base system configuration. The collection supports Fedora/RHEL systems.

## Repository Structure

```
repo-root/                 # Collection root = git repo root (Galaxy-compatible layout)
├── galaxy.yml             # Collection metadata (declares ansible.posix dependency)
├── meta/runtime.yml       # Ansible version requirement
├── ansible.cfg            # Development config (uses external inventory)
├── Makefile               # Build/install automation
├── playbooks/site.yml     # Main playbook targeting builder/workstations/artifact_servers/network_controllers/bootstrap_nodes
└── roles/
    ├── base/              # Baseline packages (dnf-based)
    ├── workstation/       # Dev users, dev tools (git, terraform, packer), AI tooling
    ├── artifacts/         # nginx artifact server with ISO/image fetching
    ├── omada_controller/  # TP-Link Omada network controller (podman container via systemd)
    └── bootstrap/         # PXE boot server (dnsmasq DHCP/TFTP) for network installations
```

## Common Commands

Using the Makefile (recommended):
```bash
make deps      # Install ansible.posix dependency
make build     # Build collection tarball
make install   # Install tarball locally
make rebuild   # deps + build + install (full bootstrap)
make all       # rebuild + run playbook against builder
```

Manual commands (from repo root):
```bash
ansible-galaxy collection build --force
ansible-galaxy collection install deevnet-builder-*.tar.gz --force
```

Run the main playbook (requires inventory at `../ansible-inventory-deevnet/dvntm`):
```bash
ansible-playbook playbooks/site.yml
```

Run against specific hosts:
```bash
ansible-playbook playbooks/site.yml --limit builder
ansible-playbook playbooks/site.yml --limit workstations
ansible-playbook playbooks/site.yml --limit artifact_servers
ansible-playbook playbooks/site.yml --limit network_controllers
ansible-playbook playbooks/site.yml --limit bootstrap_nodes
```

Syntax check:
```bash
ansible-playbook playbooks/site.yml --syntax-check
```

## Key Patterns

### Artifact Fetching
The `artifacts` role uses a pluggable fetch system. Artifacts are defined in inventory via `artifacts_to_fetch` list with a `type` field that maps to task files:
- `type: generic` → `fetch_generic.yml` (simple URL download with optional sha256)
- `type: fedora_iso` → `fetch_fedora_iso.yml` (GPG + checksum verification)

### Container Service Management
The `omada_controller` role demonstrates systemd management of podman containers:
- Downloads container image tarball from local artifact server
- Loads tarball with `podman load`
- Creates container with `podman create` (port mappings, volumes, env vars)
- Manages lifecycle via systemd service with proper restart handling

### PXE Boot Server (Bootstrap Role)
The `bootstrap` role sets up a PXE network boot server using dnsmasq:
- Provides DHCP and TFTP services for PXE clients
- Fetches netboot images (kernel/initrd) from artifact server
- Generates PXE boot menu from `bootstrap_netboot_images` list
- Configures SELinux contexts for TFTP directories
- Opens firewall ports (DHCP 67/udp, TFTP 69/udp, optionally DNS)

### Variable Conventions
- `dev_users: []` - List of users for workstation role (define in host_vars/group_vars)
- `artifacts_to_fetch: []` - List of artifacts to download (define in host_vars/group_vars)
- `artifacts_podman_images: []` - List of container images to download (requires fully-qualified names like `docker.io/user/repo:tag`)
- `omada_*` - Omada controller configuration (container image, ports, volumes, env vars)
- `nginx_artifacts_root: /srv/dvntm-http` - Default artifact server root
- `bootstrap_*` - PXE boot server configuration (DHCP range, interface, TFTP root, netboot images)

### Inventory Groups
The playbook expects these groups: `builder`, `workstations`, `artifact_servers`, `network_controllers`, `bootstrap_nodes`

## Notes

- All roles assume Fedora/RHEL (uses `dnf`, yum repos)
- Remote user is `a_autoprov` with become enabled
- Inventory is external to this repo (see `ansible.cfg`)
