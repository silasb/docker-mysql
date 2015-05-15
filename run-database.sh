#!/bin/bash

. /usr/bin/utilities.sh

if [[ "$1" == "--initialize" ]]; then
  chown -R mysql:mysql "$DATA_DIRECTORY"

  mysql_install_db --user=mysql -ldata="$DATA_DIRECTORY"

  service mysql start
  until nc -z localhost 3306; do sleep 0.1; done

  mysql -e "GRANT ALL ON ${DATABASE:-db}.* to '${USERNAME:-aptible}'@'%' IDENTIFIED BY '$PASSPHRASE'"
  mysql -e "CREATE DATABASE ${DATABASE:-db}"
  service mysql stop

elif [[ "$1" == "--client" ]]; then
  [ -z "$2" ] && echo "docker run -it aptible/mysql --client mysql://..." && exit
  password=$(extract_password_from_url "$2")
  MYSQL_PWD="$password" mysql $(parse_url_into_cli_option_string "$2")

elif [[ "$1" == "--dump" ]]; then
  [ -z "$2" ] && echo "docker run aptible/mysql --dump mysql://... > dump.sql" && exit
  password=$(extract_password_from_url "$2")
  MYSQL_PWD="$password" mysqldump $(parse_url_into_cli_option_string "$2")

elif [[ "$1" == "--restore" ]]; then
  [ -z "$2" ] && echo "docker run -i aptible/mysql --restore mysql://... < dump.sql" && exit
  password=$(extract_password_from_url "$2")
  MYSQL_PWD="$password" mysql $(parse_url_into_cli_option_string "$2")

elif [[ "$1" == "--readonly" ]]; then
  echo "Starting MySQL in read-only mode..."
  mysqld_safe --read-only

else
  mysqld_safe

fi
