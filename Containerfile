FROM ubuntu:26.04 AS source

ADD --checksum=sha256:aa0b2a009552f5e7c50baabf361267a79ea5e5c0fea440786f3b202d51f57753 \
    https://github.com/flightlessmango/MangoHud/releases/download/v0.8.4/MangoHud-0.8.4.r0.g992103e.tar.gz \
    /tmp/mangohud.tar.gz

WORKDIR /tmp/MangoHud

RUN tar -xzf /tmp/mangohud.tar.gz -C /tmp && \
    tar -xf MangoHud-package.tar && \
    ./mangohud-setup.sh install && \
    sed -i 's|MANGOHUD_LIB_NAME="/usr/lib|MANGOHUD_LIB_NAME="${CPAK_ROOTFS:-}/usr/lib|' /usr/bin/mangohud && \
    sed -i 's|"/usr/lib/mangohud|"../../../lib/mangohud|' \
        /usr/share/vulkan/implicit_layer.d/MangoHud.x86.json \
        /usr/share/vulkan/implicit_layer.d/MangoHud.x86_64.json

FROM ghcr.io/containerpak/wine:main

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends libxkbcommon0:i386 && \
    cpak-clean-junk

COPY --from=source /usr/bin/mangohud /usr/bin/mangohud
COPY --from=source /usr/bin/mangoplot /usr/bin/mangoplot
COPY --from=source /usr/lib/mangohud /usr/lib/mangohud
COPY --from=source /usr/share/doc/mangohud /usr/share/doc/mangohud
COPY --from=source /usr/share/vulkan/implicit_layer.d/MangoHud.x86.json /usr/share/vulkan/implicit_layer.d/MangoHud.x86.json
COPY --from=source /usr/share/vulkan/implicit_layer.d/MangoHud.x86_64.json /usr/share/vulkan/implicit_layer.d/MangoHud.x86_64.json
