/*FINAL_VIEWS*/

CREATE OR REPLACE VIEW completely_or_partially_booked_shuttles AS
SELECT
    s.shuttle_id,
    s.model,
    s.capacity,
    COALESCE(SUM(r.status = 'booked'), 0) AS booked_count,
    CASE
        WHEN SUM(r.status = 'booked') = s.capacity THEN 'Completely Booked'
        WHEN SUM(r.status = 'booked') > 0 THEN 'Partially Booked'
        ELSE 'Available'
    END AS booking_status
FROM
    shuttles s
LEFT JOIN
    trips t ON s.shuttle_id = t.shuttle_id
LEFT JOIN
    rides r ON t.trip_id = r.trip_id
GROUP BY
    s.shuttle_id, s.model, s.capacity;
 
--select* from completely_or_partially_booked_shuttles;
 
CREATE OR REPLACE VIEW weekly_driver_schedule AS
SELECT
    d.driver_id,
    d.license_number,
    s.shift_id,
    s.shuttle_id,
    sh.model AS shuttle_model,
    sh.capacity AS shuttle_capacity,
    s.start_time,
    s.end_time,
    TO_CHAR(s.start_time, 'IW') AS week_number,  -- ISO week number for weekly grouping
    TO_CHAR(s.start_time, 'YYYY') AS year  -- Adding year to differentiate weeks across years
FROM
    drivers d
JOIN
    shifts s ON d.driver_id = s.driver_id
JOIN
    shuttles sh ON s.shuttle_id = sh.shuttle_id
ORDER BY
    d.driver_id,
    year,
    week_number,
    s.start_time;
 
 
CREATE OR REPLACE VIEW upcoming_maintenance_schedule AS
SELECT s.LICENSE_PLATE, s.model AS shuttle_model, sm.maintenance_id, sm.MAINTENANCE_DATE
from MAINTENANCE_SCHEDULES sm
join shuttles s on s.SHUTTLE_ID = sm.SHUTTLE_ID
where sm.MAINTENANCE_DATE > SYSDATE
ORDER BY
    sm.MAINTENANCE_DATE ASC;
 
 
CREATE OR REPLACE VIEW most_booked_routes AS
SELECT
    l1.location_id AS pickup_location_id,
    l1.name AS pickup_location_name,
    l2.location_id AS dropoff_location_id,
    l2.name AS dropoff_location_name,
    COUNT(r.ride_id) AS booking_count
FROM
    rides r
JOIN
    locations l1 ON r.pickup_location_id = l1.location_id
JOIN
    locations l2 ON r.dropoff_location_id = l2.location_id
GROUP BY
    l1.location_id, l1.name, l2.location_id, l2.name
ORDER BY
    booking_count DESC;
   
   
CREATE OR REPLACE VIEW top_users_by_rides_taken AS
SELECT
    u.user_id,
    u.name AS user_name,
    u.email,
    u.phone,
    COUNT(r.ride_id) AS rides_taken
FROM
    users u
JOIN
    rides r ON u.user_id = r.user_id
GROUP BY
    u.user_id, u.name, u.email, u.phone
ORDER BY
    rides_taken DESC;
 
 
CREATE OR REPLACE VIEW top_drivers_by_rides_driven AS
SELECT
    d.driver_id,
    d.license_number,
    COUNT(r.ride_id) AS rides_driven
FROM
    drivers d
JOIN
    shifts s ON d.driver_id = s.driver_id
JOIN
    trips t ON s.shuttle_id = t.shuttle_id  -- Assuming that shifts are associated with shuttles used in trips
JOIN
    rides r ON t.trip_id = r.trip_id
GROUP BY
    d.driver_id, d.license_number
ORDER BY
    rides_driven DESC;
 
 
CREATE OR REPLACE VIEW peak_time_for_riding AS
SELECT
    TO_CHAR(t.start_time, 'HH24') AS ride_hour,  -- Replace with actual column if different
    COUNT(r.ride_id) AS rides_count
FROM
    trips t
JOIN
    rides r ON t.trip_id = r.trip_id
GROUP BY
    TO_CHAR(t.start_time, 'HH24')
ORDER BY
    rides_count DESC;
   
   
CREATE OR REPLACE VIEW average_time_per_route AS
SELECT
    l1.location_id AS pickup_location_id,
    l1.name AS pickup_location_name,
    l2.location_id AS dropoff_location_id,
    l2.name AS dropoff_location_name,
    AVG(EXTRACT(HOUR FROM (t.end_time - t.start_time)) * 60 + EXTRACT(MINUTE FROM (t.end_time - t.start_time))) AS avg_travel_time_minutes
FROM
    rides r
JOIN
    trips t ON r.trip_id = t.trip_id
JOIN
    locations l1 ON r.pickup_location_id = l1.location_id
JOIN
    locations l2 ON r.dropoff_location_id = l2.location_id
WHERE
    t.end_time IS NOT NULL AND t.start_time IS NOT NULL  -- Ensures valid time data
GROUP BY
    l1.location_id, l1.name, l2.location_id, l2.name
ORDER BY
    avg_travel_time_minutes ASC;
 
 
CREATE OR REPLACE VIEW Upcoming_Bookings_View AS
SELECT
    r.ride_id,
    r.user_id,
    t.trip_id,
    t.start_time AS trip_start_time,
    t.end_time AS trip_end_time,
    s.shuttle_id,
    s.model AS shuttle_model,
    s.capacity AS shuttle_capacity,
    r.status AS booking_status
