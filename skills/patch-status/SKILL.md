---
name: patch-status
description: Say what needs patching on the Deevnet substrate, most urgent first, and which change record to open for each. Use when the operator asks what needs patching or updating, what is out of date or near end of life, about security advisories waiting, or what the update banner on the Builder is about. Reads the deevnet-patch MCP server's tools; changes nothing.
---

# What needs patching

Answer from the **deevnet-patch** MCP server's tools, which read what the update and health
watchers on the Builder last wrote. Nothing here changes a system: this skill finds and ranks the
work, and recommends the change record for it. Applying anything is a change record the operator
approves.

If the tools are missing, the server is not registered: say so, and give
`make patch-mcp-register` in `ansible-collection-deevnet.builder`.

## Steps

1. **Read the state.** Call `patch_status`, `os_releases` and
   `security_advisories(min_severity="Important")`. Note `checked_at`: the update data is from the
   watcher's daily run. If it is more than a day old, or the operator has just patched something,
   say so and offer `make update-watch-now` before trusting it.
2. **Look closer only where it matters.** `host_updates(host, only="critical")` or `only="major"`
   for a host that ranks high; `health_status` if a system did not answer; `discovery_report` for the
   core router, switch or AP versions.
3. **Rank the findings** in this order, most urgent first:
   1. **A release past or near end of life** (`os_releases` status `past end of life` or `within 90
      days`). Once a release ends, its security updates stop, so this outranks any single advisory.
      Give the date and the days left.
   2. **Critical advisories**, then **Important**: each advisory, the hosts waiting on it, and the
      packages. A kernel among them means a reboot.
   3. **Systems that did not answer** either watcher: their state is unknown, not clean.
   4. **Newer releases of the core router or network devices** (`network` in `patch_status`).
   5. **The routine backlog**: counts of waiting updates per host, majors named.
4. **Recommend the change for each finding**, by what it is:

   | Finding | The change |
   |---|---|
   | A Fedora release near end of life | A release upgrade to `deevnet_fedora_current` (the inventory's current release, which the template and kickstart use), one host per change record |
   | Waiting updates on the service VMs or the Builder | A patch change within the release, one host at a time with a snapshot first; the method CHG-0083 piloted, until the monthly cycle (Patch Management v4) exists |
   | Hypervisor packages | One hypervisor at a time, its VMs shut down first: a change record each. Proxmox VE also notifies its own |
   | A new OPNsense point release | The [Core Router Patch](/docs/runbook/substrate/lifecycle/core-router-patch/) runbook, a change record |
   | Omada device firmware | A change record per device, as CHG-0005 and CHG-0006 did |

## The answer

Lead with the one thing to do next and why, in a sentence. Then the ranked findings, each with its
evidence (host, release and date, advisory and severity, counts) and its recommended change. End
with how old the data is. Keep the per-host backlog to a short table; name packages only for majors
and Critical advisories.

Facts come from the tools, not memory: if a tool does not say it (an end-of-life date not recorded,
a severity Debian does not give), say that it is unknown rather than filling it in.
