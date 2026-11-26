---
name: patch-status
description: Say what needs patching on the Deevnet substrate, most urgent first, and which change record to open for each. Use when the operator asks what needs patching or updating, what is out of date or near end of life, about security advisories waiting, or what the update banner on the Builder is about. Reads the deevnet-patch MCP server's tools; changes nothing; can run the update watcher for a fresh scan.
---

# What needs patching

Answer from the **deevnet-patch** MCP server's tools, which read what the update and health
watchers on the Builder last wrote; `refresh_updates` runs the update watcher first for a fresh
scan. Nothing here changes a system: this skill finds and ranks the work, and recommends the change
record for it. Applying anything is a change record the operator approves.

If the tools are missing, the server is not registered: say so, and give
`make patch-mcp` in `ansible-collection-deevnet.builder`, then a new session.

## Steps

1. **Make sure the data is fresh.** Call `refresh_updates` first when the operator asks for a
   fresh or live look, has just patched something, or `checked_at` is more than a day old; it
   scans every host (about half a minute) and returns `patch_status` from the new report. Otherwise
   the daily run is enough. If `refresh_updates` fails, say why and give `make update-watch-now`.
2. **Read the state.** Call `patch_status` (unless `refresh_updates` just returned it),
   `os_releases` and `security_advisories(min_severity="Important")`. Note `checked_at`.
3. **Look closer only where it matters.** `host_updates(host, only="critical")` or `only="major"`
   for a host that ranks high; `health_status` if a system did not answer; `discovery_report` for the
   core router, switch or AP versions.
4. **Rank the findings** in this order, most urgent first:
   1. **A release past or near end of life** (`os_releases` status `past end of life` or `within 90
      days`). Once a release ends, its security updates stop, so this outranks any single advisory.
      Give the date and the days left.
   2. **Critical advisories**, then **Important**: each advisory, the hosts waiting on it, and the
      packages. A kernel among them means a reboot.
   3. **Systems that did not answer** either watcher: their state is unknown, not clean.
   4. **Newer releases of the core router or network devices** (`network` in `patch_status`).
   5. **The routine backlog**: counts of waiting updates per host, majors named.
5. **Recommend the change for each finding**, by what it is:

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
with how old the data is, and whether it was refreshed for this answer. Keep the per-host backlog to a short table; name packages only for majors
and Critical advisories.

Facts come from the tools, not memory: if a tool does not say it (an end-of-life date not recorded,
a severity Debian does not give), say that it is unknown rather than filling it in.
