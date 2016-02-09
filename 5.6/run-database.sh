#!/bin/bash

. /usr/bin/utilities.sh

sed "s:DATA_DIRECTORY:${DATA_DIRECTORY}:g" /etc/mysql/conf.d/overrides.cnf.template > /etc/mysql/conf.d/overrides.cnf

if [[ "$1" == "--initialize" ]]; then
  mkdir -p "$DATA_DIRECTORY/ssl"
  cd "$DATA_DIRECTORY/ssl"
  # All of these certificates need to be generated and signed in the past.
  # Otherwise, MySQL can reject the configuration with an error indicating that
  # it thinks their start dates are in the future.
  faketime 'yesterday' openssl genrsa 2048 > ca-key.pem
  faketime 'yesterday' openssl req -sha1 -new -x509 -nodes -days 10000 -key ca-key.pem -batch > ca-cert.pem
  faketime 'yesterday' openssl req -sha1 -newkey rsa:2048 -days 10000 -nodes -keyout server-key-pkcs-8.pem -batch  > server-req.pem
  faketime 'yesterday' openssl x509 -sha1 -req -in server-req.pem -days 10000  -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 > server-cert.pem
  # MySQL requires the key to be PKCS #1-formatted; modern versions of OpenSSL
  # will generate a key in PKCS #8 format. This call ensures that the key is in
  # PKCS #1 format. Reference: https://bugs.mysql.com/bug.php?id=71271
  openssl rsa -in server-key-pkcs-8.pem -out server-key.pem
  cd -

  chown -R mysql:mysql "$DATA_DIRECTORY"

  mysql_install_db --user=mysql -ldata="$DATA_DIRECTORY"

  mysqld_safe --ssl &
  until nc -z localhost 3306; do sleep 0.1; done

  mysql -e "GRANT ALL ON *.* to 'root'@'%' IDENTIFIED BY '$PASSPHRASE' WITH GRANT OPTION"
  mysql -e "GRANT ALL ON ${DATABASE:-db}.* to '${USERNAME:-aptible}-nossl'@'%' IDENTIFIED BY '$PASSPHRASE'"
  mysql -e "GRANT ALL ON ${DATABASE:-db}.* to '${USERNAME:-aptible}'@'%' IDENTIFIED BY '$PASSPHRASE' REQUIRE SSL"
  mysql -e "CREATE DATABASE ${DATABASE:-db}"
  mysqladmin shutdown

elif [[ "$1" == "--client" ]]; then
  [ -z "$2" ] && echo "docker run -it aptible/mysql --client mysql://..." && exit
  parse_url "$2"
  MYSQL_PWD="$password" mysql --host="$host" --port="$port" --user="$user" "$database" --ssl

elif [[ "$1" == "--dump" ]]; then
  [ -z "$2" ] && echo "docker run aptible/mysql --dump mysql://... > dump.sql" && exit
  parse_url "$2"
  # If the file /dump-output exists, write output there. Otherwise, use stdout.
  [ -e /dump-output ] && exec 3>/dump-output || exec 3>&1
  MYSQL_PWD="$password" mysqldump --host="$host" --port="$port" --user="$user" "$database" --ssl >&3

elif [[ "$1" == "--restore" ]]; then
  [ -z "$2" ] && echo "docker run -i aptible/mysql --restore mysql://... < dump.sql" && exit
  parse_url "$2"
  # If the file /restore-input exists, read input there. Otherwise, use stdin.
  [ -e /restore-input ] && exec 3</restore-input || exec 3<&0
  MYSQL_PWD="$password" mysql --host="$host" --port="$port" --user="$user" "$database" --ssl <&3

elif [[ "$1" == "--readonly" ]]; then
  echo "Starting MySQL in read-only mode..."
  mysqld_safe --read-only --ssl

else
  mysqld_safe --ssl

fi
