# Oracle 19c Automation Lab (WSL)

This repository contains a set of scripts designed to automate the complete lifecycle of Oracle Database 19c instances on WSL (Windows Subsystem for Linux).

## Project Structure
All scripts are located in the root directory:
```text
.
├── 01_setup_dirs.sh
├── 02_install_software.sh
├── 03_create_listener_dynamic.sh
├── 03_drop_listener_dynamic.sh
├── 04_create_database_full.sh
├── 06_stop_all.sh
├── 07_start_all.sh
├── nuke_oracle.sh
└── README.md

Quick Start Guide
- Software Installation
Install prerequisites and Oracle 19c binaries:
./01_setup_dirs.sh
sudo ./02_install_software.sh /path/to/oracle-database-ee-19c.rpm

- Network Management (Listeners)
Create or drop listeners dynamically:
# Create: LISTENER on port 1521
./03_create_listener_dynamic.sh LISTENER 1521

# Drop:
./03_drop_listener_dynamic.sh LISTENER

- Database Management
Create a new database (the script will automatically relocate control files and prompt for a SYS password):
./04_create_database_full.sh TESTDB1

Maintenance Operations
Manage services (automatically saves/restores the state of active processes):
# Stop all Oracle services and save the current state
./06_stop_all.sh

# Start services based on the saved state
./07_start_all.sh

Cleanup (Nuke)
Wipe your environment:
# Wipe only databases and data files
sudo ./nuke_oracle.sh

# Wipe EVERYTHING, including software binaries
sudo ./nuke_oracle.sh --software

Security & Usage Notes
Passwords: Scripts use read -s or environment variables to ensure sensitive data is not hardcoded or stored in command history.

Privileges: Scripts that interact with OS files or binaries require sudo. Database management scripts should be executed as the oracle user.

Environment: Ensure your environment variables (like ORACLE_HOME and PATH) are correctly configured in your .bashrc or .ora_env19c.

Developed for automated test environments and Proof of Concepts (PoC).
