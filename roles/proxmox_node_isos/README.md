# proxmox_node_isos

Installer ISOs in a Proxmox node's `local` ISO storage, fetched from the artifact server and
declared in inventory as `proxmox_node_isos`. Packer's Fedora template build boots from
`local:iso/Fedora-Server-dvd-x86_64-<release>-<build>.iso`, and a reinstalled node has none.

## What it does

For each URL, `get_url` compares the file already on the node with `<url>.sha256`, which the
`artifacts` role writes beside every Fedora ISO it publishes. It downloads only a file that is
missing or differs, and keeps it only if it matches. Files not listed are left alone, so an old
release's ISO stays until removed by hand.

It runs as root over SSH, not through the Proxmox API: the API's `download-url` needs
`Sys.AccessNetwork` on the node, which the automation token does not hold (CHG-0037).

## Variables

See `defaults/main.yml`.

## Run

```bash
ansible-playbook playbooks/site.yml --limit hypervisors --tags isos
```

The artifact server and the hypervisors share the management subnet, so the download does not
cross the core router.
