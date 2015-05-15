#!/bin/bash

parse_url_into_cli_option_string()
{
  # cf http://stackoverflow.com/a/17287984
  protocol="$(echo "$1" | grep :// | sed -e's,^\(.*://\).*,\1,g')"
  # remove the protocol
  url=$(echo $1 | sed -e s,$protocol,,g)
  # extract the user and password (if any)
  user_and_password="$(echo $url | grep @ | cut -d@ -f1)"
  password="$(echo $user_and_password | grep : | cut -d: -f2)"
  if [ -n "$password" ]; then
    user="$(echo $user_and_password | grep : | cut -d: -f1)"
  else
    user="$user_and_password"
  fi

  # extract the host
  host_and_port="$(echo $url | sed -e s,$user_and_password@,,g | cut -d/ -f1)"
  port="$(echo $host_and_port | grep : | cut -d: -f2)"
  if [ -n "$port" ]; then
    host="$(echo $host_and_port | grep : | cut -d: -f1)"
  else
    host="$host_and_port"
  fi

  database="$(echo $url | grep / | cut -d/ -f2-)"

  options="-h "$host""
  [ -n "$port" ] && options="$options -P "$port""
  [ -n "$user" ] && options="$options --user="$user""
  [ -n "$database" ] && options="$options $database"
  echo $options
}

# Note that supplying the password with `--password=...` results in:
# "Warning: Using a password on the command line interface can be insecure."
# However, providing the environment variable `$MYSQL_PWD` suppresses the
# warning. Hence the password extraction is separated here.
extract_password_from_url()
{
  # cf http://stackoverflow.com/a/17287984
  protocol="$(echo "$1" | grep :// | sed -e's,^\(.*://\).*,\1,g')"
  # remove the protocol
  url=$(echo $1 | sed -e s,$protocol,,g)
  # extract the user and password (if any)
  user_and_password="$(echo $url | grep @ | cut -d@ -f1)"
  password="$(echo $user_and_password | grep : | cut -d: -f2)"
  echo $password
}
