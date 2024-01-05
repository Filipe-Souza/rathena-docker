FROM debian:buster-20231030 as compiler

LABEL org.opencontainers.image.source = "https://github.com/Filipe-Souza/rathena-docker"
LABEL org.opencontainers.image.description="Contains a rAthena compilation environment."

USER root

RUN apt-get update -y -qq \
  && apt-get install git make libmariadb-dev libmariadbclient-dev libmariadbclient-dev-compat gcc g++ zlib1g-dev libpcre3-dev nano autoconf -y \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /app

WORKDIR /app

RUN git clone https://github.com/rathena/rathena.git . \
    && rm -rf .git

COPY ./rathena-mods/src/custom/defines_pre.hpp src/custom/defines_pre.hpp
COPY ./rathena-mods/src/config/core.hpp src/config/core.hpp
COPY ./rathena-mods/src/config/packets.hpp src/config/packets.hpp

RUN ./configure && make server -j 6

RUN chmod a+x login-server char-server map-server web-server

FROM debian:buster-20231030 AS release

LABEL org.opencontainers.image.source = "https://github.com/Filipe-Souza/rathena-docker"
LABEL org.opencontainers.image.description="Contains a rAthena release environment, with the binaries."

RUN apt-get update -y \
    && apt-get install libmariadb-dev libmariadbclient-dev libmariadbclient-dev-compat zlib1g-dev libpcre3-dev -y \
    && mkdir -p /opt/rathena

WORKDIR /opt/rathena

COPY --from=compiler /app/*-server /opt/rathena
COPY --from=compiler /app/db /opt/rathena/db
COPY --from=compiler /app/conf /opt/rathena/conf
COPY --from=compiler /app/npc /opt/rathena/npc

EXPOSE 6900 6121 5121
