# Project Overview

This is an Ansible collection named `deevnet.builder`. Its purpose is to automate infrastructure provisioning and management tasks. It includes roles for setting up a development workstation, an artifact server, a network controller, and a base configuration for servers. The collection is designed to be modular and reusable.

# Building and Running

This is an Ansible collection, so there isn't a traditional "build" process. To use this collection, you would typically run the playbooks with `ansible-playbook`.

**Running Playbooks:**

The main playbook is `deevnet/builder/playbooks/site.yml`. To run it, you would use a command like this:

```bash
ansible-playbook -i <inventory_file> deevnet/builder/playbooks/site.yml
```

Replace `<inventory_file>` with the path to your Ansible inventory file.

**Building the Collection:**

To build the collection into a tarball for distribution, you can use the `ansible-galaxy` command:

```bash
cd deevnet/builder
ansible-galaxy collection build
```

This will create a file like `deevnet-builder-1.0.0.tar.gz`.

# Development Conventions

*   **Roles:** The collection is organized into roles, with each role responsible for a specific component of the infrastructure.
*   **Variables:** Default variables for each role are defined in the `defaults/main.yml` file within the role's directory. These can be overridden in your inventory or playbook.
*   **Tasks:** Tasks are defined in the `tasks` directory of each role. The main entry point for a role's tasks is `tasks/main.yml`.
*   **Templates:** Templates are used to generate configuration files. They are located in the `templates` directory of each role.
*   **Handlers:** Handlers are used to restart services or perform other actions when a change is made. They are located in the `handlers` directory of each role.
*   **Metadata:** Collection metadata is defined in `deevnet/builder/galaxy.yml`. Role metadata is in the `meta/main.yml` file for each role.
