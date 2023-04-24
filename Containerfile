ARG FEDORA_MAJOR_VERSION=38
ARG BASE_CONTAINER_URL=ghcr.io/ublue-os/silverblue-nvidia

FROM fedora-minimal:${FEDORA_MAJOR_VERSION} as builder
COPY ${RECIPE} /tmp/ublue-recipe.yml
COPY --from=docker.io/mikefarah/yq /usr/bin/yq /usr/bin/yq
COPY build-rpms.sh /tmp/build-rpms.sh
RUN chmod +x /tmp/build-rpms.sh && /tmp/build-rpms.sh

FROM ${BASE_CONTAINER_URL}:${FEDORA_MAJOR_VERSION}
ARG RECIPE

# copy over configuration files
COPY etc /etc
COPY usr /usr
COPY rpm /tmp/rpm

COPY ${RECIPE} /tmp/ublue-recipe.yml

# yq used in build.sh and the setup-flatpaks recipe to read the recipe.yml
# copied from the official container image as it's not avaible as an rpm
COPY --from=docker.io/mikefarah/yq /usr/bin/yq /usr/bin/yq

# copy and run the build script
COPY build.sh /tmp/build.sh
RUN chmod +x /tmp/build.sh && /tmp/build.sh

# clean up and finalize container build
RUN rm -rf \
        /tmp/* \
        /var/* && \
    ostree container commit
