/*The MaintenancePerMonth view is a summarized representation of maintenance activities, 
grouped by month and year. It allows administrators or analysts to easily track the 
number of maintenance schedules conducted for shuttles on a monthly basis*/

CREATE OR REPLACE VIEW MaintenancePerMonth AS
SELECT
    TO_CHAR(maintenanceDate, 'YYYY-MM') AS maintenance_month,
    shuttle_id,
    COUNT(*) AS maintenance_count
FROM
    maintenance_schedules
GROUP BY
    TO_CHAR(maintenanceDate, 'YYYY-MM'),
    shuttle_id
ORDER BY
    maintenance_month, shuttle_id;

/*The Shuttle Efficiency and Mileage Trends Report provides a comprehensive analysis of shuttle usage by summarizing daily mileage trends, cumulative total mileage, and the total number of trips completed for each shuttle. This report helps identify utilization patterns, peak usage times, and potential underutilization of shuttle assets.*/
CREATE OR REPLACE VIEW shuttle_efficiency_and_mileage_trends AS
WITH daily_mileage AS (
    SELECT 
        shuttle_id,
        TRUNC(updated_at) AS mileage_date,
        SUM(mileage_added) AS daily_mileage_added,
        MAX(total_mileage) AS total_mileage
    FROM 
        shuttle_mileage_records
    GROUP BY 
        shuttle_id, TRUNC(updated_at)
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
    dm.shuttle_id,
    dm.mileage_date,
    dm.daily_mileage_added,
    dm.total_mileage,
    tc.trip_count
FROM 
    daily_mileage dm
LEFT JOIN 
    trip_count tc
ON 
    dm.shuttle_id = tc.shuttle_id
ORDER BY 
    dm.shuttle_id, dm.mileage_date;

/*The Most Frequent Routes Report identifies popular routes by analyzing the frequency of trips between pickup and drop-off locations. It provides insights to optimize route planning and improve shuttle availability based on demand.*/
CREATE OR REPLACE VIEW most_frequent_routes_report AS
SELECT 
    r.pickupLocationId AS pickup_location_id,
    l1.name AS pickup_location_name,
    r.dropoffLocationId AS dropoff_location_id,
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
---The TOPDRIVERS view ranks drivers based on performance metrics, aggregating data to show total hours worked and trips completed.
CREATE OR REPLACE VIEW TOPDRIVERS AS
SELECT
    d.driver_id,
    -- Calculate total hours worked (sum of the difference between start and end times)
    ROUND(SUM(EXTRACT(HOUR FROM (s.end_time - s.start_time)) + 
              EXTRACT(MINUTE FROM (s.end_time - s.start_time)) / 60), 2) AS total_hours_worked,
    -- Calculate the total number of trips taken by the driver
    COUNT(t.trip_id) AS total_trips_taken
FROM
    drivers d
JOIN
    shifts s ON d.driver_id = s.driver_id
LEFT JOIN
    trips t ON s.shuttle_id = t.shuttle_id -- Join on shuttle_id instead of shift_id
GROUP BY
    d.driver_id
ORDER BY
    total_trips_taken DESC, total_hours_worked DESC;

 /*Report - Average Cancels per day*/
 CREATE OR REPLACE VIEW AverageCancelsPerDay AS
SELECT
    TRUNC(t.startTime) AS trip_date,                         -- Extract the date from the startTime
    COUNT(CASE WHEN t.status = 'Cancelled' THEN 1 END) AS cancels_per_day, -- Count canceled trips for the day
    ROUND(
        COUNT(CASE WHEN t.status = 'Cancelled' THEN 1 END) * 1.0 / 
        COUNT(DISTINCT TRUNC(t.startTime)), 2
    ) AS average_cancels,                                   -- Calculate the average cancels per day
    LISTAGG(t.trip_id, ', ') WITHIN GROUP (ORDER BY t.trip_id) AS trip_ids, -- Aggregate trip IDs
    LISTAGG(t.shuttle_id, ', ') WITHIN GROUP (ORDER BY t.shuttle_id) AS shuttle_ids -- Aggregate shuttle IDs
FROM
    trips t
GROUP BY
    TRUNC(t.startTime)
ORDER BY
    trip_date;