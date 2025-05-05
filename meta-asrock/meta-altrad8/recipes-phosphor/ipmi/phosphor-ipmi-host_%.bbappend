FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " dynamic-storages-only arm-sbmr"

DEPENDS:append = " altrad8-yaml-config"

EXTRA_OEMESON = " \
                -Dsensor-yaml-gen=${STAGING_DIR_HOST}${datadir}/altrad8-yaml-config/ipmi-sensors.yaml \
                -Dfru-yaml-gen=${STAGING_DIR_HOST}${datadir}/altrad8-yaml-config/ipmi-fru-read.yaml \
               "

