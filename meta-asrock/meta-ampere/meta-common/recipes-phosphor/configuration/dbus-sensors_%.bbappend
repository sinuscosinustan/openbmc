# TODO: re-add intrusionsensor once GPIO line name is configurable in entity-manager
PACKAGECONFIG:remove = " intelcpusensor ipmbsensor intrusionsensor"
PACKAGECONFIG:append = " nvmesensor"
