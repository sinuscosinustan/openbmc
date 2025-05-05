#!/bin/bash

# Time out checking for Host ON is 60s
cnt=60
while [ "$cnt" -gt 0 ];
do
	cnt=$((cnt - 1))
	if ! gpioget "$(gpiofind host0-ready)"; then
		if command -v ampere_driver_binder.sh;
		then
			ampere_driver_binder.sh
		fi
		exit 0
	fi
	sleep 1
done

exit 1
