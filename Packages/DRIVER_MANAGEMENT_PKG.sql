create or replace PACKAGE driver_management_pkg AS

    -- Function to check driver's rest eligibility
    FUNCTION CHECK_DRIVER_REST_ELIGIBILITY (
        id IN VARCHAR2,
        required_rest_hours IN NUMBER
    ) RETURN VARCHAR2;

    -- Procedure to assign backup drivers
    PROCEDURE ASSIGN_BACKUP_DRIVERS;

    -- Procedure to enforce background check for drivers
    PROCEDURE ENFORCE_DRIVER_BACKGROUND_CHECK (
        driver_id IN drivers.driver_id%TYPE
    );

END driver_management_pkg;