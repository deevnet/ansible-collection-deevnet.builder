.PHONY: help default pve-nag deps deps-force build check install-dev install-user rebuild apply list \
        publish clean-deps clean-project deep-clean all bootstrap-auth core-auth \
        update-watch update-watch-now update-watch-show update-watch-dry-run update-watch-ack \
        health-watch health-watch-now health-watch-dry-run \
        patch-mcp patch-mcp-test patch-mcp-test-refresh patch-mcp-register

# ---------- Config ----------
COLLECTION_NAME ?= deevnet-builder
REQS           ?= collections/requirements.yml
DEPS_STAMP     ?= .deps.stamp

# User-level collections (shared across repos)
USER_COLLECTIONS_PATH    ?= $(HOME)/.ansible/collections

# Project-local collections (this repo only)
PROJECT_COLLECTIONS_PATH ?= ./.ansible/collections

default: help

help:
	@printf "%s\n" \
"Targets:" \
"" \
"  deps" \
"      Install Galaxy dependency collections at the user level (~/.ansible/collections)" \
"      Only runs when collections/requirements.yml changes" \
"" \
"  deps-force" \
"      Force reinstall Galaxy dependency collections at the user level" \
"" \
"  build" \
"      Build the local collection into a versioned .tar.gz artifact" \
"" \
"  check" \
"      Syntax-check every playbook, with no inventory or vault (CI runs this)" \
"" \
"  install-dev" \
"      Build and install the collection into ./.ansible/collections (this repo only)" \
"" \
"  install-user" \
"      Build and install the collection into ~/.ansible/collections (for other repos)" \
"" \
"  publish" \
"      deps + build + install-user (user-level publish, not system-wide)" \
"" \
"  rebuild" \
"      deps + install-dev" \
"" \
"  apply" \
"      install-dev + run playbooks/site.yml using local collections first" \
"" \
"  list" \
"      Show installed collections in project and user paths" \
"" \
"  clean-deps" \
"      Remove dependency stamp (forces deps next time)" \
"" \
"  clean-project" \
"      Remove project-local collection install" \
"" \
"  deep-clean" \
"      Remove project + user collections and deps stamp" \
"" \
"  bootstrap-auth" \
"      Enable bootstrap-authoritative mode (DNS/DHCP/gateway for substrate)" \
"" \
"  core-auth" \
"      Transition to core router-authoritative mode (TFTP only on bootstrap)" \
"" \
"  pve-nag" \
"      Turn off the Proxmox web UI subscription popup on every hypervisor" \
"" \
"  update-watch" \
"      Deploy the update watcher on the Builder and its read-only check on the Builder VMs and hypervisors" \
"      (deevnet.mgmt's site.yml --tags update_check puts the check on the service VMs)" \
"" \
"  update-watch-now" \
"      Run the update watcher once now, writing its report in /srv/updates, and show its log" \
"" \
"  update-watch-dry-run" \
"      Print the notice and report the update watcher would write, without writing anything" \
"" \
"  update-watch-show" \
"      Show the scoreboard of updates waiting now, from the last run, whether or not anything is new" \
"" \
"  update-watch-ack" \
"      Acknowledge what is new: the login banner keeps the scoreboard, marked nothing new" \
"" \
"  health-watch" \
"      Deploy the health watcher on the Builder and its read-only check on the Builder VMs and hypervisors" \
"      (deevnet.mgmt's site.yml --tags update_check puts the check on the service VMs)" \
"" \
"  health-watch-now" \
"      Run the health watcher once now, writing /srv/health/latest.txt, and show it" \
"" \
"  health-watch-dry-run" \
"      Print what the health watcher finds, without changing its state or the banner" \
"" \
"  patch-mcp" \
"      Deploy deevnet-patch-mcp on the Builder: patch tools for Claude over MCP (stdio), its polkit rule," \
"      and register it with the skills in every operator's Claude Code" \
"" \
"  patch-mcp-test" \
"      Start the patch MCP server, call every read-only tool, and report each result" \
"" \
"  patch-mcp-test-refresh" \
"      The same, then a fresh scan through its refresh_updates tool (about half a minute)" \
"" \
"  patch-mcp-register" \
"      Re-register the patch MCP server for you, and link the skills to this checkout (to follow its branch)"

# ---------- Deps ----------
$(DEPS_STAMP): $(REQS)
	ansible-galaxy collection install -r "$(REQS)" -p "$(USER_COLLECTIONS_PATH)"
	touch "$(DEPS_STAMP)"

deps: $(DEPS_STAMP)

deps-force:
	ansible-galaxy collection install -r "$(REQS)" --force -p "$(USER_COLLECTIONS_PATH)"
	touch "$(DEPS_STAMP)"

# ---------- Build ----------
build:
	ansible-galaxy collection build --force

# ---------- Check ----------
# Every playbook, parsed against localhost alone: no inventory, no vault.
check:
	@set -e; for p in $$(find playbooks -name '*.yml' | sort); do \
	  echo "syntax-check $$p"; \
	  ANSIBLE_HOST_PATTERN_MISMATCH=ignore ANSIBLE_LOCALHOST_WARNING=false \
	    ansible-playbook -i localhost, --syntax-check "$$p" >/dev/null; \
	done

# ---------- Install lanes ----------
install-dev: build
	@mkdir -p "$(PROJECT_COLLECTIONS_PATH)"
	@tarball="$$(ls -1t "$(COLLECTION_NAME)"-*.tar.gz 2>/dev/null | head -1)"; \
	test -n "$$tarball"; \
	echo "Installing tarball (dev): $$tarball"; \
	ansible-galaxy collection install "$$tarball" --force -p "$(PROJECT_COLLECTIONS_PATH)"

