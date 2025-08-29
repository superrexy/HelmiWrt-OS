#!/bin/bash
#=================================================
# File name: jcg-q20-pb-boot-support.sh
# Description: Add SUPPORTED_DEVICES support for JCG Q20 pb-boot variant
# Author: HelmiWrt-OS
# Blog: https://helmiau.com
#=================================================

echo "helmilog: Adding SUPPORTED_DEVICES support for JCG Q20 pb-boot variant"

# Check if we're in the OpenWrt build directory
if [ ! -d "target/linux/ramips" ]; then
    echo "Error: Not in OpenWrt build directory. Please run this script from the OpenWrt root directory."
    exit 1
fi

# 1. Update device definition in mt7621.mk to add SUPPORTED_DEVICES
MT7621_MAKEFILE="target/linux/ramips/image/mt7621.mk"

if [ -f "$MT7621_MAKEFILE" ]; then
    echo "helmilog: Updating $MT7621_MAKEFILE to add SUPPORTED_DEVICES for JCG Q20"

    # Check if JCG Q20 device definition exists
    if grep -q "define Device/jcg_q20" "$MT7621_MAKEFILE"; then
        # Check if SUPPORTED_DEVICES already exists for jcg_q20
        if grep -A 20 "define Device/jcg_q20" "$MT7621_MAKEFILE" | grep -q "SUPPORTED_DEVICES.*jcg,q20-pb-boot"; then
            echo "helmilog: SUPPORTED_DEVICES already includes jcg,q20-pb-boot variant"
        else
            # Add SUPPORTED_DEVICES line if it doesn't exist, or update existing one
            if grep -A 20 "define Device/jcg_q20" "$MT7621_MAKEFILE" | grep -q "SUPPORTED_DEVICES"; then
                # Update existing SUPPORTED_DEVICES line
                sed -i '/define Device\/jcg_q20/,/endef/ s/SUPPORTED_DEVICES.*:=.*/SUPPORTED_DEVICES := jcg,q20 jcg,q20-pb-boot/' "$MT7621_MAKEFILE"
                echo "helmilog: Updated existing SUPPORTED_DEVICES line for JCG Q20"
            else
                # Add new SUPPORTED_DEVICES line before endef
                sed -i '/define Device\/jcg_q20/,/endef/ s/endef/  SUPPORTED_DEVICES := jcg,q20 jcg,q20-pb-boot\nendef/' "$MT7621_MAKEFILE"
                echo "helmilog: Added new SUPPORTED_DEVICES line for JCG Q20"
            fi
        fi
    else
        echo "helmilog: Warning - JCG Q20 device definition not found in $MT7621_MAKEFILE"
        echo "helmilog: Device may be defined in a different file or with different name"
    fi
else
    echo "helmilog: Warning - $MT7621_MAKEFILE not found"
fi

# 2. Update platform.sh to handle jcg,q20-pb-boot board name alias
PLATFORM_SCRIPT="target/linux/ramips/mt7621/base-files/lib/upgrade/platform.sh"

if [ -f "$PLATFORM_SCRIPT" ]; then
    echo "helmilog: Updating $PLATFORM_SCRIPT to add board name alias"

    # Check if jcg,q20-pb-boot alias already exists
    if grep -q "jcg,q20-pb-boot" "$PLATFORM_SCRIPT"; then
        echo "helmilog: Board name alias for jcg,q20-pb-boot already exists"
    else
        # Find existing jcg,q20 case and add pb-boot variant
        if grep -q "jcg,q20)" "$PLATFORM_SCRIPT"; then
            sed -i 's/jcg,q20)/jcg,q20|jcg,q20-pb-boot)/' "$PLATFORM_SCRIPT"
            echo "helmilog: Added jcg,q20-pb-boot alias to existing case statement"
        else
            echo "helmilog: Warning - jcg,q20 case not found in platform.sh"
        fi
    fi
else
    echo "helmilog: Warning - $PLATFORM_SCRIPT not found"
fi

# 3. Update 02_network script to include jcg,q20-pb-boot variant
NETWORK_SCRIPT="target/linux/ramips/mt7621/base-files/etc/board.d/02_network"

if [ -f "$NETWORK_SCRIPT" ]; then
    echo "helmilog: Updating $NETWORK_SCRIPT to add network configuration"

    # Check if jcg,q20-pb-boot already exists in network config
    if grep -q "jcg,q20-pb-boot" "$NETWORK_SCRIPT"; then
        echo "helmilog: Network configuration for jcg,q20-pb-boot already exists"
    else
        # Find existing jcg,q20 case and add pb-boot variant
        if grep -q "jcg,q20)" "$NETWORK_SCRIPT"; then
            sed -i 's/jcg,q20)/jcg,q20|jcg,q20-pb-boot)/' "$NETWORK_SCRIPT"
            echo "helmilog: Added jcg,q20-pb-boot to network configuration"
        else
            echo "helmilog: Warning - jcg,q20 network case not found in 02_network"
        fi
    fi
else
    echo "helmilog: Warning - $NETWORK_SCRIPT not found"
fi

# 4. Update 10_fix_wifi_mac script to handle jcg,q20-pb-boot variant
WIFI_MAC_SCRIPT="target/linux/ramips/mt7621/base-files/etc/hotplug.d/ieee80211/10_fix_wifi_mac"

if [ -f "$WIFI_MAC_SCRIPT" ]; then
    echo "helmilog: Updating $WIFI_MAC_SCRIPT to add WiFi MAC configuration"

    # Check if jcg,q20-pb-boot already exists in wifi mac config
    if grep -q "jcg,q20-pb-boot" "$WIFI_MAC_SCRIPT"; then
        echo "helmilog: WiFi MAC configuration for jcg,q20-pb-boot already exists"
    else
        # Find existing jcg,q20 case and add pb-boot variant
        if grep -q "jcg,q20)" "$WIFI_MAC_SCRIPT"; then
            sed -i 's/jcg,q20)/jcg,q20|jcg,q20-pb-boot)/' "$WIFI_MAC_SCRIPT"
            echo "helmilog: Added jcg,q20-pb-boot to WiFi MAC configuration"
        else
            echo "helmilog: Warning - jcg,q20 WiFi MAC case not found in 10_fix_wifi_mac"
        fi
    fi
else
    echo "helmilog: Warning - $WIFI_MAC_SCRIPT not found"
fi

echo "helmilog: JCG Q20 pb-boot variant support script completed"
echo "helmilog: The following modifications were made:"
echo "  1. Added SUPPORTED_DEVICES metadata for sysupgrade compatibility"
echo "  2. Added board name alias in platform.sh"
echo "  3. Added network configuration support"
echo "  4. Added WiFi MAC configuration support"
echo ""
echo "helmilog: This ensures that firmware built for jcg,q20 will be accepted"
echo "helmilog: by devices with board-name jcg,q20-pb-boot during sysupgrade"
