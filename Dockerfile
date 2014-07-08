FROM quay.io/aptible/ubuntu:14.04

# Install Percona MySQL 5.6 from official Debian sources
ADD templates/etc/apt/sources.list.d /etc/apt/sources.list.d
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A && \
    apt-get update && \
    apt-get install -y percona-server-server-5.6 percona-server-client-5.6

ADD test /tmp/test
RUN bats /tmp/test

VOLUME ["/var/lib/mysql"]
EXPOSE 3306

CMD /usr/bin/mysqld_safe
