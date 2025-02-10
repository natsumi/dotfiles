#! /usr/bin/env bash

# DESCRIPTION
# Applies basic system settings.

# EXECUTION
read -r -p "What is this machine's computer name? " mac_os_label
if [[ -z "$mac_os_label" ]]; then
  printf "ERROR: Invalid MacOS label.\n"
  exit 1
fi

read -r -p "What is this machine's host name? " mac_os_name
if [[ -z "$mac_os_name" ]]; then
  printf "ERROR: Invalid MacOS name.\n"
  exit 1
fi
printf "Setting system computer name and  host name...\n"
sudo scutil --set ComputerName "$mac_os_label"
sudo scutil --set HostName "$mac_os_name"
sudo scutil --set LocalHostName "$mac_os_name"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$mac_os_name"