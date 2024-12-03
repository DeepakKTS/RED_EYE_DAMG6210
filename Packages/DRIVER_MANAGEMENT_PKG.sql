create or replace PACKAGE driver_management_pkg AS
    FUNCTION check_driver_rest_eligibility (
        id IN VARCHAR2,
        required_rest_hours IN NUMBER
    ) RETURN VARCHAR2;

    PROCEDURE assign_backup_drivers;
END driver_management_pkg;
