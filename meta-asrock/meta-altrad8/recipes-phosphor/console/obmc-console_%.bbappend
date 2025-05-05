FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"
RDEPENDS:${PN} += "bash"

# Declare port specific config files
OBMC_CONSOLE_TTYS = "ttyS1 ttyS2 ttyS3"
CONSOLE_CLIENT = "2200 2201 2202"

SRC_URI += " \
             ${@compose_list(d, 'CONSOLE_SERVER_CONF_FMT', 'OBMC_CONSOLE_TTYS')} \
             ${@compose_list(d, 'CONSOLE_CLIENT_CONF_FMT', 'CONSOLE_CLIENT')} \
             file://ampere_uartmux_ctrl.sh \
             file://ampere_uart_console_setup.sh \
           "

CONSOLE_CLIENT_SERVICE_FMT = "obmc-console-ssh@{0}.service"
CONSOLE_SERVER_CONF_FMT = "file://server.{0}.conf"
CONSOLE_CLIENT_CONF_FMT = "file://client.{0}.conf"

SYSTEMD_SERVICE:${PN}:remove = "obmc-console-ssh.socket"

FILES:${PN}:remove = "${systemd_system_unitdir}/obmc-console-ssh@.service.d/use-socket.conf"

SYSTEMD_SERVICE:${PN}:append = " \
                                  ${@compose_list(d, 'CONSOLE_CLIENT_SERVICE_FMT', 'CONSOLE_CLIENT')} \
                                "


SYSTEMD_SERVICE:${PN}:append = " obmc-console-ssh@2200.service \
                obmc-console-ssh@2201.service \
                obmc-console-ssh@2202.service \
                "


PACKAGECONFIG:append = " concurrent-servers"

do_install:append() {
    # Script to switch host's uart muxes by GPIOs
    install -d ${D}${sbindir}
    install -m 0755 ${UNPACKDIR}/ampere_uartmux_ctrl.sh ${D}/${sbindir}

    # Script to set host's uart muxes to BMC
    install -m 0755 ${UNPACKDIR}/ampere_uart_console_setup.sh ${D}${sbindir}

    # Install the console client configurations
    install -m 0644 ${UNPACKDIR}/client.*.conf ${D}${sysconfdir}/${BPN}
}
