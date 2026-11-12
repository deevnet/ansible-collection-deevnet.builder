# proxmox_node_access

The Proxmox roles, users, API tokens and ACLs that automation and the Deevnet API use on a node,
declared per hypervisor in inventory as `proxmox_node_access`. A node that declares none is skipped.

It exists so a hypervisor can be rebuilt from code. These identities live in `/etc/pve` on the OS
disk, so a reinstall loses them, and before this role they were made by hand and recorded nowhere.

## What it does

| Piece | Present and matching | Missing | Present but different |
|---|---|---|---|
| Role | nothing | `pveum role add <id> --privs …` | `pveum role modify <id> --privs …`, to exactly the declared set |
| User | nothing | `pveum user add <id>` | not compared |
| API token | nothing | **Fails the run**, with the manual step | not compared |
| ACL entry | nothing | `pveum acl modify <path> --roles <role> --users\|--tokens <id>` | — |

It removes only what is declared absent (`acls_absent`, `users_absent`, `roles_absent`), with
`pveum acl delete`, `pveum user delete` or `pveum role delete`, and only after the grants, so a role that replaces another
is in place before the old one goes. Roles, users and ACL entries that are merely not declared are
left alone. Deleting a user deletes its tokens and ACL entries too.

## Why tokens are not created

A Proxmox token's secret is shown once, when it is created. Creating one here would print it into
Ansible output and leave it nowhere safe. A missing token is therefore a failure that names the
manual step: `pveum user token add`, put the secret in the vault, `make vault`, commit and **push**
before anything else, redeploy what uses it, then run this role again for the token's ACLs.

## Variables

```yaml
proxmox_node_access:
  roles:
    - id: DeevnetTenantBuilder
      privs: [VM.Allocate, VM.Audit]
  users:
    - id: deevnet-api@pve
      tokens: [tenants]
  acls:
    - path: /
      role: DeevnetTenantBuilder
      users: [deevnet-api@pve]
      tokens: [deevnet-api@pve!tenants]
  # Removed if present, after the grants above
  acls_absent:
    - path: /
      role: Administrator
      users: [terraform-prov@pve]
      tokens: [terraform-prov@pve!tf-prov-token]
  users_absent: [packer-prov@pve]
  roles_absent: [TerraformProv]
```

## Running it

```bash
ansible-playbook playbooks/site.yml --limit hypervisors --tags proxmox-access
```

Against a node that matches its declaration it reports no changes. `--check` shows what it would
do: the reads run, and every write it would make is listed without a `false_condition`.
