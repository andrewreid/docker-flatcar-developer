ARG FLATCAR_VERSION
FROM mediadepot/flatcar-developer:${FLATCAR_VERSION}
LABEL maintainer="Jason Kulatunga <jason@thesparktree.com>"
ARG FLATCAR_VERSION
ARG FLATCAR_BUILD

# Create a Flatcar Linux Developer image as defined in:
# https://docs.flatcar-linux.org/os/kernel-modules/

RUN emerge-gitclone \
    && export $(cat /usr/share/coreos/release | xargs) \
    && export OVERLAY_VERSION="flatcar-${FLATCAR_BUILD}" \
    && export PORTAGE_VERSION="flatcar-${FLATCAR_BUILD}" \
    && env \
    && git -C /var/lib/portage/coreos-overlay checkout "$OVERLAY_VERSION" \
    && git -C /var/lib/portage/portage-stable checkout "$PORTAGE_VERSION"

# try to use pre-built binaries and fall back to building from source
RUN emerge -gKq --jobs 4 --load-average 4 coreos-sources || echo "failed to download binaries, fallback build from source:" && emerge -q --jobs 4 --load-average 4 coreos-sources

# Prepare the filesystem
# KERNEL_VERSION is determined from kernel source, not running kernel.
# see https://superuser.com/questions/504684/is-the-version-of-the-linux-kernel-listed-in-the-source-some-where
RUN cp /usr/lib64/modules/$(ls /usr/lib64/modules)/build/.config /usr/src/linux/ \
    && make -C /usr/src/linux modules_prepare
RUN export KERNEL_VERSION=$(cat /usr/src/linux/include/config/kernel.release || ls /lib/modules) \
    && cp /lib/modules/${KERNEL_VERSION}/build/Module.symvers /usr/src/linux/
