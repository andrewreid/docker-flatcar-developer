ARG IMAGE_REPO=ghcr.io/andrewreid/flatcar-developer
ARG FLATCAR_VERSION=latest
FROM ${IMAGE_REPO}:${FLATCAR_VERSION}

ARG FLATCAR_VERSION
ARG FLATCAR_BUILD=unknown
ARG FLATCAR_TRACK=stable
ARG SOURCE_REPO=https://github.com/andrewreid/flatcar-developer
ARG SOURCE_REF=main
ARG REVISION=unknown
ARG CREATED=1970-01-01T00:00:00Z
ARG IMAGE_TITLE=flatcar-developer

LABEL maintainer="Andrew Reid <andrew@reid.ee>" \
    org.opencontainers.image.title="${IMAGE_TITLE}" \
    org.opencontainers.image.description="Flatcar developer container image with bundled build dependencies and sources." \
    org.opencontainers.image.source="${SOURCE_REPO}" \
    org.opencontainers.image.url="${SOURCE_REPO}" \
    org.opencontainers.image.version="${FLATCAR_VERSION}" \
    org.opencontainers.image.revision="${REVISION}" \
    org.opencontainers.image.created="${CREATED}" \
    org.opencontainers.image.ref.name="${SOURCE_REF}" \
    org.opencontainers.image.authors="Andrew Reid <andrew@reid.ee>"

# Create a Flatcar Linux Developer image as defined in:
# https://docs.flatcar-linux.org/os/kernel-modules/

RUN emerge-gitclone \
    && export $(cat /usr/share/coreos/release | xargs) \
    && export OVERLAY_VERSION="${FLATCAR_TRACK}-${FLATCAR_VERSION}" \
    && export PORTAGE_VERSION="${FLATCAR_TRACK}-${FLATCAR_VERSION}" \
    && env \
    && git -C /var/lib/portage/coreos-overlay checkout "tags/$OVERLAY_VERSION" \
    && git -C /var/lib/portage/portage-stable checkout "tags/$PORTAGE_VERSION"

# try to use pre-built binaries and fall back to building from source
RUN emerge -gKq --jobs 4 --load-average 4 coreos-sources || echo "failed to download binaries, fallback build from source:" && emerge -q --jobs 4 --load-average 4 coreos-sources

# Prepare the filesystem
# KERNEL_VERSION is determined from kernel source, not running kernel.
# see https://superuser.com/questions/504684/is-the-version-of-the-linux-kernel-listed-in-the-source-some-where
RUN cp /usr/lib64/modules/$(ls /usr/lib64/modules)/build/.config /usr/src/linux/ \
    && make -C /usr/src/linux modules_prepare \
    && cp /usr/lib64/modules/$(ls /usr/lib64/modules)/build/Module.symvers /usr/src/linux/
