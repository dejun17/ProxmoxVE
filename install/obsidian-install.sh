#!/usr/bin/env bash
set -Eeuo pipefail
set -x
exec > >(tee /root/obsidian-install.log) 2>&1
# Copyright (c) 2021-2026 community-scripts ORG
# Author: dejun17
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/dejun17/ProxmoxVE


# Functions injected by build.func
# shellcheck disable=SC1091
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

APP="AppName"

# ===========================
# DEPENDENCIES
# ===========================
msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  ca-certificates
msg_ok "Installed Dependencies"

# ===========================
# INSTALL APP
# ===========================
msg_info "Downloading ${APP}"

RELEASE=$(curl -fsSL https://api.github.com/repos/OWNER/REPO/releases/latest \
  | grep tag_name | awk -F'"' '{print $4}')

mkdir -p /opt/${APP}
curl -fsSL "https://github.com/OWNER/REPO/archive/refs/tags/${RELEASE}.tar.gz" \
  | tar xz --strip-components=1 -C /opt/${APP}

echo "${RELEASE}" >/opt/${APP}_version.txt
msg_ok "Installed ${APP} ${RELEASE}"

# ===========================
# SERVICE
# ===========================
msg_info "Creating service"
cat <<EOF >/etc/systemd/system/${APP}.service
[Unit]
Description=${APP}
After=network.target

[Service]
WorkingDirectory=/opt/${APP}
ExecStart=/usr/bin/bash /opt/${APP}/start.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable -q --now ${APP}
msg_ok "Service enabled"

# ===========================
# CLEANUP
# ===========================
motd_ssh
customize
cleanup_lxc
