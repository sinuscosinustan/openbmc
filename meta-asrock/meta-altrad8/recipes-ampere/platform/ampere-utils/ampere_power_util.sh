#!/bin/bash

# File indicating we've sent a request to the host to shut down
HOST_SHUTDOWN_IN_PROGRESS_FILE="/run/openbmc/host@0-softpoweroff"
# File indicating the host has indicated it's finished shutting down
HOST_SHUTDOWN_ACK_FILE="/run/openbmc/host@0-softpoweroff-shutdown-ack"
# Wait for 30 seconds for the shutdown_ack from the host
HOST_SHUTDOWN_TIMEOUT_SECONDS=30

# Usage of this utility
usage() {
	echo "Usage:"
	echo "  ampere_power_util.sh [status|shutdown_ack|force_reset|soft_off|host_reboot_wa]"
}

get_gpio() {
	gpio_name=$1

	# shellcheck disable=SC2046
	gpioget $(gpiofind "${gpio_name}")
}

set_gpio() {
	gpio_name=$1
	gpio_value=$2

	# shellcheck disable=SC2046
	gpioset $(gpiofind "${gpio_name}")="${gpio_value}"
}

power_status() {
	st=$(get_gpio ps-pwr-ok)
	if [ "${st}" = "1" ]; then
		busctl set-property xyz.openbmc_project.State.Chassis \
			/xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis \
			CurrentPowerState s "xyz.openbmc_project.State.Chassis.PowerState.On"

		echo "on"
	else
		busctl set-property xyz.openbmc_project.State.Chassis \
			/xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis \
			CurrentPowerState s "xyz.openbmc_project.State.Chassis.PowerState.Off"

		echo "off"
	fi
}

shutdown_ack() {
	# The shutdown ack signal from the host (via the CPLD) is used to indicate
	# to the BMC that the host would like to power off the system.
	if [ -f "/run/openbmc/host@0-softpoweroff" ]; then
		echo "Shutdown ACK signal received: host has shut down."
		touch /run/openbmc/host@0-softpoweroff-shutdown-ack
	else
		echo "Shutdown ACK signal received: host requested to turn off power."
		set_gpio control-power-n 0
		sleep 6
		set_gpio control-power-n 1
	fi

	# Ensure that the power state transitions to power off properly.
	# Calling power_status will also call PSM to set CurrentPowerState to off.
	st=$(power_status)
	if [ "${st}" = "on" ]; then
		echo "ps-pwr-ok still returns on... Shutdown failed."
		exit 1
	fi
}

reset_ack() {
	set_gpio host0-sysreset-n 0
	sleep 0.2
	set_gpio host0-sysreset-n 1
}

soft_off() {
	# Trigger host shutdown request
	touch "${HOST_SHUTDOWN_IN_PROGRESS_FILE}"
	set_gpio host0-shd-req-n 0
	sleep 1s
	set_gpio host0-shd-req-n 1

	echo "Sent shutdown request to host. Waiting for shutdown ACK signal."
	cnt="${HOST_SHUTDOWN_TIMEOUT_SECONDS}"
	while [ $cnt -gt 0 ];
	do
		# Wait for shutdown ACK. shutdown_ack() will create the host@0-softpoweroff-shutdown-ack file
		if [ -f "${HOST_SHUTDOWN_ACK_FILE}" ]; then
			# Host has completed shutting down
			break
		fi
		sleep 1
		cnt=$((cnt - 1))
	done

	if [ $cnt -gt 0 ]; then
		# Soft poweroff is successful
		echo "Host indicated it finished shutting down after ${cnt}s."
		rm -f "${HOST_SHUTDOWN_IN_PROGRESS_FILE}"
		if [ ! -f "${HOST_SHUTDOWN_ACK_FILE}" ]; then
			echo "WARNING: host shutdown ack file doesn't exist."
		fi
		rm -f "${HOST_SHUTDOWN_ACK_FILE}"
		set_gpio control-power-n 0
		sleep 6
		set_gpio control-power-n 1
	else
		echo "Soft poweroff was unsuccessful. Host failed to indicate having finished shutting down in ${HOST_SHUTDOWN_TIMEOUT_SECONDS}s."
		exit 1
	fi
}

force_reset() {
	if [ -f "${HOST_SHUTDOWN_IN_PROGRESS_FILE}" ]; then
		# In graceful host reset, after triggering OS shutdown,
		# the phosphor-state-manager will call force-warm-reset
		# In this case the force_reset should wait for shutdown_ack from the host
		echo "Waiting for host to shut down before rebooting."
		cnt="${HOST_SHUTDOWN_TIMEOUT_SECONDS}"
		while [ $cnt -gt 0 ];
		do
			if [ -f "${HOST_SHUTDOWN_ACK_FILE}" ]; then
				# Host has finished shutting down
				break
			fi
			echo "Waiting for shutdown ACK: ${cnt}s remaining"
			sleep 1
			cnt=$((cnt - 1))
		done
		# The host OS failed to shutdown
		if [ $cnt = 0 ]; then
			echo "Shutdown ACK timed out after ${HOST_SHUTDOWN_TIMEOUT_SECONDS}s."
			exit 1
		else
			echo "Host has finished shutting down."
		fi
	fi
	echo "Rebooting the host."
	set_gpio host0-sysreset-n 0
	sleep 1
	set_gpio host0-sysreset-n 1
}

force_off() {
	echo "Force power off the host."
	set_gpio control-power-n 0
	sleep 6
	set_gpio control-power-n 1
}

host_reboot_wa() {
	busctl set-property xyz.openbmc_project.State.Chassis \
		/xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis \
		RequestedPowerTransition s "xyz.openbmc_project.State.Chassis.Transition.Off"

	while ( true )
	do
		if systemctl status obmc-power-off@0.target | grep "Active: active"; then
			break
		fi
		sleep 2
	done
	echo "The power is already Off."

	busctl set-property xyz.openbmc_project.State.Host \
		/xyz/openbmc_project/state/host0 xyz.openbmc_project.State.Host \
		RequestedHostTransition s "xyz.openbmc_project.State.Host.Transition.On"
}

if [ $# -lt 1 ]; then
	echo "Insufficient number of parameters"
	usage
	exit 1
fi

mkdir -p /run/openbmc/

if [ "$1" == "shutdown_ack" ]; then
	shutdown_ack
elif [ "$1" == "reset_ack" ]; then
	reset_ack
elif [ "$1" == "status" ]; then
	power_status
elif [ "$1" == "force_reset" ]; then
	force_reset
elif [ "$1" == "host_reboot_wa" ]; then
	host_reboot_wa
elif [ "$1" == "soft_off" ]; then
	soft_off
elif [ "$1" == "force_off" ]; then
  force_off
else
	echo "Invalid parameter"
	usage
fi

exit 0
