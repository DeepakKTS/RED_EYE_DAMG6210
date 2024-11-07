# RED_EYE_DAMG6210

CREATE_USER_REDYE_GRANT_PERMISSIONS.sql

Prerequisites

Admin Privileges Required: The script must be executed on the admin database (DBA level) since it utilizes the DBA_USERS table to check for existing users and grants system-level privileges.
Script Overview
The SQL script performs the following steps:

Check for Existing User: It first checks if the REDEYE user already exists within the DBA_USERS table.
Drop Existing User: If the REDEYE user exists, the script will drop the user (including all associated objects) to ensure a clean setup.
Create New User: It then creates a new user REDEYE with a specified password (NeuBoston2024#).
Grant Privileges: A comprehensive set of privileges is granted to the REDEYE user, as outlined below.
Privileges Granted
The script grants the following privileges to the REDEYE user:

Basic Access Privileges:

CREATE SESSION (with admin option)
CONNECT
Unlimited quota on the DATA tablespace.
Object Creation and Modification Privileges:

CREATE TABLE
CREATE VIEW
ALTER ANY TABLE
DROP ANY TABLE
CREATE ANY INDEX
ALTER ANY INDEX
Data Manipulation Privileges:

SELECT ANY TABLE
INSERT ANY TABLE
UPDATE ANY TABLE
DELETE ANY TABLE
Procedure Privileges:

CREATE PROCEDURE
EXECUTE ANY PROCEDURE
Usage
Clone this repository.
Connect to your Oracle database with DBA privileges.
Execute the script in an SQL environment (such as SQL*Plus, SQL Developer, or any Oracle-compatible environment with DBA access).
