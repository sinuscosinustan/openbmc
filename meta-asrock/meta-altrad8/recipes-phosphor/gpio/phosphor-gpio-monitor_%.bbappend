FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

inherit systemd
inherit obmc-phosphor-systemd

RDEPENDS:${PN}-monitor += "bash"
RDEPENDS:${PN} += "bash"

SRC_URI += " \
            file://phosphor-multi-gpio-monitor.json \
            file://phosphor-multi-gpio-presence.json \
            file://ampere_scp_failover.sh \
           "

SYSTEMD_SERVICE:${PN}-monitor += " \
                                  ampere-host-reboot@.service \
                                  ampere_scp_failover.service \
                                 "

FILES:${PN}-monitor += " \
                        ${datadir}/${PN}/phosphor-multi-gpio-monitor.json \
                        /usr/sbin/ampere_scp_failover.sh \
                       "

FILES:${PN}-presence += " \
                         ${datadir}/${PN}/phosphor-multi-gpio-presence.json \
                        "

do_install:append() {
    install -d ${D}${sbindir}
    install -m 0644 ${UNPACKDIR}/phosphor-multi-gpio-monitor.json ${D}${datadir}/${PN}/
    install -m 0755 ${UNPACKDIR}/ampere_scp_failover.sh ${D}${sbindir}/
}
