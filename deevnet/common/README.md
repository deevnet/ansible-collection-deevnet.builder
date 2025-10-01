# Ansible Collection - deevnet.common


Baseline Ansible collection providing foundational roles and utilities for servers and workstations.  
Includes tasks for user management, hardening, baseline tooling, and exporters (e.g., node_exporter).

---

## 🚀 Installation

You can install the collection directly from Ansible Galaxy:

```bash
ansible-galaxy collection install deevnet.common
```

Or reference it in your `requirements.yml`:

```yaml
collections:
  - name: deevnet.common
    version: ">=0.1.0"
```

Then install:

```bash
ansible-galaxy collection install -r requirements.yml
```

---

## 📂 Included Roles

- **users** — Manage users and groups  
- **hardening** — Apply baseline security configuration  
- **node_exporter** — Deploy and configure Prometheus Node Exporter  
- **admin_tools** — Common CLI and admin utilities  

*(This list will grow as roles are added to the collection.)*

---

## 🔧 Requirements

- **Ansible**: >= 2.15 (see `meta/runtime.yml`)  
- Supported platforms:  
  - Ubuntu 22.04+  
  - Debian 12+  
  - CentOS / Rocky Linux 9+  

---

## 📖 Example Playbook

```yaml
- hosts: all
  become: true
  collections:
    - deevnet.common
  roles:
    - role: users
    - role: hardening
    - role: node_exporter
```

---

## 🛠 Development

Clone the repo and build the collection locally:

```bash
git clone https://github.com/deevnet/ansible-collection-deevnet.common.git
cd ansible-collection-deevnet.common/deevnet/common
ansible-galaxy collection build
ansible-galaxy collection install ./deevnet-common-0.1.0.tar.gz
```

Run tests (if Molecule is configured):

```bash
molecule test
```

---

## 📄 License

MIT License. See [LICENSE](LICENSE).

---

## 🙋 Support & Issues

- Issues: [GitHub Issues](https://github.com/deevnet/ansible-collection-deevnet.common/issues)  
- Author: Chris Deever (via `ansible@deevnet.com`)  

---
