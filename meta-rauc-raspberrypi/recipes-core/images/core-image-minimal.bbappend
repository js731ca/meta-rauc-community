# Store the kernel in the rootfs partition
IMAGE_INSTALL:append = " kernel-image kernel-modules"

# Remove the kernel from the /boot partition because it is in rootfs
RPI_EXTRA_IMAGE_BOOT_FILES:remove = "${KERNEL_IMAGETYPE}"

IMAGE_INSTALL:append = " rpi-eeprom"
IMAGE_INSTALL:append = " rpi-autoboot"
IMAGE_FSTYPES:remove = " ext3"
IMAGE_FSTYPES:append = " ext4"

WKS_FILE = "sdimage-dual-raspberrypi.wks.in"

# the root/boot partitions are passed in as kernel-cmdline parameters
WIC_CREATE_EXTRA_ARGS = " --no-fstab-update"

# Expose wic partition images as RAUC slot sources (the bundle picks the ones it
# names).
# Note: a blanket "deploy every partition" loop is avoided on purpose
# - the rootfs A/B partitions are fixed-size (multiple GB), and the
# rootfs slot is bundled from the content-sized .ext4, so only the
# partitions the bundle actually references are deployed.
# see: https://github.com/gportay/meta-downstream/blob/master/meta-rauc-raspberrypi-firmware/recipes-core/images/core-image-minimal.bbappend
WIC_DEPLOY_PARTITION_IMAGES ?= "p2 p5"
IMAGE_CMD:wic:append() {
    basename="$(basename "${wks%.wks}")"
    for pnum in ${WIC_DEPLOY_PARTITION_IMAGES}; do
        cp "$build_wic/$basename-"*".direct.$pnum" "$out-$pnum.img"
        ln -sf "${IMAGE_NAME}-$pnum.img" "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}-$pnum.img"
    done
}
