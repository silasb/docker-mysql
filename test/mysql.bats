#!/usr/bin/env bats

setup() {
  service mysql start
}

teardown() {
  service mysql stop
}

@test "It should install Percona MySQL 5.6" {
}

@test "It should support SSL connections" {
}

@test "It should require SSL" {
}