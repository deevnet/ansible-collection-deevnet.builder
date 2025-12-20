# Fedora Server 43 Kickstart Configuration
# Automated installation for Builder Node (bare-metal)
# Target: AOOSTAR N150 or similar mini-PC with ~1TB storage

# Installation mode
text
reboot
firstboot --disable
skipx

# Language and keyboard
lang en_US.UTF-8
keyboard us

# Timezone
timezone America/New_York --utc

# Network configuration (device-agnostic, DHCP for initial setup)
# The control-node Ansible will configure final network settings
network --bootproto=dhcp --device=link --activate --onboot=on --ipv6=auto
network --hostname=builder-node

# Root password (disabled - use SSH key auth only)
rootpw --lock

# Firewall: allow SSH
firewall --enabled --service=ssh

# Disk configuration for builder node (~1TB with dedicated /srv)
# Uses LVM for flexibility
zerombr
clearpart --all --initlabel

# Partitions:
# - /boot: 1GB XFS (outside LVM for bootloader compatibility)
# - /boot/efi: 512MB EFI partition (UEFI boot)
# - LVM volume group with:
#   - / : 50GB (OS and packages)
#   - /home: 20GB (user home directories)
#   - /srv: remainder (~800GB for artifacts, ISOs, images)
#   - swap: 16GB

part /boot --fstype=xfs --size=1024
part /boot/efi --fstype=efi --size=512
part pv.01 --size=1 --grow

volgroup vg_builder pv.01
logvol / --vgname=vg_builder --name=lv_root --fstype=xfs --size=51200
logvol /home --vgname=vg_builder --name=lv_home --fstype=xfs --size=20480
logvol /srv --vgname=vg_builder --name=lv_srv --fstype=xfs --size=1 --grow
logvol swap --vgname=vg_builder --name=lv_swap --size=16384

# Installation source (local artifact server)
url --url=http://192.168.10.97/iso/fedora/43.1-6

# Package selection (minimal for Ansible-driven provisioning)
%packages --ignoremissing --excludedocs
@core
openssh-server
sudo
python3
python3-libselinux
curl
%end

# Enable kdump
%addon com_redhat_kdump --enable --reserve-mb='auto'
%end

# User configuration - automation user for Ansible
user --name=a_autoprov --gecos="Automation User" --groups=wheel --shell=/bin/bash

# Post-installation script
%post --log=/root/ks-post.log

set -euxo pipefail

# Ensure SSH is enabled
systemctl enable --now sshd || true

# Create SSH directory with correct perms/ownership
install -d -m 0700 -o a_autoprov -g a_autoprov /home/a_autoprov/.ssh

# Fetch SSH key from artifact server
# NOTE: This URL should match your artifact server configuration
# The kickstart is served from the same server, so use relative addressing
# or update this URL to match your environment
curl --connect-timeout 10 --max-time 30 -fsSL \
  "http://192.168.10.97/keys/ssh/a_autoprov_rsa.pub" \
  -o /home/a_autoprov/.ssh/authorized_keys || true

# Enforce perms/ownership
chmod 0600 /home/a_autoprov/.ssh/authorized_keys || true
chown -R a_autoprov:a_autoprov /home/a_autoprov/.ssh

# Fix SELinux contexts so sshd will accept the key
restorecon -Rv /home/a_autoprov/.ssh || true

# Passwordless sudo for automation user
cat >/etc/sudoers.d/010_a_autoprov-nopasswd <<'EOF'
a_autoprov ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/010_a_autoprov-nopasswd
restorecon /etc/sudoers.d/010_a_autoprov-nopasswd || true

# Prepare Ansible remote_tmp directory
install -d -m 0755 -o a_autoprov -g a_autoprov /home/a_autoprov/.ansible/tmp

%end
