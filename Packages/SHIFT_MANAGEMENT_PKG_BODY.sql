-- Package for Shift Management

CREATE OR REPLACE PACKAGE shift_management_pkg AS
    -- Procedure to create and assign 5 shifts for a day
    PROCEDURE create_shifts (
        p_date IN shifts.start_time%TYPE
    );
END shift_management_pkg;
/

-- Package Body for Shift Management
CREATE OR REPLACE PACKAGE BODY shift_management_pkg AS

    -- Procedure to create and assign 5 shifts for a day
    PROCEDURE create_shifts (
        p_date IN shifts.start_time%TYPE
    ) IS
        v_shuttle_id shifts.shuttle_id%TYPE;
        v_start_time shifts.start_time%TYPE;
        v_driver_id drivers.driver_id%TYPE;
        v_shifts_for_date NUMBER;
    BEGIN

        IF p_date IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Date cannot be null');
            RETURN; 
        END IF;

        IF p_date < SYSDATE THEN
            DBMS_OUTPUT.PUT_LINE('Date cannot be in the past');
            RETURN;
        END IF;

        BEGIN 
            SELECT COUNT(*)
            INTO v_shifts_for_date
            FROM shifts
            WHERE trunc(start_time) = p_date;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_shifts_for_date := 0;
        END;
        

        --check if the date already has shifts
        IF (v_shifts_for_date = 2 AND v_shifts_for_date > 0) THEN
            DBMS_OUTPUT.PUT_LINE('Shifts already created for ' || p_date);
            RETURN;
        END IF;

        FOR i IN 1..(2-v_shifts_for_date) LOOP
            DBMS_OUTPUT.PUT_LINE('Creating shift ' || i || ' for ' || p_date);
            BEGIN
                SELECT shuttle_id
                INTO v_shuttle_id
                FROM shuttles
                WHERE shuttle_id NOT IN (
                    SELECT shuttle_id
                    FROM shifts
                    WHERE trunc(start_time) = trunc(p_date)
                ) AND shuttle_id NOT IN (
                    SELECT shuttle_id
                    FROM maintenance_schedules 
                    WHERE maintenance_date = trunc(p_date)
                )
                AND is_active = 1
                FETCH FIRST 1 ROWS ONLY;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    DBMS_OUTPUT.PUT_LINE('No available shuttles for the given date');
                    EXIT;
            END;

            -- Find the first available driver who has not worked on the previous day
            BEGIN
                SELECT driver_id
                INTO v_driver_id
                FROM drivers
                WHERE driver_id NOT IN (
                    SELECT driver_id
                        FROM shifts
                        WHERE trunc(start_time) = trunc(p_date) - 1
                        OR trunc(start_time) = trunc(p_date)
                        or trunc(start_time) = trunc(p_date) + 1
                )
                AND is_active = 1
                FETCH FIRST 1 ROWS ONLY;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    DBMS_OUTPUT.PUT_LINE('No available drivers for the given date');
                    EXIT;
            END;

            -- Calculate the start time for the shift
            v_start_time := TRUNC(p_date) + INTERVAL '6' HOUR;

            -- Insert the new shift record starting at 6 AM and ending at 6 PM
            INSERT INTO shifts (shift_id, shuttle_id, driver_id, start_time, end_time)
            VALUES ('S' || TO_CHAR(p_date, 'YYYYMMDD') || '-' || i, v_shuttle_id, v_driver_id, v_start_time, v_start_time + INTERVAL '12' HOUR);
        END LOOP;
        COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
    END create_shifts;

END shift_management_pkg;
/
