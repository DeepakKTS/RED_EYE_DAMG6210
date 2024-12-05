/*FINAL_VIEWS*/

CREATE OR REPLACE VIEW completely_or_partially_booked_shuttles AS
SELECT
    s.license_plate,
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
    s.LICENSE_PLATE, s.model, s.capacity;
 
--select* from completely_or_partially_booked_shuttles;
 
CREATE OR REPLACE VIEW weekly_driver_schedule AS
SELECT
    u.name AS driver_name,
    d.license_number,
    s.shift_id,
    sh.license_plate,
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
JOIN
    users u ON d.driver_id = u.user_id
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
    l1.name AS pickup_location_name,
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
    booking_count DESC
FETCH FIRST 5 ROWS ONLY;
   
   
CREATE OR REPLACE VIEW top_users_by_rides_taken AS
SELECT
    u.name AS user_name,
    u.email,
    COUNT(r.ride_id) AS rides_taken
FROM
    users u
JOIN
    rides r ON u.user_id = r.user_id
GROUP BY
    u.user_id, u.name, u.email, u.phone
ORDER BY
    rides_taken DESC
FETCH FIRST 5 ROWS ONLY;
 
 
CREATE OR REPLACE VIEW top_drivers_by_rides_driven AS
SELECT
    u.name as driver_name,
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
JOIN
    users u ON d.driver_id = u.user_id
GROUP BY
    d.license_number, u.name
ORDER BY
    rides_driven DESC
FETCH FIRST 5 ROWS ONLY;
 
 
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

CREATE OR REPLACE VIEW shifts_logs_view AS
SELECT
    s.shift_id,
    s.start_time AS shift_start_time,
    s.end_time AS shift_end_time,
    u.name AS driver_name,
    d.license_number AS driver_license,
    sh.license_plate AS shuttle_license_plate,
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
JOIN
    users u ON d.driver_id = u.user_id
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


/*The MaintenancePerMonth view is a summarized representation of maintenance activities, 
grouped by month and year. It allows administrators or analysts to easily track the 
number of maintenance schedules conducted for shuttles on a monthly basis*/

CREATE OR REPLACE VIEW maintenance_per_month AS
SELECT
    TO_CHAR(ms.maintenance_Date, 'YYYY-MM') AS maintenance_month,
    sh.license_plate AS shuttle_license_plate,
    COUNT(1) AS maintenance_count
FROM
    maintenance_schedules ms
JOIN 
shuttles sh ON ms.shuttle_id = sh.shuttle_id
WHERE
    ms.maintenance_Date IS NOT NULL
GROUP BY
    TO_CHAR(ms.maintenance_Date, 'YYYY-MM'),
    sh.license_plate
ORDER BY
    TO_CHAR(ms.maintenance_Date, 'YYYY-MM');

/*The Shuttle Efficiency and Mileage Trends Report provides a comprehensive analysis of shuttle usage by summarizing daily mileage trends, cumulative total mileage, and the total number of trips completed for each shuttle. This report helps identify utilization patterns, peak usage times, and potential underutilization of shuttle assets.*/

CREATE OR REPLACE VIEW shuttle_efficiency_and_mileage_trends AS
WITH daily_mileage AS (
    SELECT 
        smr.shuttle_id as shuttle_id,
        sh.license_plate AS shuttle_license_plate,
        TRUNC(smr.updated_at) AS mileage_date,
        SUM(smr.mileage_added) AS daily_mileage_added
    FROM 
        shuttle_mileage_records smr
    JOIN
        shuttles sh ON smr.shuttle_id = sh.shuttle_id
    GROUP BY 
        smr.shuttle_id, sh.license_plate, TRUNC(smr.updated_at)
),
total_mileage AS (
    SELECT 
        shuttle_id,
        SUM(mileage_added) AS total_mileage
    FROM 
        shuttle_mileage_records
    GROUP BY 
        shuttle_id
),
trip_count AS (
    SELECT 
        shuttle_id,
        COUNT(trip_id) AS trip_count
    FROM 
        shuttle_mileage_records
    GROUP BY 
        shuttle_id
)
SELECT 
    dm.shuttle_license_plate,
    dm.mileage_date,
    dm.daily_mileage_added,
    tm.total_mileage,
    tc.trip_count
FROM 
    daily_mileage dm
LEFT JOIN 
    total_mileage tm
ON 
    dm.shuttle_id = tm.shuttle_id
LEFT JOIN 
    trip_count tc
ON 
    dm.shuttle_id = tc.shuttle_id
ORDER BY 
    dm.shuttle_id, dm.mileage_date;


/*The Most Frequent Routes Report identifies popular routes by analyzing the frequency of trips between pickup and drop-off locations. It provides insights to optimize route planning and improve shuttle availability based on demand.*/
CREATE OR REPLACE VIEW most_frequent_routes_report AS
SELECT 
    l1.name AS pickup_location_name,
    l2.name AS dropoff_location_name,
    COUNT(*) AS trip_count
FROM 
    rides r
INNER JOIN 
    locations l1 ON r.pickup_Location_Id = l1.location_id
INNER JOIN 
    locations l2 ON r.dropoff_Location_Id = l2.location_id
GROUP BY 
    r.pickup_Location_Id, l1.name, r.dropoff_Location_Id, l2.name
ORDER BY 
    trip_count DESC;
    

/*Report - Average Cancels per day*/
CREATE OR REPLACE VIEW average_cancels_per_day AS
SELECT
    TRUNC(t.start_time) AS trip_date,                         -- Extract the date from the start_time
    COUNT(CASE WHEN r.status = 'CANCELLED' THEN 1 END) AS cancels_per_day, -- Count canceled trips for the day
    ROUND(
        COUNT(CASE WHEN r.status = 'CANCELLED' THEN 1 END) * 1.0 / 
        COUNT(DISTINCT TRUNC(t.start_time)), 2
    ) AS average_cancels,                                   -- Calculate the average cancels per day
    LISTAGG(SUBSTR(r.ride_id, 0, 8), ', ') WITHIN GROUP (ORDER BY r.ride_id) AS ride_ids, -- Aggregate trip IDs
    LISTAGG(t.shuttle_id, ', ') WITHIN GROUP (ORDER BY t.shuttle_id) AS shuttle_ids -- Aggregate shuttle IDs
FROM
    trips t
JOIN 
    rides r ON t.trip_id = r.trip_id
WHERE
    r.status = 'CANCELLED'
GROUP BY
    TRUNC(t.start_time)
ORDER BY
    trip_date;


CREATE OR REPLACE VIEW RIDES_HISTORY AS
SELECT
    r.ride_id,
    l.name AS pickup_location,
    l2.name AS dropoff_location,
    r.trip_id,
    u.name AS user_name,
    u.email AS user_email,
    r.status,
    t.start_time,
    t.end_time,
    t.status AS trip_status,
    sh.model AS shuttle_model,
    sh.license_plate AS shuttle_license_plate
FROM
    rides r
JOIN
    locations l ON r.pickup_location_id = l.location_id
JOIN
    locations l2 ON r.dropoff_location_id = l2.location_id
JOIN
    trips t ON r.trip_id = t.trip_id
JOIN
    users u ON r.user_id = u.user_id
JOIN
    shuttles sh ON t.shuttle_id = sh.shuttle_id
ORDER BY
    t.start_time DESC;
    
    
CREATE OR REPLACE VIEW view_all_dropoff_locations AS
SELECT
    l.name AS dropoff_location
FROM
    LOCATIONS l
WHERE 
    l.is_active = 1 AND LOCATION_ID  != 'L1'
