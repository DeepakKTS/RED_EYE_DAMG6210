-- Create User Block
DECLARE
    user_exists NUMBER;
BEGIN
    -- Check if the user 'REDEYE' exists in DBA_USERS
    SELECT COUNT(*)
    INTO user_exists
    FROM dba_users
    WHERE username = 'REDEYE';

    -- Drop the user if it exists
    IF user_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP USER Redeye CASCADE';
    END IF;

    -- Create the user
    EXECUTE IMMEDIATE 'CREATE USER Redeye IDENTIFIED BY NeuBoston2024#';
END;
/

-- Grant Privileges to the user Redeye
GRANT CREATE SESSION TO Redeye WITH ADMIN OPTION;
GRANT CONNECT TO Redeye;
ALTER USER Redeye QUOTA unlimited ON DATA;

GRANT CREATE TABLE TO Redeye;
GRANT CREATE VIEW TO Redeye;

GRANT ALTER ANY TABLE TO Redeye;
GRANT DROP ANY TABLE TO Redeye;

GRANT SELECT ANY TABLE TO Redeye;
GRANT INSERT ANY TABLE TO Redeye;
GRANT UPDATE ANY TABLE TO Redeye;
GRANT DELETE ANY TABLE TO Redeye;

GRANT CREATE ANY INDEX TO Redeye;
GRANT ALTER ANY INDEX TO Redeye;

GRANT CREATE PROCEDURE TO Redeye;
GRANT EXECUTE ANY PROCEDURE TO Redeye;

GRANT EXECUTE ON DBMS_SCHEDULER TO Redeye;

GRANT MANAGE SCHEDULER to Redeye;
GRANT CREATE JOB TO Redeye;

GRANT CREATE TRIGGER TO Redeye;
