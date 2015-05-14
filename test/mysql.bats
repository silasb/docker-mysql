#!/usr/bin/env bats

setup() {
  service mysql start
}

teardown() {
  service mysql stop
}

@test "It should install MySQL 5.6" {
  run mysqld --version
  [[ "$output" =~ "Ver 5.6"  ]]
}

@test "It should support SSL connections" {
  skip
}

@test "It should require SSL" {
  skip
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
