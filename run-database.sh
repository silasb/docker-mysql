#!/bin/bash

if [[ "$1" == "--initialize" ]]; then
  chown -R mysql:mysql "$DATA_DIRECTORY"

  mysql_install_db --user=mysql -ldata="$DATA_DIRECTORY"

  service mysql start
  until nc -z localhost 3306; do sleep 0.1; done

  mysql -e "GRANT ALL ON *.* to '${USERNAME:-aptible}'@'%' IDENTIFIED BY '$PASSPHRASE'"
  mysql -e "CREATE DATABASE ${DATABASE:-db}"
  service mysql stop
  exit
fi

mysqld_safe
