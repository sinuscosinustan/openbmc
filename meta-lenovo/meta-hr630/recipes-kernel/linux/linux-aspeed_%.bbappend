# Copyright (c) 2019-present Lenovo
# Licensed under BSD-3, see COPYING.BSD file for details.

FILESEXTRAPATHS:prepend:hr630 := "${THISDIR}/${PN}:"
SRC_URI:append:hr630 = " file://hr630.cfg"
