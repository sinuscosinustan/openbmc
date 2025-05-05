FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

EXTRA_OEMESON:append = " \
                         -Dwarm-reboot=enabled \
                       "

# Chassis Config
# TODO: Remove it when 69903 applied
CHASSIS_DEFAULT_TARGETS:remove = " \
    obmc-chassis-powerreset@{}.target.requires/phosphor-reset-chassis-on@{}.service \
    obmc-chassis-powerreset@{}.target.requires/phosphor-reset-chassis-running@{}.service \
    obmc-chassis-poweroff@{}.target.requires/obmc-power-stop@{}.service \
    obmc-chassis-poweron@{}.target.requires/obmc-power-start@{}.service \
    "

# TODO: Remove it when 69903 applied
CHASSIS_DEFAULT_TARGETS:remove = " \
    obmc-chassis-poweron@{}.target.wants/chassis-poweron@{}.service \
    obmc-chassis-hard-poweroff@{}.target.wants/chassis-poweroff@{}.service \
    obmc-chassis-powercycle@{}.target.wants/chassis-powercycle@{}.service \
    "

# TODO: Remove it when 69903 applied
CHASSIS_DEFAULT_TARGETS:append = " \
    obmc-chassis-poweron@{}.target.requires/chassis-poweron@{}.service \
    obmc-chassis-powercycle@{}.target.requires/chassis-powercycle@{}.service \
    "

# Host Config
# Host Reset
HOST_DEFAULT_TARGETS:remove = " \
    obmc-host-warm-reboot@{}.target.requires/xyz.openbmc_project.Ipmi.Internal.SoftPowerOff.service \
    obmc-host-warm-reboot@{}.target.requires/obmc-host-force-warm-reboot@{}.target \
    obmc-host-force-warm-reboot@{}.target.requires/obmc-host-stop@{}.target \
    obmc-host-force-warm-reboot@{}.target.requires/phosphor-reboot-host@{}.service \
    "

# Host On/Off
HOST_DEFAULT_TARGETS:append = " \
    obmc-host-startmin@{}.target.requires/host-poweron@{}.service \
    "

HOST_DEFAULT_TARGETS:append = " \
    obmc-host-shutdown@{}.target.requires/host-graceful-poweroff@{}.service \
    obmc-host-stop@{}.target.requires/host-force-poweroff@{}.service \
    "

HOST_DEFAULT_TARGETS:remove = " \
    obmc-host-shutdown@{}.target.wants/host-poweroff@{}.service \
    obmc-host-start@{}.target.wants/host-poweron@{}.service \
    "

# Host Cycle
HOST_DEFAULT_TARGETS:remove = " \
    obmc-host-reboot@{}.target.wants/host-powercycle@{}.service \
    obmc-host-reboot@{}.target.requires/obmc-host-shutdown@{}.service \
    "

# We need to ensure that the chassis power is always on.
CHASSIS_DEFAULT_TARGETS:remove = " \
    obmc-host-shutdown@{}.target.requires/obmc-chassis-poweroff@{}.target \
    "

SYSTEMD_SERVICE:${PN}-chassis:remove = "phosphor-reset-chassis-on@.service"
SYSTEMD_SERVICE:${PN}-chassis:remove = "phosphor-reset-chassis-running@.service"
SYSTEMD_SERVICE:${PN}-chassis:remove = "obmc-power-start@.service"
SYSTEMD_SERVICE:${PN}-chassis:remove = "obmc-power-stop@.service"

SRC_URI:append = " \
    file://ampere-state-helpers \
    file://chassis-poweroff@.service \
    file://chassis-poweron@.service \
    file://chassis-poweron-failure@.service \
    file://chassis-powercycle@.service \
    file://host-force-poweroff@.service \
    file://host-graceful-poweroff@.service \
    file://host-poweron@.service \
    file://host-poweron-failure@.service \
    file://host-powercycle@.service \
    file://chassis-poweroff \
    file://chassis-poweron \
    file://chassis-poweron-failure \
    file://chassis-powercycle \
    file://host-graceful-poweroff \
    file://host-force-poweroff \
    file://host-poweron \
    file://host-poweron-failure \
    file://host-powercycle \
    file://phosphor-wait-power-off@.service \
    file://policy-chassis-poweron \
    file://policy-chassis-poweron@.service \
    "

RDEPENDS:${PN}:append = " bash"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${UNPACKDIR}/*.service ${D}${systemd_system_unitdir}/

    install -d ${D}${libexecdir}/${PN}
    install -m 0755 ${UNPACKDIR}/ampere-state-helpers ${D}${libexecdir}/${PN}/
    install -m 0755 ${UNPACKDIR}/chassis-poweroff ${D}${libexecdir}/${PN}/
    install -m 0755 ${UNPACKDIR}/chassis-poweron ${D}${libexecdir}/${PN}/
    install -m 0755 ${UNPACKDIR}/chassis-poweron-failure ${D}${libexecdir}/${PN}/
    install -m 0755 ${UNPACKDIR}/chassis-powercycle ${D}${libexecdir}/${PN}/
    install -m 0755 ${UNPACKDIR}/host-force-poweroff ${D}${libexecdir}/${PN}/
    install -m 0755 ${UNPACKDIR}/host-graceful-poweroff ${D}${libexecdir}/${PN}/
    install -m 0755 ${UNPACKDIR}/host-poweron ${D}${libexecdir}/${PN}/
    install -m 0755 ${UNPACKDIR}/host-poweron-failure ${D}${libexecdir}/${PN}/
    install -m 0755 ${UNPACKDIR}/host-powercycle ${D}${libexecdir}/${PN}/
    install -m 0755 ${UNPACKDIR}/policy-chassis-poweron ${D}${libexecdir}/${PN}/
}

FILES:${PN} += " \
    ${systemd_system_unitdir}/*.service \
    ${systemd_system_unitdir}/*.service.d \
    ${systemd_system_unitdir}/*.service.d/*.conf \
"
