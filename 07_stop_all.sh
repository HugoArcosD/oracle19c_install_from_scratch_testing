#!/bin/bash
# Run as ORACLE user

STATE_FILE="/home/oracle/oracle_state.txt"
echo -n "" > $STATE_FILE

echo "--- Stopping all Oracle services and saving state ---"

# 1. Save and stop Listeners
ps -ef | grep tnslsnr | grep -v grep | awk '{print $NF}' > /tmp/listeners.list
while read LSNR; do
    echo "Saving and stopping listener: $LSNR"
    echo "LSNR:$LSNR" >> $STATE_FILE
    lsnrctl stop $LSNR
done < /tmp/listeners.list

# 2. Save and stop Databases
ps -ef | grep ora_pmon | grep -v grep | awk -F_ '{print $NF}' > /tmp/dbs.list
while read SID; do
    echo "Saving and stopping database: $SID"
    echo "DB:$SID" >> $STATE_FILE
    export ORACLE_SID=$SID
    sqlplus -s / as sysdba <<EOF
    shutdown immediate;
    EXIT;
EOF
done < /tmp/dbs.list

echo "--- All services stopped. State saved in $STATE_FILE ---"

