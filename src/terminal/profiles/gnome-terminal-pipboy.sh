#!/bin/bash
# Install Pip-Boy theme for GNOME Terminal
# This script creates a new GNOME Terminal profile with Pip-Boy colors

# Colors in dconf format (RGB values as decimals)
# Pip-Boy green: #00FF41 = rgb(0,255,65)
# Background: #000000 = rgb(0,0,0)

PROFILE_ID=$(uuidgen)
PROFILE_NAME="Pip-Boy"

echo "Creating GNOME Terminal profile: $PROFILE_NAME"

# Create new profile
dconf write /org/gnome/terminal/legacy/profiles:/list "[$(dconf read /org/gnome/terminal/legacy/profiles:/list | tr -d '[]'), '$PROFILE_ID']"

# Set profile name
dconf write /org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/visible-name "'$PROFILE_NAME'"

# Set colors
dconf write /org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/background-color "'rgb(0,0,0)'"
dconf write /org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/foreground-color "'rgb(0,255,65)'"
dconf write /org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/cursor-colors-set true
dconf write /org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/cursor-background-color "'rgb(0,255,65)'"
dconf write /org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/cursor-foreground-color "'rgb(0,0,0)'"

# Set palette
dconf write /org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/palette "['rgb(0,0,0)', 'rgb(255,0,65)', 'rgb(0,255,65)', 'rgb(255,255,65)', 'rgb(0,65,255)', 'rgb(255,65,255)', 'rgb(65,255,255)', 'rgb(192,192,192)', 'rgb(64,64,64)', 'rgb(255,65,65)', 'rgb(65,255,65)', 'rgb(255,255,65)', 'rgb(65,65,255)', 'rgb(255,65,255)', 'rgb(65,255,255)', 'rgb(255,255,255)']"

# Set font
dconf write /org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/font "'Unifont 12'"

# Set as default
dconf write /org/gnome/terminal/legacy/profiles:/default "'$PROFILE_ID'"

echo "Pip-Boy profile created and set as default!"

