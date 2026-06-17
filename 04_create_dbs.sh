#!/bin/bash
# Run as ORACLE user

# 1. Validate parameter
if [ -z "$1" ]; then
    echo "ERROR: ORACLE_SID parameter is missing."
    exit 1
fi

export ORACLE_SID=$1

# Ask for syspassword
if [ -z "$ORACLE_PASS" ]; then
    echo -n "Introduce  SYS password for  ${ORACLE_SID}: "
    read -s ORACLE_PASS
    echo ""
fi

export ORACLE_SID=$1
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

echo "--- Starting full creation process for: ${ORACLE_SID} ---"

# 2. Preparation
mkdir -p /data/ora_data01/${ORACLE_SID}
mkdir -p /data/ora_redo01/${ORACLE_SID}
mkdir -p /data/ora_redo02/${ORACLE_SID}
mkdir -p /data/ora_fra01/${ORACLE_SID}

# 3. Create Database
dbca -silent -createDatabase \
     -templateName General_Purpose.dbc \
     -gdbname ${ORACLE_SID} -sid ${ORACLE_SID} \
     -createAsContainerDatabase false \
     -sysPassword "$ORACLE_PASS" -systemPassword "$ORACLE_PASS" \
     -storageType FS \
     -datafileDestination "/data/ora_data01/${ORACLE_SID}" \
     -recoveryAreaDestination "/data/ora_fra01/${ORACLE_SID}" \
     -redoLogFileSize 50 \
     -memoryPercentage 15 \
     -initParams control_files="('/data/ora_data01/${ORACLE_SID}/control01.ctl','/data/ora_redo01/${ORACLE_SID}/control02.ctl')"

# 4. Integrated Verification & Fix Logic
CTRL_TARGET="/data/ora_redo01/${ORACLE_SID}/control02.ctl"

# Use TR to strip all spaces, tabs, and newlines from the SQL output
CTRL_CURRENT=$(sqlplus -s / as sysdba <<EOF
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF
SELECT name FROM v\$controlfile WHERE name LIKE '%control02%';
EXIT;
EOF
)
CTRL_CURRENT=$(echo "$CTRL_CURRENT" | tr -d '[:space:]')

# Check if the cleaned string contains our target path
if [[ "$CTRL_CURRENT" != *"$CTRL_TARGET"* ]]; then
    echo "Detection: Control file is in wrong location ($CTRL_CURRENT). Moving to $CTRL_TARGET..."
    
    sqlplus -s / as sysdba <<EOF
    shutdown immediate;
    EXIT;
EOF
    
    # Use find to locate the file by name in case the path is unpredictable
    # We strip spaces from the result of find just in case
    mv "$(find /data/ -name "control02.ctl" | grep ${ORACLE_SID} | tr -d '[:space:]')" "$CTRL_TARGET"
    
    sqlplus -s / as sysdba <<EOF
    startup nomount;
    ALTER SYSTEM SET control_files='/data/ora_data01/${ORACLE_SID}/control01.ctl', '$CTRL_TARGET' SCOPE=SPFILE SID='*';
    shutdown immediate;
    startup;
    EXIT;
EOF
    echo "Control file successfully relocated and DB restarted."
else
    echo "Verification: Control file is confirmed to be in $CTRL_TARGET."
fi


