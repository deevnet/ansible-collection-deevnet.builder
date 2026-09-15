# proxmox_node_storage

Volume groups, thin pools and PVE storage entries on a Proxmox node's **data disks**, declared per
hypervisor in inventory as `proxmox_node_storage`. A node that declares none is skipped.

It exists so a hypervisor can be rebuilt from code. It records the storage a node has today; it
does not decide what that storage should be.

## What it does

| Piece | Present and matching | Missing | Present but different |
|---|---|---|---|
| Volume group | nothing | Refused, unless `-e proxmox_node_storage_allow_create=true`. Even then, only on a device with no signature (`blkid -p`). | not checked (devices are not compared) |
| Thin pool | nothing | `lvcreate -L <size> -n <name> <vg>`, then `lvconvert --type thin-pool <vg>/<name>` | fails if the name is taken by a non-thin LV |
| PVE storage entry | nothing | `pvesm add <type> <id> --vgname … [--thinpool …] --content …` | fails if type, VG or thin pool differ; content types are aligned |

It never removes, shrinks or wipes anything. Every declared storage must report active at the end.

## The common recovery case

The OS disk is reinstalled and the data disk survives. LVM finds the data disk's volume group at
boot, so nothing is created on it. Only the PVE storage entries, which live in `/etc/pve` on the
OS disk, are added back. After that, existing VM disks on the pool are visible to Proxmox again.

## Not owned here

- **The installer's own storage on the OS disk:** the `pve` volume group and `local-lvm`.
- **Partitioning.** A declared device must already exist, whether a partition or a whole disk.

## Variables

See `defaults/main.yml` for the shape.

## Run

```bash
ansible-playbook playbooks/site.yml --limit dv02hyp001p01
```

The `hypervisors` play runs `proxmox_node_base`, then this role.
