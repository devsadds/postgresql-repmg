ARG BASE_IMAGE
FROM ${BASE_IMAGE}
LABEL maintainer "Bitnami <containers@bitnami.com>"

ENV HOME="/" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux" \
    DEBIAN_FRONTEND=noninteractive \
    BITNAMI_APP_NAME="postgresql-repmgr" \
    BITNAMI_IMAGE_VERSION="12.4.0-debian-10-r49" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    NSS_WRAPPER_LIB="/opt/bitnami/common/lib/libnss_wrapper.so" \
    PATH="/opt/bitnami/postgresql/bin:/opt/bitnami/repmgr/bin:/opt/bitnami/common/bin:$PATH" \
    CONSUL_VERSION="1.8.4"
COPY prebuildfs /

RUN install_packages acl ca-certificates unzip curl gzip libbsd0 libc6 libedit2 libffi6 libgcc1 libgmp10 libgnutls30 libhogweed4 libicu63 libidn2-0 libldap-2.4-2 liblzma5 libnettle6 libp11-kit0 libsasl2-2 libsqlite3-0 libssl1.1 libstdc++6 libtasn1-6 libtinfo6 libunistring2 libuuid1 libxml2 libxslt1.1 locales procps tar zlib1g apt-transport-https iproute2 net-tools iputils-ping \
&& . /opt/bitnami/scripts/libcomponent.sh  \
&& component_unpack "postgresql-repmgr" "12.4.0-2" --checksum 7e36972cf465c6f7bec91c9758d34857c40efc1f5b97135d434d35bc2fafc8b1 \
&& . /opt/bitnami/scripts/libcomponent.sh \
&& component_unpack "gosu" "1.12.0-1" --checksum 51cfb1b7fd7b05b8abd1df0278c698103a9b1a4964bdacd87ca1d5c01631d59c \
&& apt-get update && apt-get upgrade -y \
&& rm -r /var/lib/apt/lists /var/cache/apt/archives \
&& chmod g+rwX /opt/bitnami \
&& localedef -c -f UTF-8 -i en_US en_US.UTF-8 \
&& update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
&& DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
&& echo 'en_GB.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen \
&& echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen \
&& echo 'ru_RU.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen \
&& mkdir -p /temp/ \
&& cd /temp/ \
&& curl https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -o /temp/consul_${CONSUL_VERSION}_linux_amd64.zip \
&& unzip -d /bin consul_${CONSUL_VERSION}_linux_amd64.zip \
&& chmod +x -v /bin/consul \
&& rm -rf /temp
COPY rootfs /

RUN /opt/bitnami/scripts/postgresql-repmgr/postunpack.sh \
&& /opt/bitnami/scripts/locales/add-extra-locales.sh

COPY files/pgscripts /pgscripts/
COPY files/configs/bitnami/postgres/conf.d /opt/bitnami/postgresql/conf/conf.d
COPY files/bashrc_alias.sh /usr/sbin/bashrc_alias.sh
COPY files/initbash_profile.sh /usr/sbin/initbash_profile
COPY files/docker-entrypoint.d /docker-entrypoint.d/
RUN chmod +x  /usr/sbin/bashrc_alias.sh /usr/sbin/initbash_profile \
    && sed -i '/postgresql_custom_init_scripts/a bash /docker-entrypoint.d/consul_agent.sh' /opt/bitnami/scripts/librepmgr.sh \
    && sed -i '/Starting repmgrd/a info \"** Start consul agent! **\" ' /opt/bitnami/scripts/postgresql-repmgr/run.sh \
    && sed -i '/Start consul agent/a bash /docker-entrypoint.d/consul_agent.sh & disown' /opt/bitnami/scripts/postgresql-repmgr/run.sh \
    && echo "bash /docker-entrypoint.d/consul_agent.sh" >> /opt/bitnami/repmgr/events/execs/includes/unlock_standby.sh \
    && chmod 777 -R -v /pgscripts/  \
                      /opt/bitnami/scripts/librepmgr.sh \
                      /opt/bitnami/scripts/postgresql-repmgr/run.sh \
                      /opt/bitnami/repmgr/events/execs/includes/unlock_standby.sh \
    && chmod 777 -R /docker-entrypoint.d/ \
    && ls -la /opt/bitnami/postgresql/conf/conf.d/ \
    && /bin/bash -C "/usr/sbin/initbash_profile" \
    && mkdir -p /docker-info.d/ \
    && VERSION_POSTGRES=$(psql --version | awk '{print $NF}') \
    && VERSION_CONSUL=${CONSUL_VERSION} \
    && DOCKER_BUILD_DATA=$(date +%Y_%m_%d_%R_%Z) \
    && DOCKER_BASE_IMAGE="docker.io/bitnami/minideb:buster" \
    && echo "DOCKER_BUILD_DATA=${DOCKER_BUILD_DATA}" > /docker-info.d/build.info \
    && echo "VERSION_POSTGRES=${VERSION_POSTGRES}" >> /docker-info.d/build.info \
    && echo "VERSION_CONSUL=${VERSION_CONSUL}" >> /docker-info.d/build.info \
    && echo "--------Build info----------------" \
    && cat /docker-info.d/build.info \
    && echo "--------Build info----------------" \
    && cat /opt/bitnami/scripts/postgresql-repmgr/run.sh 
USER 1001

EXPOSE 5432

ENTRYPOINT [ "/opt/bitnami/scripts/postgresql-repmgr/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/postgresql-repmgr/run.sh" ]
