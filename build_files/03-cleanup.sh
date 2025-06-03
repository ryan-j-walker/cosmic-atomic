#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

rm -rf /tmp/* || true
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -fr {} \;

for i in /etc/yum.repos.d/rpmfusion-*; do
    sed -i 's@enabled=1@enabled=0@g' "$i"
done

systemctl disable flatpak-add-fedora-repos.service

if rpm -q docker-ce >/dev/null; then
    systemctl enable docker.socket
fi
systemctl disable rpm-ostreed-automatic.timer
systemctl enable brew-setup.service
systemctl enable brew-update.timer
systemctl enable brew-upgrade.timer
systemctl enable podman.socket
systemctl enable uupd.service
systemctl enable uupd.timer
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo

for i in /etc/yum.repos.d/rpmfusion-*; do
    sed -i 's@enabled=1@enabled=0@g' "$i"
done

dnf5 -y copr disable phracek/PyCharm
dnf5 -y copr disable ublue-os/packages

echo "::endgroup::"
