#!/usr/bin/env bash

# Source - https://github.com/ublue-os/bluefin/blob/main/build_files/base/04-packages.sh

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

if rpm -E %fedora >/dev/null; then
    FEDORA_MAJOR_VERSION=$(rpm -E %fedora)
fi

### Install groups
# build list of all packages requested for inclusion
readarray -t INCLUDED_GROUPS < <(jq -r "[(.base.group_include | (select(.base != null).base)[]), \
                    (select(.\"$FEDORA_MAJOR_VERSION\" != null).\"$FEDORA_MAJOR_VERSION\".group_include | (select(.base != null).base)[])] \
                    | sort | unique[]" /tmp/packages.json)

# Install groups
if [[ "${#INCLUDED_GROUPS[@]}" -gt 0 ]]; then
    dnf5 -y group install "${INCLUDED_GROUPS[@]}"
else
    echo "No groups to install."
fi

### Install packages
# build list of all packages requested for inclusion
readarray -t INCLUDED_PACKAGES < <(jq -r "[(.base.include | (select(.base != null).base)[]), \
                    (select(.\"$FEDORA_MAJOR_VERSION\" != null).\"$FEDORA_MAJOR_VERSION\".include | (select(.base != null).base)[])] \
                    | sort | unique[]" /tmp/packages.json)

# Install Packages
if [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    dnf5 -y install "${INCLUDED_PACKAGES[@]}"
else
    echo "No packages to install."
fi

# build list of all packages requested for exclusion
readarray -t EXCLUDED_PACKAGES < <(jq -r "[(.base.exclude | (select(.base != null).base)[]), \
                    (select(.\"$FEDORA_MAJOR_VERSION\" != null).\"$FEDORA_MAJOR_VERSION\".exclude | (select(.base != null).base)[])] \
                    | sort | unique[]" /tmp/packages.json)

if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    readarray -t EXCLUDED_PACKAGES < <(rpm -qa --queryformat='%{NAME}\n' "${EXCLUDED_PACKAGES[@]}")
fi

# remove any excluded packages which are still present on image
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    dnf5 -y remove "${EXCLUDED_PACKAGES[@]}"
else
    echo "No packages to remove."
fi

# Add workaround for xdg-desktop-portal
dnf5 -y upgrade --enablerepo=updates-testing --refresh --advisory=FEDORA-2025-c358833c5d

echo "::endgroup::"

