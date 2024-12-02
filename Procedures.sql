---PROCEDURES---
/*Procedure 1:Vehicle Maintenance Scheduling
This procedure automates the scheduling of vehicle maintenance based on mileage, usage, or a predefined maintenance threshold. The procedure:

Checks shuttles with mileage exceeding a set threshold or scheduled maintenance overdue.
Schedules maintenance for such shuttles by creating entries in the maintenance_schedules table.
Notifies about unscheduled or overdue maintenance.*/

CREATE OR REPLACE PROCEDURE schedule_vehicle_maintenance IS
    v_shuttle_id shuttles.shuttle_id%TYPE;
    v_model shuttles.model%TYPE;
    v_licensePlate shuttles.licensePlate%TYPE;
    v_mileage shuttles.mileage%TYPE;
    v_next_maintenance_date DATE;
    CURSOR overdue_shuttles IS
        SELECT shuttle_id, model, licensePlate, mileage
        FROM shuttles
        WHERE mileage >= 100000
           OR shuttle_id NOT IN (
               SELECT shuttle_id 
               FROM maintenance_schedules 
               WHERE maintenanceDate >= SYSDATE
           ); -- No upcoming maintenance scheduled
BEGIN
    OPEN overdue_shuttles;

    LOOP
        FETCH overdue_shuttles INTO v_shuttle_id, v_model, v_licensePlate, v_mileage;
        EXIT WHEN overdue_shuttles%NOTFOUND;

        -- Schedule maintenance
        v_next_maintenance_date := SYSDATE + INTERVAL '7' DAY; -- Schedule one week from today

        -- Use a sequence to ensure unique maintenance IDs
        INSERT INTO maintenance_schedules (maintenance_id, shuttle_id, maintenanceDate, description)
        VALUES (
            'MNT_' || v_shuttle_id || '_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') || '_' || TO_CHAR(DBMS_RANDOM.VALUE(1000, 9999), 'FM0000'),
            v_shuttle_id,
            v_next_maintenance_date,
            'Routine maintenance scheduled automatically'
        );

        DBMS_OUTPUT.PUT_LINE('Maintenance scheduled for Shuttle: ' || v_shuttle_id || ', License Plate: ' || v_licensePlate || ', Model: ' || v_model);
    END LOOP;

    CLOSE overdue_shuttles;
END;
/

/*Procedure 2: PRIORITY_ROUTING.The PRIORITY_ROUTING procedure dynamically prioritizes shuttle
routes based on factors such as demand, shuttle availability, and time of day. 
This ensures that high-demand routes are assigned more shuttles and resources, optimizing operational efficiency.
*/

CREATE OR REPLACE PROCEDURE priority_routing IS
    CURSOR route_demand IS
        SELECT r.pickupLocationId, r.dropoffLocationId, COUNT(r.ride_id) AS total_rides
        FROM rides r
        JOIN trips t ON r.trip_id = t.trip_id
        WHERE t.startTime BETWEEN SYSDATE - INTERVAL '1' DAY AND SYSDATE -- Analyze recent demand
        GROUP BY r.pickupLocationId, r.dropoffLocationId
        ORDER BY total_rides DESC; -- Prioritize high-demand routes

    v_pickup_location rides.pickupLocationId%TYPE;
    v_dropoff_location rides.dropoffLocationId%TYPE;
    v_total_rides NUMBER;
    v_shuttle_id shuttles.shuttle_id%TYPE;

    CURSOR available_shuttles IS
        SELECT shuttle_id
        FROM shuttles
        WHERE shuttle_id NOT IN (
            SELECT shuttle_id
            FROM trips
            WHERE startTime BETWEEN SYSDATE AND SYSDATE + INTERVAL '1' DAY
        ); -- Only consider shuttles not currently scheduled
BEGIN
    OPEN route_demand;
    OPEN available_shuttles;

    LOOP
        FETCH route_demand INTO v_pickup_location, v_dropoff_location, v_total_rides;
        EXIT WHEN route_demand%NOTFOUND;

        FETCH available_shuttles INTO v_shuttle_id;
        EXIT WHEN available_shuttles%NOTFOUND; -- Stop if no more shuttles are available

        -- Assign the shuttle to the route
        INSERT INTO trips (trip_id, startTime, endTime, status, shuttle_id)
        VALUES (
            'T_' || v_shuttle_id || '_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI'),
            SYSDATE + INTERVAL '1' HOUR, -- Schedule one hour from now
            SYSDATE + INTERVAL '2' HOUR, -- Ends two hours from now
            'Scheduled',
            v_shuttle_id
        );

        DBMS_OUTPUT.PUT_LINE('Assigned Shuttle: ' || v_shuttle_id || ' to Route: ' || v_pickup_location || ' -> ' || v_dropoff_location);
    END LOOP;

    CLOSE route_demand;
    CLOSE available_shuttles;
