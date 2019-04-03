FROM ubuntu:18.04

ARG repository="deb http://repo.yandex.ru/clickhouse/deb/stable/ main/"
ARG version=\*

RUN apt-get update && \
    apt-get install -y apt-transport-https dirmngr && \
    mkdir -p /etc/apt/sources.list.d && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv E0C56BD4 && \
    echo $repository | tee /etc/apt/sources.list.d/clickhouse.list && \
    apt-get update && \
    apt-get install --allow-unauthenticated -y "clickhouse-server|clickhouse-server-common=$version" libgcc-7-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/debconf && \
    apt-get clean
COPY users.xml /etc/clickhouse-server/users.xml
COPY docker_related_config.xml /etc/clickhouse-server/config.d/
RUN chown -R clickhouse /etc/clickhouse-server/
COPY data/clickhouse.tar.gz /var/lib/clickhouse.tar.gz
RUN tar xzvf /var/lib/clickhouse.tar.gz -C /var/lib/
RUN chown -R clickhouse. /var/lib/clickhouse/
RUN rm -f /var/lib/clickhouse.tar.gz

USER clickhouse
EXPOSE 9000 8123 9009
VOLUME /var/lib/clickhouse

ENV CLICKHOUSE_CONFIG /etc/clickhouse-server/config.xml

ENTRYPOINT exec /usr/bin/clickhouse-server --config=${CLICKHOUSE_CONFIG}
