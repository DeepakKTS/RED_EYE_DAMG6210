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