#!/bin/bash
set -euxo pipefail

# prevent apt-get et al from asking questions.
# NB even with this, you'll still get some warnings that you can ignore:
#     dpkg-preconfigure: unable to re-open stdin: No such file or directory
export DEBIAN_FRONTEND=noninteractive

# # make sure the system does not uses swap (a kubernetes requirement).
# # NB see https://kubernetes.io/docs/tasks/tools/install-kubeadm/#before-you-begin
swapoff -a
sed -i -E 's,^([^#]+\sswap\s.+),#\1,' /etc/fstab

# show mac/ip addresses and the machine uuid to troubleshoot they are unique within the cluster.
ip addr
cat /sys/class/dmi/id/product_uuid

# update the package cache.
apt-get update

# Install the cloud kernel
# apt install -y linux-image-cloud-amd64
# Remove the generic kernel
# apt-get remove -y linux-image-*[^cloud]-amd64

# remove not required apckages
APT_PACKAGES=""

APT_PACKAGES=" acpi aptitude at aspell aspell-en avahi-daemon bc bin86 console-common console-data console-tools dc debian-faq"
#APT_PACKAGES=" bash-completion"
APT_PACKAGES=" debian-faq-de debian-faq-fr debian-faq-it debian-faq-zh-cn doc-debian eject fdutils"
APT_PACKAGES=" file finger foomatic-filters groff hplip iamerican ibritish info ispell libavahi-compat-libdnssd1 laptop-detect"
APT_PACKAGES=" mtools mutt netcat ncurses-term ppp pppconfig pppoe pppoeconf"
#APT_PACKAGES=" manpages"
#APT_PACKAGES=" traceroute mtr-tiny"
APT_Packages=" read-edid reportbug tasksel tcsh unzip usbutils wamerican w3m whois zip"
apt-get remove -y $APT_PACKAGES
apt-get autoremove --purge -y


# install required packages
APT_PACKAGES=""

# Install curl
APT_PACKAGES+=" curl"

# Install the VIM
APT_PACKAGES+=" vim-tiny"

# Install useful tools
APT_PACKAGES+=" tcpdump traceroute iptables mtr-tiny"

# Install gpg for apt-key operations
APT_PACKAGES+=" gpg"

# install packages
apt-get install -y --no-install-recommends $APT_PACKAGES

# show network routes.
ip route

# show memory info.
free
