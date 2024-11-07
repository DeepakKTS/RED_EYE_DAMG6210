# RED_EYE_DAMG6210

## Overview

The Redeye system is a comprehensive shuttle booking system designed to manage users, roles, shuttles, trips, rides, and maintenance schedules. This README provides instructions on how to set up and initialize the database for the Redeye system.

## Prerequisites

**Admin Privileges Required:** The setup scripts must be executed on an Oracle database with DBA privileges, as they utilize the `DBA_USERS` table to check for existing users and grant system-level privileges.

## Script Overview

The SQL scripts perform the following steps:

1. **Check for Existing User:** Verify if the `REDEYE` user exists in the `DBA_USERS` table.
2. **Drop Existing User:** If the `REDEYE` user exists, drop the user (including all associated objects) to ensure a clean setup.
3. **Create New User:** Create a new user `REDEYE` with the specified password (`NeuBoston2024#`).
4. **Grant Privileges:** Grant a comprehensive set of privileges to the `REDEYE` user.

## Privileges Granted

The script grants the following privileges to the `REDEYE` user:

### Basic Access Privileges

- `CREATE SESSION` (with admin option)
- `CONNECT`
- Unlimited quota on the `DATA` tablespace

### Object Creation and Modification Privileges

- `CREATE TABLE`
- `CREATE VIEW`
- `ALTER ANY TABLE`
- `DROP ANY TABLE`
- `CREATE ANY INDEX`
- `ALTER ANY INDEX`

### Data Manipulation Privileges

- `SELECT ANY TABLE`
- `INSERT ANY TABLE`
- `UPDATE ANY TABLE`
- `DELETE ANY TABLE`

### Procedure Privileges

- `CREATE PROCEDURE`
- `EXECUTE ANY PROCEDURE`

## Usage

1. **Clone this repository.**
2. **Connect to your Oracle database with DBA privileges.**
3. **Execute the script in an SQL environment** (such as SQL*Plus, SQL Developer, or any Oracle-compatible environment with DBA access).

## Steps to Initialize the Database with Required Views

1. **Create user using the CREATE_USER.sql script.**
2. **Login using the created user to run the rest of the scripts.**
3. **Run the CREATE_TABLES.sql script** to create the necessary tables.
4. **Run the INSERT_DATA.sql script** to populate the tables with initial data.
5. **Run the CREATE_VIEWS.sql script** to create and update the views.

By following these steps, you will set up the Redeye system's database and be ready to manage shuttle bookings efficiently.
