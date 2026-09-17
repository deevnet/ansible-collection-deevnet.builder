# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the `deevnet.builder` Ansible collection for infrastructure automation. It provides roles for setting up developer workstations, artifact servers (nginx-based), and base system configuration. The collection supports Fedora/RHEL systems.

The `omada_controller` role here is a cold fallback for the nms VM (ADR-0013), not the live controller.

## Commands

Run `make help` for build targets. The playbook requires the external inventory at
`../ansible-inventory-deevnet/dvntm` (see `ansible.cfg`).

## Key Patterns

### Artifact Fetching
The `artifacts` role uses a pluggable fetch system. Artifacts are defined in inventory via `artifacts_to_fetch` list with a `type` field that maps to task files:
- `type: generic` → `fetch_generic.yml` (simple URL download with optional sha256)
- `type: fedora_iso` → `fetch_fedora_iso.yml` (GPG + checksum verification)
- `type: proxmox_iso` → `fetch_proxmox_iso.yml` (detached GPG signature over SHA256SUMS)

**Proxmox signing keys are a list.** `SHA256SUMS.asc` can be signed by more than one release key
(currently Trixie *and* Bookworm, so clients spanning a Debian base change keep working), and
`gpg --verify` exits non-zero if it cannot check **any** signature in the file. Verifying a
dual-signed `.asc` with one key imported therefore fails on a good signature. Declare
`gpg_key_urls` (list) for such artifacts; `gpg_key_url` (singular) still works for single-signed
ones.

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

## Notes

- All roles assume Fedora/RHEL (uses `dnf`, yum repos)
- Remote user is `a_autoprov` with become enabled
- Inventory is external to this repo (see `ansible.cfg`)
