#!/bin/bash

DEVICETREE_BASE="/sys/bus/i2c/devices"
# Newer ASRock Rack platforms almost always locate the EEPROM with the MAC address
# on I2C 7 0x57. We can savely assume that this is the case here too.
I2C_BUS="7-0057"

# OFFSET1 is the RTL8211E interface, and OFFSET2 the NC-SI interface.
OFFSET1="0x3f80"
OFFSET2="0x3f88"
LENGTH="6"

EEPROM_FILE="$DEVICETREE_BASE/$I2C_BUS/eeprom"

if [ ! -f "$EEPROM_FILE" ]; then
    echo "Error: EEPROM file not found."
    exit 1
fi

# Try and read the MAC address(es) from EEPROM
MAC1=$(hexdump -v -e '1/1 "%02X:"' -s "$OFFSET1" -n "$LENGTH" "$EEPROM_FILE" | sed 's/:$//')
MAC2=$(hexdump -v -e '1/1 "%02X:"' -s "$OFFSET2" -n "$LENGTH" "$EEPROM_FILE" | sed 's/:$//')

if [[ ! "$MAC1" =~ ^([A-Fa-f0-9]{2}:){5}[A-Fa-f0-9]{2}$ ]]; then
    if [[ ! "$MAC2" =~ ^([A-Fa-f0-9]{2}:){5}[A-Fa-f0-9]{2}$ ]]; then
        # Neither offsets contained a valid MAC address, so fallback to a pre-set value
        MAC_ADDR="F8:C2:49:A6:09:3B"
    else
        MAC_ADDR="${MAC2}"
    fi
else
    MAC_ADDR="${MAC1}"
fi

# Generate MAC Address using locally administered MAC
# https://en.wikipedia.org/wiki/MAC_address#Universal_vs._local_(U/L_bit
SUBMAC=$(echo "$MAC_ADDR" | cut -d ":" -f 2-5)
/usr/bin/usb-ctrl ecm usbnet off
/usr/bin/usb-ctrl ecm usbnet on "06:$SUBMAC:01" "06:$SUBMAC:00"

# Use NCM (Ethernet) Gadget instead of FunctionFS Gadget
echo 0x0103 > /sys/kernel/config/usb_gadget/usbnet/idProduct
echo "OpenBMC usbnet Device" > /sys/kernel/config/usb_gadget/usbnet/strings/0x409/product
