FILESEXTRAPATHS:prepend:x470d4u := "${THISDIR}/${PN}:"

SRC_URI:append:x470d4u = " file://led-group-config.json"

do_install:append:x470d4u() {
        install -m 0644 ${WORKDIR}/led-group-config.json ${D}${datadir}/phosphor-led-manager/
}
