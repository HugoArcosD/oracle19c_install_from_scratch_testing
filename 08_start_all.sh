#!/bin/bash
# Run as ORACLE user

STATE_FILE="/home/oracle/oracle_state.txt"

if [ ! -f "$STATE_FILE" ]; then
    echo "No state file found! Nothing to start."
    exit 1
fi

echo "--- Restoring state from $STATE_FILE ---"

while read LINE; do
    TYPE=$(echo $LINE | cut -d: -f1)
    NAME=$(echo $LINE | cut -d: -f2)

    if [ "$TYPE" == "LSNR" ]; then
        echo "Starting listener: $NAME"
        lsnrctl start $NAME
    elif [ "$TYPE" == "DB" ]; then
        echo "Starting database: $NAME"
        export ORACLE_SID=$NAME
        sqlplus -s / as sysdba <<EOF
        startup;
        EXIT;
EOF
    fi
done < $STATE_FILE

echo "--- All saved services restored ---"

