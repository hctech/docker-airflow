#!/usr/bin/env bash

AIRFLOW_HOME="/usr/local/airflow"
CMD="airflow"

: ${FERNET_KEY:=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}

# Install custome python package if requirements.txt is present
if [ -e "/requirements.txt" ]; then
    $(which pip) install --user -r /requirements.txt
fi

# Update airflow config - Fernet key
sed -i "s|\$FERNET_KEY|$FERNET_KEY|" "$AIRFLOW_HOME"/airflow.cfg


# Update configuration depending the type of Executor
if [ "$1" = "webserver" ]; then
  echo "Initialize database..."
  $CMD initdb
  exec $CMD webserver
elif [ "$1" = "version" ]; then
  exec $CMD version
  exit
else
  sleep 10
  exec $CMD "$@"
fi