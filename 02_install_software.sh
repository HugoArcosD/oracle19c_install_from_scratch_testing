#!/bin/bash
# Must be run as ROOT or with sudo
# Usage: sudo ./02_install_software.sh <path_to_rpm_file>

# 1. Validate root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# 2. Validate input parameter
RPM_FILE=$1
if [ -z "$RPM_FILE" ]; then
    echo "ERROR: You must provide the path to the Oracle RPM file."
    echo "Usage: sudo $0 /path/to/oracle-database-ee-19c-1.0-1.x86_64.rpm"
    exit 1
fi

if [ ! -f "$RPM_FILE" ]; then
    echo "ERROR: File $RPM_FILE not found."
    exit 1
fi

echo "======================================================="
echo "Starting Oracle 19c Software Installation..."
echo "======================================================="

# 3. Install pre-requisites (oracle-database-preinstall)
# This package sets up the 'oracle' user, groups, and kernel parameters automatically
echo "Step 1: Installing pre-requisites..."
dnf install -y oracle-database-preinstall-19c

# 4. Install the Oracle RPM
echo "Step 2: Installing Oracle Database RPM..."
dnf localinstall -y "$RPM_FILE"

# 5. Confirmation
if [ $? -eq 0 ]; then
    echo "======================================================="
    echo "Software installation successful!"
    echo "The binaries are located in: /opt/oracle/product/19c/dbhome_1"
    echo "======================================================="
else
    echo "ERROR: Installation failed. Please check the logs."
    exit 1
fi


