#!/bin/bash

# Copyright (c) 2021-2025 Ampere Computing LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# shellcheck disable=SC2046

set -o errexit
set -o nounset

do_probe () {
	# Check the PNOR partition is available
	if ! grep "pnor" /proc/mtd > /dev/null; then
		# Check the ASpeed SMC driver bound before
		HOST_SPI=/sys/bus/platform/drivers/spi-aspeed-smc/1e630000.spi
		if [ -d "$HOST_SPI" ]; then
			echo "Unbinding the ASpeed SMC driver"
			echo 1e630000.spi > /sys/bus/platform/drivers/spi-aspeed-smc/unbind
			sleep 2
		fi

		# If the PNOR partition is not available, then bind again driver
		echo "Binding the ASpeed SMC driver"
		echo 1e630000.spi > /sys/bus/platform/drivers/spi-aspeed-smc/bind
		sleep 2
	fi

	if ! grep "pnor" /proc/mtd > /dev/null; then
		echo "Error: failed to probe host SPI-NOR device"
		exit 1
	fi
}

turn_host_off () {
	# Turn off the Host if it is currently ON
	chassisstate=$(obmcutil chassisstate | awk -F. '{print $NF}')
	echo "Current chassis state: $chassisstate"
	if [ "$chassisstate" == 'On' ]; then
		echo "Turning the chassis off"
		obmcutil chassisoff

		# Wait 60s until Chassis is off
		cnt=30
		while [ "$cnt" -gt 0 ]; do
			cnt=$((cnt - 1))
			sleep 2
			# Check if HOST was OFF
			chassisstate_off=$(obmcutil chassisstate | awk -F. '{print $NF}')
			if [ "$chassisstate_off" != 'On' ]; then
				break
			fi

			if [ "$cnt" == "0" ]; then
				echo "Error: failed to turn the chassis off"
				exit 1
			fi
		done
	fi
}

switch_spi_bus () {
	if [ "$1" = "bmc" ]; then
		# Switch the host SPI bus to BMC"
		echo "Switching the host SPI bus to BMC"
		if ! gpioset $(gpiofind spi0-program-sel)=0; then
			echo "Error: failed to switch the host SPI bus to BMC. Please check GPIO state"
			exit 1
		fi
	else
		# Switch the host SPI bus to HOST."
		echo "Switching the host SPI bus to Host"
		if ! gpioset $(gpiofind spi0-program-sel)=1; then
			echo "Error: failed to switch the host SPI bus to Host. Please check GPIO state"
			exit 1
		fi
	fi
}

do_flash() {
	case "$IMAGE_TYPE" in
		full)
			MTD=mtd:pnor
			;;
		code)
			# There's no code MTD for now.
			# Use the UEFI code instead.
			MTD=mtd:pnor-uefi
			;;
		tfa)
			MTD=mtd:pnor-tfa
			;;
		uefi)
			MTD=mtd:pnor-uefi
			;;
	esac

	echo "Flashing firmware to ${MTD}"
	flashcp.mtd-utils -p -v "$IMAGE" "${MTD}"
}

usage () {
	echo "Utility to flash the host (arm64/AArch64/ARMv8-A CPU) firmware on Ampere systems."
	echo "Usage:"
	echo "  $(basename "$0") [options] <Host firmware file>"
	echo
	echo "Options:"
	echo "  -f, --full                       Flash the entire SPI-NOR chip (default)"
	echo "  -c, --code                       Flash the code (UEFI) area - TF-A not included yet"
	echo "  -t, --tfa                        Flash the TF-A (ATF) area"
	echo "  -u, --uefi                       Flash the UEFI area"
	echo "  -B, --bmc                        Switch the Host SPI bus to the BMC and exit"
	echo "  -H, --host                       Switch the Host SPI bus to the Host and exit"
	echo "  -h, --help                       This help message"
	echo ""
	echo "Note: TF-A (Trusted Firmware for ARMv8-A) is the same as ATF (ARM Trusted Firmware)."
	exit 1
}

# Script starts running here

IMAGE_TYPE=""

OPTIONS=$(getopt -o fctuBHh --long full,code,tfa,uefi,bmc,host,help -- "$@")
eval set -- "$OPTIONS"

while true; do
	case "$1" in
		-f|--full)
			IMAGE_TYPE=full; shift;;
		-c|--code)
			IMAGE_TYPE=code; shift;;
		-t|--tfa)
			IMAGE_TYPE=tfa; shift;;
		-u|--uefi)
			IMAGE_TYPE=uefi; shift;;
		-B|--bmc)
			switch_spi_bus bmc;
			do_probe;
			exit;;
		-H|--host)
			switch_spi_bus host;
			exit;;
		-h|--help)
			usage;;
		--) shift; break;;
		*) echo "Internal error ($1)!"; exit 1;;
	esac
done

if [ "$#" -eq 1 ] && [ -n "$1" ]; then
	IMAGE="$1"
else
	usage
fi

eval set -- ""

if [ -z "${IMAGE_TYPE}" ]; then
	IMAGE_TYPE=full
fi

if [ ! -f "${IMAGE}" ]; then
	echo "The image file ${IMAGE} does not exist"
	exit 1
fi

turn_host_off

switch_spi_bus bmc

do_probe

# Flash the firmware
do_flash

switch_spi_bus host

if [ "$chassisstate" == 'On' ]; then
	echo "Waiting 20 seconds before turning on the host"
	sleep 20
	echo "Turning on the host"
	obmcutil chassison
fi
