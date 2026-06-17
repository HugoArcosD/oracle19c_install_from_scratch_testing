# Oracle 19c Automation Lab (WSL)

A collection of automation scripts for managing the complete lifecycle of Oracle Database 19c instances running on WSL (Windows Subsystem for Linux).

## Features

* Automated Oracle 19c software installation
* Dynamic listener creation and removal
* Automated database creation
* Start/stop management with state preservation
* Complete environment cleanup
* Designed for labs, testing, training, and Proof of Concepts (PoC)

---

## Project Structure

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
```

---

## Quick Start

### 1. Install Oracle Software

Prepare directories and install Oracle 19c binaries:

```bash
./01_setup_dirs.sh
sudo ./02_install_software.sh /path/to/oracle-database-ee-19c.rpm
```

---

### 2. Listener Management

Create a listener dynamically:

```bash
./03_create_listener_dynamic.sh LISTENER 1521
```

Remove a listener:

```bash
./03_drop_listener_dynamic.sh LISTENER
```

---

### 3. Database Creation

Create a new database:

```bash
./04_create_database_full.sh TESTDB1
```

The script will:

* Prompt for a SYS password
* Create the database
* Relocate control files automatically
* Configure the instance

---

## Maintenance Operations

### Stop Oracle Services

Saves the current state of running services before shutdown:

```bash
./06_stop_all.sh
```

### Start Oracle Services

Restores services based on the previously saved state:

```bash
./07_start_all.sh
```

---

## Environment Cleanup

### Remove Databases Only

Deletes all databases and associated data files while keeping Oracle software installed:

```bash
sudo ./nuke_oracle.sh
```

### Remove Everything

Deletes databases, configuration files, and Oracle software binaries:

```bash
sudo ./nuke_oracle.sh --software
```

---

## Security Notes

* Passwords are never hardcoded.
* Sensitive input is collected using `read -s` or environment variables.
* Scripts requiring filesystem modifications must be executed with `sudo`.
* Database administration scripts should be executed as the `oracle` user.

---

## Requirements

* Windows Subsystem for Linux (WSL2)
* Oracle Linux / RHEL-compatible distribution
* Oracle Database 19c RPM package
* Bash shell

---

## Disclaimer

This project is intended for:

* Learning Oracle administration
* Automated testing environments
* Demonstrations
* Proof of Concepts (PoC)

It is **not intended for production use without proper review and validation**.
