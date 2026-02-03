#!/usr/bin/env bash
set -Eeuo pipefail
set -x
exec > >(tee /root/obsidian-install.log) 2>&1
# Copyright (c) 2021-2026 community-scripts ORG
# Author: dejun17
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/dejun17/ProxmoxVE

# Dev URL (CHANGE BEFORE PR)
# shellcheck disable=SC1090
source <(curl -fsSL https://raw.githubusercontent.com/dejun17/ProxmoxVE/main/misc/build.func)


# shellcheck disable=SC2034
APP="Obsidian"
var_tags="utility;selfhosted"
var_cpu="2"
var_ram="2048"
var_disk="8"
var_os="debian"
var_version="12"
var_unprivileged="1"
VERBOSE="yes"
header_info "$APP"

variables
color
catch_errors

# ===========================
# UPDATE FUNCTION
# ===========================
function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/${APP} ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  RELEASE=$(curl -fsSL https://api.github.com/repos/OWNER/REPO/releases/latest \
    | grep tag_name | awk -F'"' '{print $4}')

  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Updating ${APP} to ${RELEASE}"

    # update logic goes here

    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Updated ${APP}"
  else
    msg_ok "No update required"
  fi
  exit
}

start
build_container
description

msg_ok "Completed successfully!"
echo -e "${INFO}${YW} Access ${APP} via:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}${CL}"
