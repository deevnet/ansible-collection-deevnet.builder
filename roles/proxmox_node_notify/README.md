# proxmox_node_notify

Where a Proxmox node's notifications go. Proxmox sends backup results, failed
jobs and package updates through its notification system; out of the box that
is a built-in target, `mail-to-root`, which mails root@pam's address as typed
into the installer. This role puts the address and the routing in inventory:

- an email target, `deevnet-operator`, sending to `proxmox_node_notify_email`
  from `root@<node FQDN>`;
- a rule, `deevnet-all`, sending every notification to it;
- Proxmox's built-in rule, `default-matcher`, disabled, so each notification is
  sent once. Built-in entries can't be deleted.

The address is personal, so inventory sets it from the vault:
`proxmox_node_notify_email: "{{ vault_proxmox_notify_email }}"`. The role stops
on a node if it is empty.

Mail leaves through the node's own Postfix, as before.

```bash
ansible-playbook playbooks/site.yml --limit hypervisors --tags notifications
```