END;
/

/*Procedure 4: Emergency notifications.This procedure handles emergency notifications in the shuttle management system. It will  be sending alerts to users and administrators when an emergency (e.g., breakdown, accident, or maintenance issue) occurs, ensuring that all stakeholders are promptly informed.*/

CREATE OR REPLACE PROCEDURE emergency_notifications (
    p_shuttle_id IN shuttles.shuttle_id%TYPE,
    p_emergency_type IN VARCHAR2
) IS
    -- Variables
    v_shuttle_details shuttles%ROWTYPE;
    v_admin_email VARCHAR2(100);
    v_user_emails SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST(); -- Array for user emails

    -- Cursor to get affected users
    CURSOR affected_users IS
        SELECT u.email
        FROM users u
        JOIN rides r ON u.user_id = r.user_id
        JOIN trips t ON r.trip_id = t.trip_id
        WHERE t.shuttle_id = p_shuttle_id
          AND t.startTime <= SYSDATE
          AND t.endTime >= SYSDATE;

BEGIN
    -- Fetch shuttle details
    SELECT *
    INTO v_shuttle_details
    FROM shuttles
    WHERE shuttle_id = p_shuttle_id;

    -- Log the shuttle details
    DBMS_OUTPUT.PUT_LINE('Shuttle Details: ' || v_shuttle_details.shuttle_id || ' - ' || v_shuttle_details.model);

    -- Fetch admin email (for simplicity, assume there's a single admin)
    SELECT email
    INTO v_admin_email
    FROM users
    WHERE userType = 'Admin'
    AND ROWNUM = 1;

    DBMS_OUTPUT.PUT_LINE('Admin Email: ' || v_admin_email);

    -- Notify admin about the emergency
    DBMS_OUTPUT.PUT_LINE('Sending notification to Admin: ' || v_admin_email);
    DBMS_OUTPUT.PUT_LINE('Emergency Type: ' || p_emergency_type);

    -- Notify affected users
    OPEN affected_users;
    LOOP
        FETCH affected_users BULK COLLECT INTO v_user_emails LIMIT 100;

        EXIT WHEN v_user_emails.COUNT = 0;

        FOR i IN 1 .. v_user_emails.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('Sending notification to User: ' || v_user_emails(i));
            DBMS_OUTPUT.PUT_LINE('Emergency Type: ' || p_emergency_type);
        END LOOP;
    END LOOP;
    CLOSE affected_users;

    DBMS_OUTPUT.PUT_LINE('Emergency notifications sent successfully for shuttle: ' || p_shuttle_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Shuttle or admin not found for the provided details.');
        RAISE_APPLICATION_ERROR(-20015, 'Shuttle or admin not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
        RAISE;
END;
/

/*Procedure 5: WAITLIST_NOTIFICATIONS.This procedure handles notifying users who are on a waitlist when a shuttle becomes available.
It checks for shuttles with available capacity and matches them to users on the waitlist for a specific route. 
Once a match is found, the user is notified, and their waitlist status is updated.
*/
CREATE OR REPLACE PROCEDURE waitlist_notifications IS
    -- Variables
    v_shuttle_id shuttles.shuttle_id%TYPE;
    v_route_pickup VARCHAR2(50);
    v_route_dropoff VARCHAR2(50);
    v_waitlist_user_id users.user_id%TYPE;

    -- Cursor to find available shuttles
    CURSOR available_shuttles IS
        SELECT s.shuttle_id, r.pickupLocationId, r.dropoffLocationId
        FROM shuttles s
        JOIN trips t ON s.shuttle_id = t.shuttle_id
        JOIN rides r ON t.trip_id = r.trip_id
        WHERE s.capacity > (
            SELECT COUNT(*)
            FROM rides r2
            JOIN trips t2 ON r2.trip_id = t2.trip_id
            WHERE t2.shuttle_id = s.shuttle_id AND r2.status = 'Booked'
        )
          AND r.status = 'Waitlisted';

    -- Cursor to find users on the waitlist
    CURSOR waitlist_users (p_pickupLocationId VARCHAR2, p_dropoffLocationId VARCHAR2) IS
        SELECT user_id
        FROM rides
        WHERE pickupLocationId = p_pickupLocationId
          AND dropoffLocationId = p_dropoffLocationId
          AND status = 'Waitlisted';

BEGIN
    -- Open the cursor for available shuttles
    OPEN available_shuttles;

    LOOP
        -- Fetch an available shuttle
        FETCH available_shuttles INTO v_shuttle_id, v_route_pickup, v_route_dropoff;
        EXIT WHEN available_shuttles%NOTFOUND;

        -- Log shuttle details
        DBMS_OUTPUT.PUT_LINE('Available Shuttle: ' || v_shuttle_id || ' for Route: ' || v_route_pickup || ' -> ' || v_route_dropoff);

        -- Open the cursor for users on the waitlist for the route
        OPEN waitlist_users(v_route_pickup, v_route_dropoff);

        LOOP
            -- Fetch a user from the waitlist
            FETCH waitlist_users INTO v_waitlist_user_id;
            EXIT WHEN waitlist_users%NOTFOUND;

            -- Log notification details
            DBMS_OUTPUT.PUT_LINE('Notifying User: ' || v_waitlist_user_id || ' for Route: ' || v_route_pickup || ' -> ' || v_route_dropoff);

            -- Update the user's ride status to 'Booked'
            UPDATE rides
            SET status = 'Booked'
            WHERE user_id = v_waitlist_user_id
              AND pickupLocationId = v_route_pickup
              AND dropoffLocationId = v_route_dropoff
              AND status = 'Waitlisted';

            -- Commit the update
            COMMIT;

            -- Break the inner loop after notifying one user
            EXIT;
        END LOOP;

        -- Close the waitlist cursor
        CLOSE waitlist_users;
    END LOOP;

    -- Close the shuttle cursor
    CLOSE available_shuttles;

    DBMS_OUTPUT.PUT_LINE('Waitlist notifications completed successfully.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
        RAISE;
END;
/

/*Procedure 6:ROUTE_CAPACITY_OPTIMIZATION. The ROUTE_CAPACITY_OPTIMIZATION procedure optimizes route assignments by analyzing capacity utilization. 
It reallocates shuttles from underutilized routes to high-demand routes, ensuring efficient use of resources.*/

CREATE OR REPLACE PROCEDURE route_capacity_optimization IS
    CURSOR high_demand_routes IS
        SELECT pickupLocationId, dropoffLocationId, COUNT(*) AS demand
        FROM rides
        WHERE status = 'Waitlisted'
        GROUP BY pickupLocationId, dropoffLocationId
        ORDER BY demand DESC;

    CURSOR underutilized_shuttles IS
        SELECT s.shuttle_id, s.model, COUNT(r.ride_id) AS current_rides
        FROM shuttles s
        LEFT JOIN trips t ON s.shuttle_id = t.shuttle_id
        LEFT JOIN rides r ON t.trip_id = r.trip_id
        WHERE t.startTime >= SYSDATE
        GROUP BY s.shuttle_id, s.model
        HAVING COUNT(r.ride_id) < (s.capacity * 0.5) -- Less than 50% utilization
        ORDER BY current_rides ASC;

    v_route_pickup VARCHAR2(50);
    v_route_dropoff VARCHAR2(50);
    v_demand NUMBER;
    v_shuttle_id shuttles.shuttle_id%TYPE;
    v_model shuttles.model%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Starting ROUTE_CAPACITY_OPTIMIZATION procedure...');

    -- Process high-demand routes
    FOR high_demand IN high_demand_routes LOOP
        v_route_pickup := high_demand.pickupLocationId;
        v_route_dropoff := high_demand.dropoffLocationId;
        v_demand := high_demand.demand;

        -- Log the high-demand route
        DBMS_OUTPUT.PUT_LINE('High-Demand Route: ' || v_route_pickup || ' -> ' || v_route_dropoff || ' with ' || v_demand || ' waitlisted rides.');

        -- Process underutilized shuttles for reassignment
        FOR underutilized IN underutilized_shuttles LOOP
            v_shuttle_id := underutilized.shuttle_id;
            v_model := underutilized.model;

            -- Log the shuttle reassignment
            DBMS_OUTPUT.PUT_LINE('Reassigning Shuttle: ' || v_shuttle_id || ' (' || v_model || ') to Route: ' || v_route_pickup || ' -> ' || v_route_dropoff);

            -- Update the shuttle assignment
            INSERT INTO trips (trip_id, startTime, endTime, status, shuttle_id)
            VALUES (
                'TRIP_' || v_shuttle_id || '_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI'),
                SYSDATE + INTERVAL '1' HOUR,
                SYSDATE + INTERVAL '2' HOUR,
                'Scheduled',
                v_shuttle_id
            );

            -- Exit the loop once the shuttle is reassigned to avoid over-allocation
            EXIT;
        END LOOP;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Route capacity optimization completed successfully.');
END;
/

/*Procedure 7:Auto Schedule Rides.The AUTO_SCHEDULE_RIDES procedure automates the assignment of unscheduled rides to available trips based on predefined conditions. The procedure ensures operational efficiency by scheduling rides in a way that matches their pickup and drop-off locations to appropriate trips. It updates the status of rides and assigns them to trips dynamically. */
CREATE OR REPLACE PROCEDURE auto_schedule_rides IS
    CURSOR unscheduled_rides IS
        SELECT ride_id, pickupLocationId, dropoffLocationId
        FROM rides
        WHERE status = 'Unscheduled';

    v_trip_id trips.trip_id%TYPE;
    v_shuttle_id trips.shuttle_id%TYPE;
    v_ride_id rides.ride_id%TYPE;
    v_pickupLocationId rides.pickupLocationId%TYPE;
    v_dropoffLocationId rides.dropoffLocationId%TYPE;
    v_capacity_remaining NUMBER;
BEGIN
    FOR ride_record IN unscheduled_rides LOOP
        v_ride_id := ride_record.ride_id;
        v_pickupLocationId := ride_record.pickupLocationId;
        v_dropoffLocationId := ride_record.dropoffLocationId;

        -- Find a suitable trip with capacity
        BEGIN
            SELECT t.trip_id, t.shuttle_id, 
                   (5 - COUNT(r.ride_id)) AS remaining_capacity -- Assuming a max capacity of 5 rides per trip
            INTO v_trip_id, v_shuttle_id, v_capacity_remaining
            FROM trips t
            LEFT JOIN rides r ON r.trip_id = t.trip_id
            WHERE t.status = 'Scheduled'
            GROUP BY t.trip_id, t.shuttle_id
            HAVING COUNT(r.ride_id) < 5 -- Change '5' to the actual trip capacity, if known
            FETCH FIRST ROW ONLY;

            -- If a trip is found, assign the ride
            UPDATE rides
            SET trip_id = v_trip_id,
                status = 'Scheduled'
            WHERE ride_id = v_ride_id;

            DBMS_OUTPUT.PUT_LINE('Ride ' || v_ride_id || ' assigned to Trip ' || v_trip_id);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('No available trip found for Ride ' || v_ride_id);
        END;
    END LOOP;
END;
/
/* TO CHECK Auto Schedule Rides Procedure
TRUNCATE TABLE TRIPS;
TRUNCATE TABLE RIDES;

SELECT * FROM trips;
SELECT * FROM rides;
SET SERVEROUTPUT ON;
BEGIN
    auto_schedule_rides;
END;


SELECT * FROM rides WHERE status = 'Scheduled';

INSERT INTO trips (trip_id, startTime, endTime, status, shuttle_id)
VALUES ('T3', TO_TIMESTAMP('2024-12-01 05:00:00', 'YYYY-MM-DD HH24:MI:SS'),
              TO_TIMESTAMP('2024-12-01 07:00:00', 'YYYY-MM-DD HH24:MI:SS'),
              'Scheduled', 'S3');

INSERT INTO trips (trip_id, startTime, endTime, status, shuttle_id)
VALUES ('T4', TO_TIMESTAMP('2024-12-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
              TO_TIMESTAMP('2024-12-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'),
              'Scheduled', 'S4');

-- Insert unscheduled rides linked to the placeholder trips
INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, status)
VALUES ('R4', 'L1', 'L3', 'T3', 'Unscheduled');

INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, status)
VALUES ('R5', 'L2', 'L4', 'T4', 'Unscheduled');

INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, status)
VALUES ('R6', 'L3', 'L5', 'T4', 'Unscheduled');


*/

--Procedure 8 - REASSIGN_VEHICLE_DURING_SHIFT 

CREATE OR REPLACE PROCEDURE REASSIGN_VEHICLE_DURING_SHIFT (
    shift_id IN VARCHAR2  -- ID of the shift that needs vehicle reassignment
) IS
    v_current_shuttle_id VARCHAR2(50);  -- Current shuttle assigned to the shift
    v_new_shuttle_id VARCHAR2(50);      -- New shuttle to be assigned
    v_is_under_maintenance NUMBER;      -- Variable to store maintenance check result
BEGIN
    -- Step 1: Retrieve the current shuttle assigned to the shift
    SELECT shuttle_id
    INTO v_current_shuttle_id
    FROM shifts
    WHERE shift_id = shift_id;

    -- Step 2: Check if the current shuttle is under maintenance
    SELECT COUNT(*)
    INTO v_is_under_maintenance
    FROM maintenance_schedules
    WHERE shuttle_id = v_current_shuttle_id
      AND maintenanceDate = TRUNC(SYSDATE);

    -- Step 3: If the shuttle is under maintenance, reassign it
    IF v_is_under_maintenance > 0 THEN
        -- Find a new available shuttle
        SELECT shuttle_id
        INTO v_new_shuttle_id
        FROM shuttles s
        WHERE NOT EXISTS (
            SELECT 1
            FROM maintenance_schedules m
            WHERE s.shuttle_id = m.shuttle_id
              AND m.maintenanceDate = TRUNC(SYSDATE)
        )
          AND shuttle_id != v_current_shuttle_id
        FETCH FIRST ROW ONLY;

        -- Update the shift with the new shuttle
        UPDATE shifts
        SET shuttle_id = v_new_shuttle_id
        WHERE shift_id = shift_id;

        -- Log the reassignment in the reassignment_log table
        INSERT INTO reassignment_log (shift_id, old_shuttle_id, new_shuttle_id, reassignment_time)
        VALUES (shift_id, v_current_shuttle_id, v_new_shuttle_id, SYSDATE);

        -- Commit the changes
        COMMIT;

        -- Print a success message
        DBMS_OUTPUT.PUT_LINE('Shuttle reassigned successfully for shift ID: ' || shift_id);
    ELSE
        -- Print a message if no reassignment is needed
        DBMS_OUTPUT.PUT_LINE('No reassignment needed for shift ID: ' || shift_id);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle cases where no available shuttle is found
        RAISE_APPLICATION_ERROR(-20002, 'No available shuttle found for reassignment.');
    WHEN OTHERS THEN
        -- Handle unexpected errors
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'An unexpected error occurred: ' || SQLERRM);
END;
/

--Procedure 9 MONITOR_FUEL_EFFICIENCY
-- Purpose: This procedure flags shuttles with mileage below the specified efficiency threshold
-- and inserts the flagged data into the fuel_efficiency_log table for monitoring purposes.

CREATE OR REPLACE PROCEDURE MONITOR_FUEL_EFFICIENCY (
    efficiency_threshold IN NUMBER  -- Expected efficiency threshold
) IS
    CURSOR inefficient_shuttles IS
        SELECT shuttle_id, model, mileage
        FROM shuttles
        WHERE mileage < efficiency_threshold;

    inefficient_record inefficient_shuttles%ROWTYPE;
BEGIN
    OPEN inefficient_shuttles;

    LOOP
        FETCH inefficient_shuttles INTO inefficient_record;
        EXIT WHEN inefficient_shuttles%NOTFOUND;

        INSERT INTO fuel_efficiency_log (
            shuttle_id, model, mileage, flagged_date
        ) VALUES (
            inefficient_record.shuttle_id,
            inefficient_record.model,
            inefficient_record.mileage,
            SYSDATE
        );
    END LOOP;

    CLOSE inefficient_shuttles;

    DBMS_OUTPUT.PUT_LINE('Fuel efficiency monitoring completed.');
END;
/

--Procedure - 10
-- Procedure: ASSIGN_BACKUP_DRIVERS
-- Purpose: Assigns backup drivers to unassigned shifts in the `shifts` table. 
-- Ensures that available drivers are not already assigned to overlapping shifts. 
-- Logs the assignments and handles exceptions for unavailable drivers or unexpected errors.


CREATE OR REPLACE PROCEDURE ASSIGN_BACKUP_DRIVERS AS
    -- Cursor to fetch shifts without assigned drivers
    CURSOR unassigned_shifts IS
        SELECT shift_id, shuttle_id, startTime, endTime
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
                AND (s.startTime <= shift_record.endTime AND s.endTime >= shift_record.startTime)
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
END;
/


