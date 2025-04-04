ASRock Rack X470D4U
===================

# Introduction

The ASRock Rack X470D4U is a microATX motherboard designed for AMD Ryzen Zen 3
processors. It has four DIMM slots supporting up to 128GB of DDR4 memory and
supports Unbuffered ECC memory.

# Available boards

- X470D4U (32MB SPI flash) - **TESTED**
- X470D4U2-2T (32MB SPI flash) - **UNTESTED**
- X470D4U2/1N1 (64MB SPI flash) - **TESTED**

# Switching between 32MB and 64MB SPI flash

The X470D4U2/1N1 board has a 64MB SPI flash chip, while the other two
boards have a 32MB SPI flash chip. By default, both the 32M, as well as
the 64M use the 32M layout to reduce the code complexity. The 64M image
only uses the first 32M and fills the remaining space with `FF`.

ASRock Rack usually sockets the SPI flash chip instead of soldering
them to the board. This means, you can easily swap the chips out if
you want to use a 64MB SPI flash chip on a 32MB board however, it currently has
no benefit (except the user modifies the device-tree and removes the custom
overrides).

The following chips have been tested and are known to work and are also
used by ASRock Rack regularly:

- Winbond W25Q256JV (32MB)
- Winbond W25Q512JV (64MB)
- Macronix MX25L51245GMJ (64MB)

By default, the machine config includes a file called `32-spi.inc` or
`64-spi.inc` that sets the correct flash size for the `static.mtd` artifact.

# Notes on migrating from MegaRAC SP-X to OpenBMC

**IMPORTANT**: OpenBMC is not officially supported for this board
by ASRock Rack. The OpenBMC port is a community effort and should be
considered as such. This means, you may not receive any support by
ASRock Rack anymore and not all features are available.

Always double check the type of the board you are using. The
1N1 version uses a 64MB SPI flash chip, while the other two use
a 32MB SPI flash chip. The flash is located under the AST2500 SoC (next to
the `MFG_N` jumper).

The SoCFlash and culvert methods only work if the BMC runs MegaRAC SP-X
and has not been flashed with OpenBMC before. If you have already
flashed OpenBMC and want to revert back to MegaRAC SP-X, you either have
to swap out the SPI flash chip or log into the BMC and set the required
bits in the registers. We will not cover this here, as this is not the
intended use case.

# Feature list

Marked features are supported and tested, unmarked features are not
supported. Features that are incompletely supported are marked with
a special note.

- [X] Power Management
- [X] External Power button power on/off
- [X] Error Reporting (via Phosphor Log Manager)
- [X] SOL
- [X] Virtual Media
- [X] Code Update
  * [X] BIOS
  * [X] BMC
- [X] Sensors (not IPMI SDR / IPMI sensors)
- [X] LEDs
- [ ] System Inventory
  * **NOTE**: For more information on why the system inventory is not
  supported, please refer to the [System Inventory](#system-inventory)
  section.
- [ ] Cooling
  * Still needs some work, right now all fans are running at 100%
- [X] Remote KVM

# Known limitations and issues

## System Inventory

The system inventory is being realised on a very special way. The
AMI BIOS sends a POST to the BMC via the USB gadget interface that
contains the raw SMBIOS. This method is not supported by OpenBMC.

## System needs long to start

The UEFI waits 5 minutes during POST until the KCS interface is
available, but this does not become reliabily available.

This issue is still under investigation and may be fixed in the future.
From a first perspective, it seems that some LPC-related register bits are
not being set correctly.
