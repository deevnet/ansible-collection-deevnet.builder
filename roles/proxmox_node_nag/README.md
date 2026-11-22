# proxmox_node_nag

Turns off the "No valid subscription" popup that the Proxmox web UI shows at
login. Deevnet runs the no-subscription repository on purpose, so the popup says
nothing new at any login.

- `/usr/local/sbin/deevnet-pve-nag-off` makes the one check behind the popup
  (`Proxmox.Utils.checked_command` in `proxmoxlib.js`) false. The
  Repositories panel has its own check, which still reports no active
  subscription.
- `/etc/apt/apt.conf.d/86deevnet-pve-nag-off` re-runs the script after every
  dpkg run, because a `proxmox-widget-toolkit` upgrade restores the original file.

If an upgrade changes the code so the script no longer matches, the script
prints `not-found` and leaves the file alone; the next run of this role fails
and says so.

A browser that has the old file cached shows the popup until a hard refresh.

```bash
make pve-nag
# or
ansible-playbook playbooks/site.yml --limit hypervisors --tags nag
```
