
#!/bin/bash
# Run as ROOT or with sudo

echo "Creating enterprise directory structure..."

# Oracle Base and Home directories
mkdir -p /opt/oracle/product/19c/dbhome_1
mkdir -p /opt/oracle/diag

# Simulated mount points for data, redo, and recovery
mkdir -p /data/ora_temp01
mkdir -p /data/ora_fra01
mkdir -p /data/ora_redo01
mkdir -p /data/ora_redo02
mkdir -p /data/ora_data01
mkdir -p /data/ora_data02

echo "Assigning permissions to oracle:oinstall..."
chown -R oracle:oinstall /opt/oracle
chown -R oracle:oinstall /data
chmod -R 775 /opt/oracle
chmod -R 775 /data

echo "Directories successfully created."