FROM
    rides r
JOIN
    trips t ON r.trip_id = t.trip_id
JOIN
    shuttles s ON t.shuttle_id = s.shuttle_id
WHERE
    t.start_time > SYSDATE  -- Only include upcoming bookings. The WHERE clause uses SYSDATE to filter for future trip start times, displaying only upcoming bookings.
-- If no data appears in the view, it may be because there are no trips scheduled in the future.
ORDER BY
    t.start_time ASC;
 
 
CREATE OR REPLACE VIEW Driver_Shift_Assignment_View AS
SELECT
    d.driver_id,
    d.license_number,
    s.shift_id,
    s.start_time AS shift_start_time,
    s.end_time AS shift_end_time,
    s.shuttle_id,
    sh.model AS shuttle_model,
    sh.capacity AS shuttle_capacity
FROM
    drivers d
JOIN
    shifts s ON d.driver_id = s.driver_id
JOIN
    shuttles sh ON s.shuttle_id = sh.shuttle_id
ORDER BY
    d.driver_id, s.start_time;
 
 
CREATE OR REPLACE VIEW Vehicle_Maintenance_Status_View AS
SELECT
    sh.shuttle_id,
    sh.model AS shuttle_model,
    sh.capacity AS shuttle_capacity,
    sh.license_Plate,
    ms.maintenance_id,
    ms.maintenance_date,
    ms.description AS maintenance_description,
    CASE
        WHEN ms.maintenance_date > SYSDATE THEN 'Scheduled'
        WHEN ms.maintenance_date <= SYSDATE THEN 'Completed'
        ELSE 'Unknown'
    END AS maintenance_status
FROM
    shuttles sh
LEFT JOIN
    maintenance_schedules ms ON sh.shuttle_id = ms.shuttle_id
ORDER BY
    sh.shuttle_id, ms.maintenance_date DESC;
   
   
CREATE OR REPLACE VIEW Route_Utilization_View AS
SELECT
    l1.location_id AS pickup_location_id,
    l1.name AS pickup_location_name,
    l2.location_id AS dropoff_location_id,
    l2.name AS dropoff_location_name,
    COUNT(r.ride_id) AS utilization_count
FROM
    rides r
JOIN
    locations l1 ON r.pickup_location_id = l1.location_id
JOIN
    locations l2 ON r.dropoff_location_id = l2.location_id
GROUP BY
    l1.location_id, l1.name, l2.location_id, l2.name
ORDER BY
    utilization_count DESC;
   
CREATE OR REPLACE VIEW Ride_Notifications_View AS
SELECT
    r.ride_id,
    r.user_id,
    u.name AS user_name,
    u.email AS user_email,
    t.trip_id,
    t.start_time AS trip_start_time,
    t.end_time AS trip_end_time,
    CASE
        WHEN t.start_time BETWEEN SYSDATE AND (SYSDATE + INTERVAL '1' DAY) THEN 'Upcoming within 24 hours'
        WHEN t.start_time > SYSDATE THEN 'Scheduled'
        ELSE 'Past Ride'
    END AS notification_status
FROM
    rides r
JOIN
    trips t ON r.trip_id = t.trip_id
JOIN
    users u ON r.user_id = u.user_id
WHERE
    t.start_time IS NOT NULL
ORDER BY
    t.start_time ASC;
     
   
CREATE OR REPLACE VIEW Shift_Logs_View AS
SELECT
    s.shift_id,
    s.start_time AS shift_start_time,
    s.end_time AS shift_end_time,
    d.driver_id,
    d.licence_number AS driver_license,
    sh.shuttle_id,
    sh.model AS shuttle_model,
    sh.capacity AS shuttle_capacity,
    CASE
        WHEN s.start_time <= SYSDATE AND s.end_time >= SYSDATE THEN 'Ongoing'
        WHEN s.end_time < SYSDATE THEN 'Completed'
        WHEN s.start_time > SYSDATE THEN 'Scheduled'
        ELSE 'Unknown'
    END AS shift_status
FROM
    shifts s
JOIN
    drivers d ON s.driver_id = d.driver_id
JOIN
    shuttles sh ON s.shuttle_id = sh.shuttle_id
ORDER BY
    s.start_time DESC;
 
 
 
 
/*FOR MANAGER
VIEW: SHUTTLE_DUE_FOR_MAINTENANCE*/
CREATE OR REPLACE VIEW shuttles_due_for_maintenance AS
WITH total_mileage AS (
    SELECT
        shuttle_id,
        SUM(mileage_added) AS total_mileage
    FROM
        shuttle_mileage_records
    GROUP BY
        shuttle_id
)
SELECT
    s.model,
    s.license_plate,
    NVL(ms.last_maintenance_mileage, 0) as "Last Maintenance Mileage",
    COALESCE(tm.total_mileage, 0) AS current_mileage,
    case
        when COALESCE(tm.total_mileage, 0) - NVL(ms.last_maintenance_mileage, 0) >= 50 THEN 'Required'
        ELSE 'Not Required'
    END AS maintenance_status
FROM
    shuttles s
LEFT OUTER JOIN
    maintenance_schedules ms ON s.shuttle_id = ms.shuttle_id
JOIN
    total_mileage tm ON s.shuttle_id = tm.shuttle_id;