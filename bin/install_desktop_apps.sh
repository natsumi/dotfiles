#!/usr/bin/env bash

# Define arrays for each category of applications

PRODUCTIVITY_APPS=(
  "alfred"
  "forklift"
  "google-chrome"
  "homebrew/cask-versions/firefox-developer-edition"
  "itsycal"
  "shottr"
)

DEVELOPMENT_APPS=(
  "cursor"
  "kitty"
  "postman"
  "sublime-merge"
  "tableplus"
  "visual-studio-code"
)

MEDIA_APPS=(
  "spotify"
  "spotmenu"
  "vlc"
)

SOCIAL_APPS=(
  "discord"
  "slack"
  "telegram"
)

UTILITY_APPS=(
  "betterdisplay"
  "localsend"
  "jordanbaird-ice"
  "mounty"
  "sanesidebuttons"
  "stats"
  "qlvideo"
  "the-unarchiver"
  "trex"
)

# Install applications using the defined arrays

# Productivity applications
echo "===================================="
echo "Installing Productivity Applications"
echo "===================================="
for app in "${PRODUCTIVITY_APPS[@]}"; do
  brew install --cask "$app"
done

# Social applications
echo "================================"
echo "Installing Social Applications"
echo "================================"
for app in "${SOCIAL_APPS[@]}"; do
  brew install --cask "$app"
done

# Development applications
echo "===================================="
echo "Installing Development Applications"
echo "===================================="
for app in "${DEVELOPMENT_APPS[@]}"; do
  brew install --cask "$app"
done

# Utility applications
echo "================================"
echo "Installing Utility Applications"
echo "================================"
for app in "${UTILITY_APPS[@]}"; do
  brew install --cask "$app"
done

# Media applications
echo "=============================="
echo "Installing Media Applications"
echo "=============================="
for app in "${MEDIA_APPS[@]}"; do
  brew install --cask "$app"
done
