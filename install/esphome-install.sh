#!/usr/bin/env bash

# Copyright (c) 2021-2023 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y git
msg_ok "Installed Dependencies"

msg_info "Updating Python3"
$STD apt-get install -y \
python3 \
python3-dev \
python3-pip \
python3-venv
msg_ok "Updated Python3"

msg_info "Installing ESPHome"
if [[ "$PCT_OSVERSION" == "12" ]]; then
  $STD pip install esphome --break-system-packages
  $STD pip install tornado esptool --break-system-packages
else
  $STD pip install esphome
  $STD pip install tornado esptool
fi
msg_ok "Installed ESPHome"

msg_info "Creating Service"
service_path="/etc/systemd/system/esphomeDashboard.service"
echo "[Unit]
Description=ESPHome Dashboard
After=network.target
[Service]
ExecStart=/usr/local/bin/esphome dashboard /root/config/
Restart=always
User=root
[Install]
WantedBy=multi-user.target" >$service_path
systemctl enable -q --now esphomeDashboard.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get autoremove
$STD apt-get autoclean
msg_ok "Cleaned"
