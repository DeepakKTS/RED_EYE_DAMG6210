create or replace PACKAGE BODY driver_management_pkg AS

    -- Function to check driver's rest eligibility
    FUNCTION CHECK_DRIVER_REST_ELIGIBILITY (
        id IN VARCHAR2,
        required_rest_hours IN NUMBER
    ) RETURN VARCHAR2 IS
        last_trip_end_time DATE;
        rest_period_in_hours NUMBER;
    BEGIN
        -- Fetch the last trip end time for the given driver
        SELECT MAX(t.end_time)
        INTO last_trip_end_time
        FROM trips t
        JOIN shuttles s ON t.shuttle_id = s.shuttle_id
        JOIN shifts sh ON s.shuttle_id = sh.shuttle_id
        JOIN drivers d ON sh.driver_id = d.driver_id
        WHERE d.driver_id = id;

        -- Check rest period eligibility
        IF last_trip_end_time IS NOT NULL THEN
            rest_period_in_hours := (SYSDATE - last_trip_end_time) * 24;
            IF rest_period_in_hours >= required_rest_hours THEN
                RETURN 'Eligible';
            ELSE
                RETURN 'Not Eligible';
            END IF;
        ELSE
            RETURN 'Eligible'; -- Eligible if no trips are found
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Eligible'; -- Eligible if no data found
        WHEN OTHERS THEN
            RETURN 'Error occurred: ' || SUBSTR(SQLERRM, 1, 200); -- Restrict error message length
    END CHECK_DRIVER_REST_ELIGIBILITY;

    -- Procedure to assign backup drivers
    PROCEDURE ASSIGN_BACKUP_DRIVERS AS
        -- Cursor to fetch shifts without assigned drivers
        CURSOR unassigned_shifts IS
            SELECT shift_id, shuttle_id, start_time, end_time
            FROM shifts
            WHERE driver_id IS NULL; -- Select shifts without an assigned primary driver

        available_driver_id drivers.driver_id%TYPE; -- Variable to store the available driver ID
        shift_record unassigned_shifts%ROWTYPE; -- Row type for cursor
    BEGIN
        -- Open the cursor to fetch unassigned shifts
        OPEN unassigned_shifts;

        LOOP
            FETCH unassigned_shifts INTO shift_record;
            EXIT WHEN unassigned_shifts%NOTFOUND;

            -- Find the first available driver who is not already assigned to overlapping shifts
            BEGIN
                SELECT d.driver_id
                INTO available_driver_id
                FROM drivers d
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM shifts s
                    WHERE s.driver_id = d.driver_id
                    AND (s.start_time <= shift_record.end_time AND s.end_time >= shift_record.start_time)
                )
                AND ROWNUM = 1; -- Fetch the first available driver

                -- Assign the available driver to the shift
                UPDATE shifts
                SET driver_id = available_driver_id
                WHERE shift_id = shift_record.shift_id;

                -- Log the assignment
                DBMS_OUTPUT.PUT_LINE('Backup driver ' || available_driver_id || ' assigned to shift ' || shift_record.shift_id);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    DBMS_OUTPUT.PUT_LINE('No available driver for shift ' || shift_record.shift_id);
            END;
        END LOOP;

        -- Close the cursor
        CLOSE unassigned_shifts;

        -- Output completion message
        DBMS_OUTPUT.PUT_LINE('Backup driver assignment process completed.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
    END ASSIGN_BACKUP_DRIVERS;

    -- Procedure to enforce background check for drivers
   PROCEDURE ENFORCE_DRIVER_BACKGROUND_CHECK (driver_id IN drivers.driver_id%TYPE) IS
    license_number drivers.licenseNumber%TYPE;
BEGIN
    -- Fetch the driver's license number from the drivers table
    BEGIN
        SELECT licenseNumber
        INTO license_number
        FROM drivers
        WHERE driver_id = driver_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20008, 'Driver ID not found in drivers table.');
    END;

    -- Check if the license number is NULL
    IF license_number IS NULL THEN
        -- Raise an error if the license number is mandatory but missing
        RAISE_APPLICATION_ERROR(-20010, 'License number is mandatory.');
    ELSIF LENGTH(license_number) < 10 THEN
        -- Mark verification flag as 'NO' and raise an error if the license number is invalid
        UPDATE drivers
        SET verification_flag = 'NO'
        WHERE driver_id = driver_id;

        RAISE_APPLICATION_ERROR(-20009, 'Invalid license number. Verification flag set to NO.');
    ELSE
        -- Mark verification flag as 'YES' if the license number is valid (10 or more digits)
        UPDATE drivers
        SET verification_flag = 'YES'
        WHERE driver_id = driver_id;
    END IF;

END ENFORCE_DRIVER_BACKGROUND_CHECK;

END driver_management_pkg;
