#!/bin/bash
#=================================================
# Manual Build Script for JCG Q20 with HelmiWrt-OS
# Description: Build OpenWrt for JCG Q20 with HelmiWrt modifications
# Author: HelmiWrt-OS
# Blog: https://helmiau.com
#=================================================

set -e

echo "============================================"
echo "HelmiWrt-OS Build Script for JCG Q20"
echo "============================================"

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Error: This build script requires Linux environment"
    echo "Please use Ubuntu 18.04/20.04 LTS or similar"
    exit 1
fi

# Install build dependencies
echo "Installing build dependencies..."
sudo apt update
sudo apt install -y build-essential clang flex bison g++ gawk \
gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev \
python3-distutils rsync unzip zlib1g-dev file wget curl

# Clone OpenWrt source
OPENWRT_DIR="openwrt"
if [ ! -d "$OPENWRT_DIR" ]; then
    echo "Cloning OpenWrt source..."
    git clone https://github.com/coolsnowwolf/lede.git $OPENWRT_DIR
fi

cd $OPENWRT_DIR

# Update and install feeds
echo "Updating feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# Run HelmiWrt customization script
echo "Applying HelmiWrt customizations..."
bash ../scripts/lean-openwrt.sh

# Create JCG Q20 configuration
echo "Creating JCG Q20 configuration..."
cat > .config << 'EOF'
# Target
CONFIG_TARGET_ramips=y
CONFIG_TARGET_ramips_mt7621=y
CONFIG_TARGET_ramips_mt7621_DEVICE_jcg_q20=y

# Basic system
CONFIG_PACKAGE_dnsmasq=n
CONFIG_PACKAGE_dnsmasq-full=y
CONFIG_PACKAGE_kmod-usb-core=y
CONFIG_PACKAGE_kmod-usb-ohci=y
CONFIG_PACKAGE_kmod-usb-uhci=y
CONFIG_PACKAGE_kmod-usb2=y
CONFIG_PACKAGE_kmod-usb3=y

# File systems
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-fs-vfat=y
CONFIG_PACKAGE_e2fsprogs=y

# Network
CONFIG_PACKAGE_wpad-openssl=y
CONFIG_PACKAGE_hostapd-common=n
CONFIG_PACKAGE_wpad-basic-wolfssl=n

# LuCI
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-ssl-openssl=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-argon-config=y

# Additional packages
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_wget=y
CONFIG_PACKAGE_nano=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_iperf3=y
EOF

# Append universal config
cat ../config/universal.config >> .config

# Generate full config
echo "Generating configuration..."
make defconfig

# Start compilation
echo "Starting compilation..."
echo "This may take 1-3 hours depending on your hardware"
make download -j8
find dl -size -1024c -exec ls -l {} \;
find dl -size -1024c -exec rm -f {} \;

# Compile
make -j$(($(nproc) + 1)) V=s

echo "============================================"
echo "Build completed!"
echo "============================================"
echo "Firmware location: bin/targets/ramips/mt7621/"
echo "Look for files with 'jcg_q20' in the name"
echo ""
echo "Files to flash:"
echo "- Factory: *-jcg_q20-squashfs-factory.bin"
echo "- Sysupgrade: *-jcg_q20-squashfs-sysupgrade.bin"
echo "============================================"
