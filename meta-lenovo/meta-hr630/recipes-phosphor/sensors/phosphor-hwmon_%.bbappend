FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
EXTRA_OEMESON:append:hr630 = " -Dnegative-errno-on-fail=true"

CHIPS = " \
        bus@1e78a000/i2c-bus@40/tmp75@4e \
        bus@1e78a000/i2c-bus@80/tmp75@4d \
        pwm-tacho-controller@1e786000 \
        "
ITEMSFMT = "ahb/apb/{0}.conf"

ITEMS = "${@compose_list(d, 'ITEMSFMT', 'CHIPS')}"
ITEMS += "iio-hwmon.conf"

ENVS = "obmc/hwmon/{0}"
SYSTEMD_ENVIRONMENT_FILE:${PN}:append:hr630 := "${@compose_list(d, 'ENVS', 'ITEMS')}"
