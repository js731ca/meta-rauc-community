# hack... hack...
# to get the new "bootloader=raspberrypi"
# Track the rebased Rtone/rauc PR by pinned commit; nobranch=1 keeps the fetch
# working if upstream force-pushes the branch again (as it did off f6b5f54b).
SRC_URI = "git://github.com/Rtone/rauc.git;protocol=https;nobranch=1"
SRCREV = "a574bcfcff7330982b12dc1bdab08df82d668feb"
LIC_FILES_CHKSUM = "file://COPYING;md5=4bf661c1e3793e55c8d1051bc5e0ae21"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append := "  \
	file://rauc-grow-data-partition.service \
"

# additional dependencies required to run RAUC on the target
#RDEPENDS:${PN} += "u-boot-fw-utils u-boot-env"
RDEPENDS:${PN} += "raspi-utils"

inherit systemd

SYSTEMD_PACKAGES += "${PN}-grow-data-part"
SYSTEMD_SERVICE:${PN}-grow-data-part = "rauc-grow-data-partition.service"

PACKAGES += "rauc-grow-data-part"

RDEPENDS:${PN}-grow-data-part += "parted"

do_install:append() {
	install -d ${D}${systemd_unitdir}/system/
	install -m 0644 ${UNPACKDIR}/rauc-grow-data-partition.service ${D}${systemd_unitdir}/system/
}
