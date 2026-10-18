# Builds AzerothCore with custom modules compiled in. Adapted from
# apps/docker/Dockerfile upstream, which has no hook for extra modules.
ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION} AS build

ARG DEBIAN_FRONTEND=noninteractive
ARG AC_REF
ARG MOD_GUILD_DISCORD_REF=master
ARG CTYPE=RelWithDebInfo

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential ccache libtool cmake ninja-build clang \
        git ca-certificates curl unzip default-mysql-client openssl \
        default-libmysqlclient-dev libboost-all-dev libssl-dev libmysql++-dev \
        libreadline-dev zlib1g-dev libbz2-dev libncurses5-dev liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /azerothcore

# Fetch by ref so both commit SHAs and branches work; .git is required by the cmake revision check.
RUN test -n "$AC_REF" \
    && git init -q . \
    && git remote add origin https://github.com/azerothcore/azerothcore-wotlk.git \
    && git fetch -q --depth 1 origin "$AC_REF" \
    && git checkout -q FETCH_HEAD

RUN git init -q modules/mod-guild-discord \
    && git -C modules/mod-guild-discord remote add origin https://github.com/locus313/mod-guild-discord.git \
    && git -C modules/mod-guild-discord fetch -q --depth 1 origin "$MOD_GUILD_DISCORD_REF" \
    && git -C modules/mod-guild-discord checkout -q FETCH_HEAD

WORKDIR /azerothcore/build

RUN --mount=type=cache,target=/ccache,sharing=locked \
    git config --global --add safe.directory /azerothcore \
    && CCACHE_DIR=/ccache cmake /azerothcore \
       -G Ninja \
       -DCMAKE_INSTALL_PREFIX=/azerothcore/env/dist \
       -DAPPS_BUILD=all \
       -DTOOLS_BUILD=db-only \
       -DSCRIPTS=static \
       -DMODULES=static \
       -DCMAKE_BUILD_TYPE="$CTYPE" \
       -DCMAKE_CXX_COMPILER=clang++ \
       -DCMAKE_C_COMPILER=clang \
       -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
       -DCMAKE_C_COMPILER_LAUNCHER=ccache \
       -DBoost_USE_STATIC_LIBS=ON \
    && CCACHE_DIR=/ccache cmake --build . --config "$CTYPE" -j "$(($(nproc) + 1))" \
    && cmake --install . --config "$CTYPE"

FROM ubuntu:${UBUNTU_VERSION} AS runtime

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=America/Los_Angeles
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG DOCKER_USER=acore

ENV ACORE_COMPONENT=undefined
ENV PATH="/azerothcore/env/dist/bin:$PATH"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        tzdata ca-certificates libmysqlclient21 libreadline8 libicu74 \
        libncurses5-dev gettext-base default-mysql-client adduser \
    && ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /azerothcore/env/dist/etc /azerothcore/env/dist/logs \
        /azerothcore/env/dist/temp /azerothcore/env/dist/data \
    && userdel --remove ubuntu \
    && addgroup --gid "$GROUP_ID" "$DOCKER_USER" \
    && adduser --disabled-password --gecos '' --uid "$USER_ID" --gid "$GROUP_ID" "$DOCKER_USER" \
    && chown -R "$DOCKER_USER:$DOCKER_USER" /azerothcore

WORKDIR /azerothcore

COPY --from=build /azerothcore/env/dist/etc/ /azerothcore/env/ref/etc
COPY --from=build --chown=$USER_ID:$GROUP_ID --chmod=755 \
     /azerothcore/apps/docker/entrypoint.sh /azerothcore/entrypoint.sh

USER $DOCKER_USER

ENTRYPOINT ["/usr/bin/env", "bash", "/azerothcore/entrypoint.sh"]

FROM runtime AS authserver
ENV ACORE_COMPONENT=authserver \
    AC_UPDATES_ENABLE_DATABASES=0 \
    AC_DISABLE_INTERACTIVE=1 \
    AC_CLOSE_IDLE_CONNECTIONS=0
COPY --from=build --chown=$DOCKER_USER:$DOCKER_USER \
     /azerothcore/env/dist/bin/authserver /azerothcore/env/dist/bin/authserver
CMD ["authserver"]

FROM runtime AS worldserver
ENV ACORE_COMPONENT=worldserver \
    AC_UPDATES_ENABLE_DATABASES=0 \
    AC_DISABLE_INTERACTIVE=1 \
    AC_CLOSE_IDLE_CONNECTIONS=0
COPY --from=build --chown=$DOCKER_USER:$DOCKER_USER \
     /azerothcore/env/dist/bin/worldserver /azerothcore/env/dist/bin/worldserver
CMD ["worldserver"]

FROM runtime AS db-import
ENV ACORE_COMPONENT=dbimport
COPY --from=build --chown=$DOCKER_USER:$DOCKER_USER /azerothcore/data data
COPY --from=build --chown=$DOCKER_USER:$DOCKER_USER /azerothcore/modules modules
COPY --from=build --chown=$DOCKER_USER:$DOCKER_USER \
     /azerothcore/env/dist/bin/dbimport /azerothcore/env/dist/bin/dbimport
CMD ["dbimport"]

FROM runtime AS client-data
ENV DATAPATH=/azerothcore/env/dist/data
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl unzip \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build --chown=$DOCKER_USER:$DOCKER_USER /azerothcore/apps apps
USER $DOCKER_USER
ENTRYPOINT []
CMD ["bash", "-c", "source /azerothcore/apps/installer/includes/functions.sh && inst_download_client_data"]
