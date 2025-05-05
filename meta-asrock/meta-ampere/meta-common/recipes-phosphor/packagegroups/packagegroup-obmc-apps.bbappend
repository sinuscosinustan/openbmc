RDEPENDS:${PN}-extras:append = " \
                                phosphor-image-signing \
                                phosphor-virtual-sensor \
                                phosphor-misc-usb-ctrl \
                                phosphor-gpio-monitor-monitor \
                                phosphor-gpio-monitor-presence \
                                phosphor-hostlogger \
                                phosphor-sel-logger \
                                phosphor-logging \
                                phosphor-post-code-manager \
                                phosphor-host-postd \
                                phosphor-software-manager \
                                phosphor-state-manager \
                                obmc-phosphor-buttons-signals \
                                obmc-phosphor-buttons-handler \
                                smbios-mdr \
                               "

RDEPENDS:${PN}-inventory:append = " \
                                   entity-manager \
                                  "
