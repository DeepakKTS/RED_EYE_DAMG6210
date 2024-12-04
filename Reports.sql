/*The MaintenancePerMonth view is a summarized representation of maintenance activities, 
grouped by month and year. It allows administrators or analysts to easily track the 
number of maintenance schedules conducted for shuttles on a monthly basis*/

CREATE OR REPLACE VIEW MaintenancePerMonth AS
SELECT
    TO_CHAR(maintenanceDate, 'YYYY-MM') AS maintenance_month,
    COUNT(*) AS maintenance_count
FROM
    maintenance_schedules
GROUP BY
    TO_CHAR(maintenanceDate, 'YYYY-MM')
ORDER BY
    maintenance_month;


