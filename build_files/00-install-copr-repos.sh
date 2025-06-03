#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

### Configure Repos
dnf5 -y copr enable ublue-os/packages

echo "::endgroup::"
