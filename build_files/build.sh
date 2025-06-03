#!/bin/bash

set -ouex pipefail

# Copy Files to Container
cp /ctx/config/* /tmp/
rsync -rvK /ctx/system_files/ /

# COPR Repos
/ctx/00-install-copr-repos.sh

# Install/Uninstall Packages
/ctx/01-packages.sh

# Install Google Fonts
/ctx/02-nerd-fonts.sh

# Cleanup
/ctx/03-cleanup.sh
