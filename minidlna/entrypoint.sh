#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'
pidfile="/minidlna/minidlna.pid"

# Remove old pid if it exists
[ -f $pidfile ] && rm -f $pidfile

dbdir_provided=false
logdir_provided=false

# Change configuration
: > /etc/minidlna.conf
for VAR in $(env); do
  if [[ "$VAR" =~ ^MINIDLNA_ ]]; then
    if [[ "$VAR" =~ ^MINIDLNA_MEDIA_DIR ]]; then
      minidlna_name='media_dir'
    elif [[ "$VAR" =~ ^MINIDLNA_DB_DIR ]]; then
      minidlna_name='db_dir'
      dbdir_provided=true
    elif [[ "$VAR" =~ ^MINIDLNA_LOG_DIR ]]; then
      minidlna_name='log_dir'
      logdir_provided=true
    else
      minidlna_name=$(echo "$VAR" | sed -r "s/MINIDLNA_(.*)=.*/\\1/g" | tr '[:upper:]' '[:lower:]')
    fi
    minidlna_value=$(echo "$VAR" | sed -r "s/.*=(.*)/\\1/g")
    echo "${minidlna_name}=${minidlna_value}" >> /etc/minidlna.conf
  fi
done
# Directories have to be in a writeable place
if [ "$dbdir_provided" = false ] ; then
  echo "db_dir=/minidlna/cache" >> /etc/minidlna.conf
fi
if [ "$logdir_provided" = false ] ; then
  echo "log_dir=/minidlna/" >>/etc/minidlna.conf
fi

# Start daemon
exec /usr/sbin/minidlnad -P $pidfile -S "$@"
