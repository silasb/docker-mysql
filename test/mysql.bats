#!/usr/bin/env bats

setup() {
  service mysql start
}

teardown() {
  service mysql stop
}

@test "It should install Percona MySQL 5.6" {
  run mysqld --version
  [[ "$output" =~ "Ver 5.6"  ]]
  [[ "$output" =~ "Percona"  ]]
}

@test "It should support SSL connections" {
  skip
}

@test "It should require SSL" {
  skip
}
