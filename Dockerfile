FROM debian:buster-20231030 as compiler

LABEL org.opencontainers.image.source = "https://github.com/Filipe-Souza/rathena-helm"

USER root

ARG PACKET_VER=20211103

RUN apt-get update -y -qq && \
  apt-get install git make libmariadb-dev libmariadbclient-dev libmariadbclient-dev-compat gcc g++ zlib1g-dev libpcre3-dev nano autoconf -y -qq

RUN git clone https://github.com/rathena/rathena.git ~/rAthena

COPY ./rathena-mods/src/custom/defines_pre.hpp ~/rAthena/src/custom/defines_pre.hpp
COPY ./rathena-mods/src/config/core.hpp ~/rAthena/src/config/core.hpp
COPY ./rathena-mods/src/config/packets.hpp ~/rAthena/src/config/packets.hpp

RUN cd ~/rAthena && ./configure --enable-packetver=$PACKET_VER && make server -j 6

RUN chmod a+x ~/rAthena/login-server && chmod a+x ~/rAthena/char-server && chmod a+x ~/rAthena/map-server && chmod a+x ~/rAthena/web-server

FROM debian:buster-20231030 AS release

RUN apt-get update -y && \
  apt-get install libmariadb-dev libmariadbclient-dev libmariadbclient-dev-compat zlib1g-dev libpcre3-dev -y

RUN mkdir -p /opt/rathena

WORKDIR /opt/rathena

COPY --from=compiler /root/rAthena/*-server /opt/rathena
COPY --from=compiler /root/rAthena/db /opt/rathena/db
COPY --from=compiler /root/rAthena/conf /opt/rathena/conf
COPY --from=compiler /root/rAthena/npc /opt/rathena/npc

EXPOSE 6900 6121 5121
