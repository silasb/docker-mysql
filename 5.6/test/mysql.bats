#!/usr/bin/env bats

setup() {
  service mysql start
}

teardown() {
  service mysql stop
  while [ -f /var/run/mysqld/mysqld.pid ]; do sleep 0.1; done
}

@test "It should install MySQL 5.6.25" {
  run mysqld --version
  [[ "$output" =~ "Ver 5.6.25"  ]]
}

@test "It should support SSL connections" {
  have_ssl=$(mysql -Ee "show variables where variable_name = 'have_ssl'" | grep Value | awk '{ print $2 }')
  [[ "$have_ssl" == "YES" ]]
}

@test "It should be built with OpenSSL support" {
  have_openssl=$(mysql -Ee "show variables where variable_name = 'have_openssl'" | grep Value | awk '{ print $2 }')
  [[ "$have_openssl" == "YES" ]]
}

@test "It should allow connections over SSL" {
  cipher=$(mysql -Ee "show status like 'Ssl_cipher'" | grep Value | awk '{ print $2 }')
  [[ "$cipher" == "DHE-RSA-AES256-SHA" ]]
}

@test "It should set max_connect_errors to a large value" {
# Containers from this Docker image are often run behind load balancers that
# ping them constantly with TCP health checks, which can confuse MySQL because
# they appear to be repeated failed connection attempts from the same host.
# MySQL will eventually block connections from the load balancer if
# max_connect_errors isn't set high enough.
  max_connect_errors=$(mysql -Ee "show variables where variable_name = 'max_connect_errors'" | grep Value | awk '{ print $2 }')
  [[ "$max_connect_errors" -ge 10000000 ]]
}
