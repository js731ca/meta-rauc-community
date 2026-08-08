FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# The default single cmdline.txt is unused: the RPi firmware selects a per-slot
# cmdline via the [boot_partition=N] filter in config.txt (see rpi-config
# bbappend), so leave CMDLINE_ROOTFS empty here; the per-slot root bits are
# appended to the full CMDLINE below.
CMDLINE_ROOTFS = ""

# Per-slot root/boot command-line bits, appended to the full CMDLINE. Partition
# indexes depend on the image layout, so override these per-machine/image.
CMDLINE_ROOTFS_A ?= "root=/dev/mmcblk0p5 ${CMDLINE_ROOT_FSTYPE} rootwait systemd.mount-extra=/dev/mmcblk0p2:/boot:vfat rauc.slot=firmware.0"
CMDLINE_ROOTFS_B ?= "root=/dev/mmcblk0p6 ${CMDLINE_ROOT_FSTYPE} rootwait systemd.mount-extra=/dev/mmcblk0p3:/boot:vfat rauc.slot=firmware.1"

# Build the per-slot cmdline files from the FULL CMDLINE (so console=,
# net.ifnames=, CMA, dwc_otg, etc. are preserved) plus the per-slot root bits.
do_compile:append () {
    echo "${@' '.join(d.getVar('CMDLINE').split())} ${CMDLINE_ROOTFS_A}" > "${WORKDIR}/cmdline-rootfs-A.txt"
    echo "${@' '.join(d.getVar('CMDLINE').split())} ${CMDLINE_ROOTFS_B}" > "${WORKDIR}/cmdline-rootfs-B.txt"
}

do_deploy:append() {
    install -m 0644 "${WORKDIR}/cmdline-rootfs-A.txt" "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"
    install -m 0644 "${WORKDIR}/cmdline-rootfs-B.txt" "${DEPLOYDIR}/${BOOTFILES_DIR_NAME}"
}
