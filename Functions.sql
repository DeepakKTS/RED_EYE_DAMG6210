-- File: Functions.sql
-- Author: Bhavya
-- Purpose: Contains functions for the Redeye system, including driver eligibility checks based on rest periods.

-- Function 1: CHECK_DRIVER_REST_ELIGIBILITY
-- This function calculates if a driver is eligible for a new trip based on their rest period.

CREATE OR REPLACE FUNCTION CHECK_DRIVER_REST_ELIGIBILITY (
    id IN VARCHAR2,            -- Driver ID to check
    required_rest_hours IN NUMBER     -- Minimum required rest hours
) RETURN VARCHAR2 IS
    last_trip_end_time DATE;          -- Stores the last trip's end time
    rest_period_in_hours NUMBER;      -- Stores the calculated rest period in hours
BEGIN
    -- Get the end time of the driver's last trip by linking through shifts and shuttles
    SELECT MAX(t.endTime)
    INTO last_trip_end_time
    FROM trips t
    JOIN shuttles s ON t.shuttle_id = s.shuttle_id
    JOIN shifts sh ON s.shuttle_id = sh.shuttle_id
    JOIN drivers d ON sh.driver_id = d.driver_id
    WHERE d.driver_id = id;  -- Explicitly use the alias for driver_id

    -- Calculate the rest period in hours
    IF last_trip_end_time IS NOT NULL THEN
        rest_period_in_hours := (SYSDATE - last_trip_end_time) * 24;

        -- Check if the rest period meets the required rest time
        IF rest_period_in_hours >= required_rest_hours THEN
            RETURN 'Eligible'; -- Driver has rested enough
        ELSE
            RETURN 'Not Eligible'; -- Driver has not rested enough
        END IF;
    ELSE
        -- No trips found for this driver, assume eligibility
        RETURN 'Eligible';
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- If no trips are found for the driver, assume eligibility
        RETURN 'Eligible';
    WHEN OTHERS THEN
        -- Handle any other unexpected exceptions
        RETURN 'Error: ' || SQLERRM;
END;
/