install-user: build
	@mkdir -p "$(USER_COLLECTIONS_PATH)"
	@tarball="$$(ls -1t "$(COLLECTION_NAME)"-*.tar.gz 2>/dev/null | head -1)"; \
	test -n "$$tarball"; \
	echo "Installing tarball (user): $$tarball"; \
	ansible-galaxy collection install "$$tarball" --force -p "$(USER_COLLECTIONS_PATH)"

# ---------- Workflows ----------
rebuild: deps install-dev

publish: deps install-user
	@echo "Published $(COLLECTION_NAME) to $(USER_COLLECTIONS_PATH)"

apply: install-dev
	@ANSIBLE_COLLECTIONS_PATH="$(PROJECT_COLLECTIONS_PATH):$(USER_COLLECTIONS_PATH)" \
	  ansible-playbook playbooks/site.yml

# ---------- Inspection ----------
list:
	@echo "== Project collections ($(PROJECT_COLLECTIONS_PATH)) =="
	@ANSIBLE_COLLECTIONS_PATH="$(PROJECT_COLLECTIONS_PATH)" ansible-galaxy collection list || true
	@echo
	@echo "== User collections ($(USER_COLLECTIONS_PATH)) =="
	@ANSIBLE_COLLECTIONS_PATH="$(USER_COLLECTIONS_PATH)" ansible-galaxy collection list || true

# ---------- Cleanup ----------
clean-deps:
	rm -f "$(DEPS_STAMP)"

clean-project:
	rm -rf "$(PROJECT_COLLECTIONS_PATH)"

deep-clean: clean-project
	rm -rf "$(USER_COLLECTIONS_PATH)"
	rm -f "$(DEPS_STAMP)"

all: rebuild apply

# ---------- Authority Mode Transitions ----------
bootstrap-auth: install-dev
	@ANSIBLE_COLLECTIONS_PATH="$(PROJECT_COLLECTIONS_PATH):$(USER_COLLECTIONS_PATH)" \
	  ansible-playbook playbooks/bootstrap-authoritative.yml

core-auth: install-dev
	@ANSIBLE_COLLECTIONS_PATH="$(PROJECT_COLLECTIONS_PATH):$(USER_COLLECTIONS_PATH)" \
	  ansible-playbook playbooks/core-authoritative.yml

# ---------- Proxmox ----------
pve-nag: install-dev
	@ANSIBLE_COLLECTIONS_PATH="$(PROJECT_COLLECTIONS_PATH):$(USER_COLLECTIONS_PATH)" \
	  ansible-playbook playbooks/site.yml --limit hypervisors --tags nag

# ---------- Update watcher (Patch Management v2) ----------
update-watch: install-dev
	@ANSIBLE_COLLECTIONS_PATH="$(PROJECT_COLLECTIONS_PATH):$(USER_COLLECTIONS_PATH)" \
	  ansible-playbook playbooks/site.yml --limit 'update_watchers:builder:hypervisors' --tags update_watch,update_check

# These run the watcher on this host, which is the Builder.
update-watch-now:
	sudo systemctl start deevnet-update-watch.service
	sudo journalctl -u deevnet-update-watch.service -n 20 --no-pager

update-watch-dry-run:
	sudo -u deevnet-watch /usr/local/sbin/deevnet-update-watch --config /etc/deevnet/update-watch.json --dry-run

# The scoreboard leads latest.txt on every run; the banner shows it only while
# there is news. This shows it any time, with when it was checked.
update-watch-show:
	@sed -n '1,/^Total/p' /srv/updates/latest.txt
	@grep '^Checked' /srv/updates/latest.txt

update-watch-ack:
	sudo -u deevnet-watch /usr/local/sbin/deevnet-update-watch --config /etc/deevnet/update-watch.json --ack

# ---------- Health watcher (INC-0007) ----------
# update_watch too: the health watcher uses its account.
health-watch: install-dev
	@ANSIBLE_COLLECTIONS_PATH="$(PROJECT_COLLECTIONS_PATH):$(USER_COLLECTIONS_PATH)" \
	  ansible-playbook playbooks/site.yml --limit 'update_watchers:builder:hypervisors' --tags update_watch,health_watch,update_check

health-watch-now:
	sudo systemctl start deevnet-health-watch.service
	cat /srv/health/latest.txt

health-watch-dry-run:
	sudo -u deevnet-watch /usr/local/sbin/deevnet-health-watch --config /etc/deevnet/health-watch.json --dry-run

# ---------- Patch tools for Claude (MCP) ----------
patch-mcp: install-dev
	@ANSIBLE_COLLECTIONS_PATH="$(PROJECT_COLLECTIONS_PATH):$(USER_COLLECTIONS_PATH)" \
	  ansible-playbook playbooks/site.yml --limit update_watchers --tags patch_mcp

patch-mcp-test:
	/usr/local/bin/deevnet-patch-mcp --self-test

# The same, then a fresh scan through refresh_updates (about half a minute).
patch-mcp-test-refresh:
	/usr/local/bin/deevnet-patch-mcp --self-test --refresh

# make patch-mcp already registers the server and links the installed skills for
# every operator. This is for skill development: it links the skills to this
# checkout instead, so they follow its branch. User scope: /srv/dvnt, where Claude
# runs, is the organization's .github checkout.
patch-mcp-register:
	-claude mcp remove deevnet-patch --scope user >/dev/null 2>&1
	claude mcp add --scope user deevnet-patch -- /usr/local/bin/deevnet-patch-mcp
	mkdir -p $(HOME)/.claude/skills
	@for d in skills/*/; do n=$$(basename $$d); ln -sfn "$(CURDIR)/skills/$$n" "$(HOME)/.claude/skills/$$n"; echo "skill $$n linked"; done
