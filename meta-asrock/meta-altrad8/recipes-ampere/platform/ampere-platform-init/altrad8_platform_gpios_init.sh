#!/bin/bash

function pre-platform-init() {
    echo "Do pre platform init"
}


function post-platform-init() {
    echo "Do post platform init"
}

export output_high_gpios_in_ac=(
    "i2c-backup-sel"
    "host0-shd-req-n"
    "host0-sysreset-n"
    "power-chassis-good"
)

export output_low_gpios_in_ac=(
    "spi0-program-sel"
    "s0-rtc-lock"
    "host0-special-boot"
    "ps-atx-on-n"
)

export input_gpios_in_ac=(
    "s0-spi-auth-fail-n"
    "s0-vr-hot-n"
    "ps-pwr-ok"
)

export output_high_gpios_in_bmc_reboot=(
    "i2c-backup-sel"
)

export output_low_gpios_in_bmc_reboot=(
    "bmc-ready"
    "bmc-ok"
)

export input_gpios_in_bmc_reboot=(
    "bmc-salt2-n"
)
