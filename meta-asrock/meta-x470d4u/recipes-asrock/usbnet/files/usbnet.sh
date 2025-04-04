#!/bin/bash

# MAC is static (octets 2-5 are random generated), no magic required for USB gadget
/usr/bin/usb-ctrl ecm usbnet off
/usr/bin/usb-ctrl ecm usbnet on "06:6b:00:5a:26:01" "06:6b:00:5a:26:00"

# Use NCM (Ethernet) Gadget instead of FunctionFS Gadget
echo 0x0103 > /sys/kernel/config/usb_gadget/usbnet/idProduct
echo "OpenBMC usbnet Device" > /sys/kernel/config/usb_gadget/usbnet/strings/0x409/product

if [ "$MAC_ADDR" != "$ENV_MAC_ADDR" ]; then
	# fail and wait for systemd to restart this service
	exit 1
fi