# Deevnet Builder Collection

The **Deevnet Builder** Ansible collection provides a complete toolkit for automating infrastructure image creation, PXE bootstrapping, artifact hosting, and multi-platform provisioning across Fedora, Debian, Raspberry Pi OS, and Proxmox.

This collection powers the Deevnet “builder pipeline,” but it also serves as a practical, hands-on way to explore real Infrastructure as Code (IaC) workflows using:

- Ansible  
- Packer  
- Terraform  
- PXE / TFTP  
- Nginx for static artifact hosting  

Use this collection to create a fully reproducible environment for building images, bootstrapping hardware, and managing lab infrastructure end-to-end.

---

## Key Features

- Provision developer/admin hosts  
- Build Raspberry Pi and Proxmox images with Packer  
- Serve artifacts (ISOs, images, bootloaders) over HTTP  
- Bootstrap bare metal using PXE  
- Consistent cross-platform automation (x86_64, ARM, Pi)  
- Modular roles — use only the parts you need  

---

## Included Roles

### `base`
Baseline configuration for any host participating in the builder workflow.  
Installs essential packages, prepares system defaults, and sets the foundation for all upper-layer roles.

### `dev_host`
Creates a development/admin environment:

- Dev users (e.g. `cdeever`)  
- SSH keys pulled from GitHub  
- Workspace directories  
- Common command-line tooling  

### `image_builder`
Configures a host to run the full image factory:

- Installs Packer, Terraform, and Go  
- Prepares image build directories  
- Integrates with artifact hosting  
- Supports building Raspberry Pi images, Proxmox templates, and cloud-init/kickstart assets  

### `artifacts`
Static HTTP artifact server using nginx:

- Hosts ISOs, images, bootloaders, checksums  
- Automatically downloads items defined in group vars  
- Exposes content for Packer builds, PXE boot, and installers  

### `bootstrap_pxe_host`
Bootstraps bare-metal machines:

- Configures TFTP and optional DHCP  
- Serves kernels, initrds, and installer configs  
- Uses nginx for HTTP-based boot paths  
- Works alongside the `artifacts` role when needed  

---

## Example Inventory (YAML)

```yaml
all:
  hosts:
    builder01:
    dev01:
    pxe01:

  children:
    dev_hosts:
      hosts:
        dev01:

    image_builder_hosts:
      hosts:
        builder01:

    artifact_hosts:
      hosts:
        builder01:

    bootstrap_hosts:
      hosts:
        pxe01:
