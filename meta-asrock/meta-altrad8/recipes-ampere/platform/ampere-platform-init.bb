SUMMARY = "Phosphor OpenBMC ALTRAD8 Platform Init Service"
DESCRIPTION = "Phosphor OpenBMC ALTRAD8 Platform Init Daemon"

PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit systemd
inherit obmc-phosphor-systemd

S = "${UNPACKDIR}"

DEPENDS += "systemd"
RDEPENDS:${PN} += "libsystemd"
RDEPENDS:${PN} += "bash"

SRC_URI = " \
    file://ampere_platform_init.sh \
    file://altrad8_platform_gpios_init.sh \
    file://ampere-platform-init.service \
    "

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "ampere-platform-init.service"

do_install () {
    install -d ${D}${sbindir}
    install -m 0755 ${UNPACKDIR}/ampere_platform_init.sh ${D}${sbindir}/
    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${UNPACKDIR}/ampere-platform-init.service ${D}${systemd_unitdir}/system
    install -m 0755 ${UNPACKDIR}/altrad8_platform_gpios_init.sh ${D}${sbindir}/platform_gpios_init.sh
}
