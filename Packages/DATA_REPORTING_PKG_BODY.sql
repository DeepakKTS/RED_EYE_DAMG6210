CREATE OR REPLACE PACKAGE BODY Shuttle_Management_Pkg AS

    -- Procedure to generate shuttle utilization report
    PROCEDURE Generate_Shuttle_Utilization_Report IS
        CURSOR shuttle_utilization IS
            SELECT s.shuttle_id, s.model, s.capacity,
                   COUNT(CASE WHEN r.status = 'booked' THEN 1 END) AS booked_count,
                   CASE 
                       WHEN COUNT(CASE WHEN r.status = 'booked' THEN 1 END) = s.capacity THEN 'Completely Booked'
                       WHEN COUNT(CASE WHEN r.status = 'booked' THEN 1 END) > 0 THEN 'Partially Booked'
                       ELSE 'Available'
                   END AS booking_status
            FROM shuttles s
            LEFT JOIN trips t ON s.shuttle_id = t.shuttle_id
            LEFT JOIN rides r ON t.trip_id = r.trip_id
            GROUP BY s.shuttle_id, s.model, s.capacity;

    BEGIN
        FOR rec IN shuttle_utilization LOOP
            DBMS_OUTPUT.PUT_LINE('Shuttle ID: ' || rec.shuttle_id ||
                                 ', Model: ' || rec.model ||
                                 ', Capacity: ' || rec.capacity ||
                                 ', Status: ' || rec.booking_status);
        END LOOP;
    END Generate_Shuttle_Utilization_Report;

    -- Procedure to generate driver shift schedule
    PROCEDURE Generate_Driver_Shift_Schedule IS
        CURSOR driver_schedule IS
            SELECT d.driver_id, d.licenseNumber, s.shift_id, sh.model, sh.capacity,
                   s.startTime, s.endTime
            FROM drivers d
            JOIN shifts s ON d.driver_id = s.driver_id
            JOIN shuttles sh ON s.shuttle_id = sh.shuttle_id
            ORDER BY d.driver_id, s.startTime;

        schedule_line VARCHAR2(255);
    BEGIN
        FOR rec IN driver_schedule LOOP
            schedule_line := 'Driver ID: ' || rec.driver_id ||
                             ', License: ' || rec.licenseNumber ||
                             ', Shift ID: ' || rec.shift_id ||
                             ', Shuttle Model: ' || rec.model ||
                             ', Start Time: ' || rec.startTime ||
                             ', End Time: ' || rec.endTime;
            DBMS_OUTPUT.PUT_LINE(schedule_line);
        END LOOP;
    END Generate_Driver_Shift_Schedule;

    -- Procedure to manage ride notifications
    PROCEDURE Manage_Ride_Notifications IS
        CURSOR ride_notifications IS
            SELECT r.ride_id, r.user_id, u.name AS user_name, u.email, t.startTime,
                   CASE 
                       WHEN t.startTime BETWEEN SYSDATE AND (SYSDATE + INTERVAL '1' DAY) THEN 'Upcoming within 24 hours'
                       WHEN t.startTime > SYSDATE THEN 'Scheduled'
                       ELSE 'Past Ride'
                   END AS notification_status
            FROM rides r
            JOIN trips t ON r.trip_id = t.trip_id
            JOIN users u ON r.user_id = u.user_id
            WHERE t.startTime IS NOT NULL
            ORDER BY t.startTime;

        notification_line VARCHAR2(255);
    BEGIN
        FOR rec IN ride_notifications LOOP
            notification_line := 'Ride ID: ' || rec.ride_id ||
                                 ', User: ' || rec.user_name ||
                                 ', Status: ' || rec.notification_status;
            DBMS_OUTPUT.PUT_LINE(notification_line);
        END LOOP;
    END Manage_Ride_Notifications;

    -- Procedure to check vehicle maintenance status
    PROCEDURE Check_Maintenance_Status IS
        CURSOR maintenance_status IS
            SELECT sh.shuttle_id, sh.model, ms.maintenanceDate,
                   CASE 
                       WHEN ms.maintenanceDate > SYSDATE THEN 'Scheduled'
                       WHEN ms.maintenanceDate <= SYSDATE THEN 'Completed'
                       ELSE 'Unknown'
                   END AS status
            FROM shuttles sh
            LEFT JOIN maintenance_schedules ms ON sh.shuttle_id = ms.shuttle_id
            ORDER BY ms.maintenanceDate;

        maintenance_line VARCHAR2(255);
    BEGIN
        FOR rec IN maintenance_status LOOP
            maintenance_line := 'Shuttle ID: ' || rec.shuttle_id ||
                                ', Model: ' || rec.model ||
                                ', Maintenance Date: ' || rec.maintenanceDate ||
                                ', Status: ' || rec.status;
            DBMS_OUTPUT.PUT_LINE(maintenance_line);
        END LOOP;
    END Check_Maintenance_Status;

    -- Function to calculate average trip time for a route
    FUNCTION Calculate_Average_Trip_Time(pickup_location_id IN VARCHAR2, dropoff_location_id IN VARCHAR2) RETURN NUMBER IS
        avg_time NUMBER;
    BEGIN
        SELECT AVG(EXTRACT(HOUR FROM (t.endTime - t.startTime)) * 60 + EXTRACT(MINUTE FROM (t.endTime - t.startTime)))
        INTO avg_time
        FROM rides r
        JOIN trips t ON r.trip_id = t.trip_id
        WHERE r.pickupLocationId = pickup_location_id AND r.dropoffLocationId = dropoff_location_id;

        RETURN avg_time;
    END Calculate_Average_Trip_Time;

    -- Procedure to flag underutilized routes
    PROCEDURE Flag_Underutilized_Routes(threshold IN NUMBER) IS
        CURSOR underutilized_routes IS
            SELECT l1.name AS pickup_location, l2.name AS dropoff_location, COUNT(r.ride_id) AS ride_count
            FROM rides r
            JOIN locations l1 ON r.pickupLocationId = l1.location_id
            JOIN locations l2 ON r.dropoffLocationId = l2.location_id
            GROUP BY l1.name, l2.name
            HAVING COUNT(r.ride_id) < threshold;

        route_line VARCHAR2(255);
    BEGIN
        FOR rec IN underutilized_routes LOOP
            route_line := 'Route: ' || rec.pickup_location || ' -> ' || rec.dropoff_location || ', Ride Count: ' || rec.ride_count;
            DBMS_OUTPUT.PUT_LINE('Flagging underutilized route: ' || route_line);
        END LOOP;
    END Flag_Underutilized_Routes;

END Shuttle_Management_Pkg;
/
