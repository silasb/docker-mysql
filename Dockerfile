FROM quay.io/aptible/debian:wheezy

# cf. docker-library/mysql: explicitly create the user so uid and gid are consistent.
RUN groupadd -r mysql && useradd -r -g mysql mysql

ADD templates/etc/apt/sources.list.d /etc/apt/sources.list.d
RUN apt-key adv --keyserver pool.sks-keyservers.net --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        netcat \
        perl \
        procps \
        mysql-server=5.6.23-1debian7 \
        mysql-client=5.6.23-1debian7 \
        && \
    rm -rf /var/lib/apt/lists/*

ADD templates/etc/mysql /etc/mysql

ENV DATA_DIRECTORY /var/db
RUN mkdir -p "$DATA_DIRECTORY" && chown -R mysql:mysql "$DATA_DIRECTORY"

ADD test /tmp/test
# The current tests are simple. If they need mysqld running in the future, see
# aptible/docker-postgresql for an example.
RUN bats /tmp/test

VOLUME ["$DATA_DIRECTORY"]
EXPOSE 3306

ADD run-database.sh /usr/bin/
ENTRYPOINT ["run-database.sh"]
