-- Package for Shift Management

CREATE PACKAGE shift_management_pkg AS
    -- Procedure to create and assign 5 shifts for a day
    PROCEDURE create_shifts (
        date IN DATE
    );
END shift_management_pkg;
