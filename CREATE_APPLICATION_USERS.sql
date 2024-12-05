-- Create User Block
DECLARE
    user_exists NUMBER;
BEGIN
    -- Check if the user 'manager' exists in DBA_USERS
    SELECT COUNT(*)
    INTO user_exists
    FROM dba_users
    WHERE username = 'manager';

    -- Create the user
    EXECUTE IMMEDIATE 'CREATE USER manager IDENTIFIED BY NeuBoston2024#';

    EXECUTE IMMEDIATE 'CREATE USER piyush IDENTIFIED BY NeuBoston2024#';
    EXECUTE IMMEDIATE 'CREATE USER sneha IDENTIFIED BY NeuBoston2024#';
    EXECUTE IMMEDIATE 'CREATE USER deepak IDENTIFIED BY NeuBoston2024#';
    EXECUTE IMMEDIATE 'CREATE USER bhavya IDENTIFIED BY NeuBoston2024#';

    -- Create a driver user
    EXECUTE IMMEDIATE 'CREATE USER driver IDENTIFIED BY NeuBoston2024#';

    -- Create a analyst user
    EXECUTE IMMEDIATE 'CREATE USER analyst IDENTIFIED BY NeuBoston2024#';
END;
/

CREATE USER manager IDENTIFIED BY NeuBoston2024#;
CREATE USER piyush IDENTIFIED BY NeuBoston2024#;
CREATE USER sneha IDENTIFIED BY NeuBoston2024#;
CREATE USER deepak IDENTIFIED BY NeuBoston2024#;
CREATE USER bhavya IDENTIFIED BY NeuBoston2024#;

-- CREATE USER analyst IDENTIFIED BY NeuBoston2024#;
CREATE USER driver IDENTIFIED BY NeuBoston2024#;

-- Grant Privileges to manager to the application
GRANT CREATE SESSION TO manager;

-- Has access to all packages in the application
GRANT EXECUTE ON redeye.shift_management_pkg TO manager;
GRANT EXECUTE ON redeye.asset_management_pkg TO manager;
GRANT EXECUTE ON redeye.ride_management_pkg TO manager;
GRANT EXECUTE ON redeye.redeye_user_management_pkg TO manager;

-- Grant Privileges to piyush, sneha, deepak, bhavya to the application
GRANT CREATE SESSION TO piyush;
GRANT CREATE SESSION TO sneha;
GRANT CREATE SESSION TO deepak;
GRANT CREATE SESSION TO bhavya;

-- Has access to redeye_user_management_pkg in the application
GRANT EXECUTE ON redeye.redeye_user_management_pkg TO piyush;
GRANT EXECUTE ON redeye.redeye_user_management_pkg TO sneha;
GRANT EXECUTE ON redeye.redeye_user_management_pkg TO deepak;
GRANT EXECUTE ON redeye.redeye_user_management_pkg TO bhavya;

GRANT SELECT ON redeye.RIDES_HISTORY TO piyush;
GRANT SELECT ON redeye.RIDES_HISTORY TO sneha;
GRANT SELECT ON redeye.RIDES_HISTORY TO deepak;
GRANT SELECT ON redeye.RIDES_HISTORY TO bhavya;

GRANT SELECT ON redeye.view_all_dropoff_locations TO piyush;
GRANT SELECT ON redeye.view_all_dropoff_locations TO sneha;
GRANT SELECT ON redeye.view_all_dropoff_locations TO deepak;
GRANT SELECT ON redeye.view_all_dropoff_locations TO bhavya;


-- Grant Privileges to driver to the application
GRANT CREATE SESSION TO driver;

-- Has access to driver_management_pkg in the application
GRANT EXECUTE ON redeye.driver_management_pkg TO driver;
GRANT SELECT on redeye.weekly_driver_schedule TO driver;

-- Grant Privileges to analyst to the application
GRANT CREATE SESSION TO analyst;

-- Has access to report views in the application
GRANT SELECT ON redeye.shuttle_mileage_records TO analyst;
GRANT SELECT ON redeye.shift_logs_view TO analyst;
GRANT SELECT ON redeye.route_utilization_view TO analyst;
GRANT SELECT ON redeye.shuttles_due_for_maintenance TO analyst;
GRANT SELECT ON redeye.upcoming_maintenance_schedule TO analyst;
GRANT SELECT ON redeye.top_drivers_by_rides_driven TO analyst;
GRANT SELECT ON redeye.top_users_by_rides_taken TO analyst;
GRANT SELECT ON redeye.most_booked_routes TO analyst;
GRANT SELECT ON redeye.peak_time_for_riding TO analyst;
GRANT SELECT ON redeye.average_time_per_route TO analyst;
GRANT SELECT ON redeye.average_cancels_per_day TO analyst;
GRANT SELECT ON redeye.completely_or_partially_booked_shuttles TO analyst;
GRANT SELECT ON redeye.shuttle_efficiency_and_mileage_trends TO analyst;
GRANT SELECT ON redeye.maintenance_per_month TO analyst;


-- same access on views for manager
GRANT SELECT ON redeye.shuttle_mileage_records TO manager;
GRANT SELECT ON redeye.shift_logs_view TO manager;
GRANT SELECT ON redeye.route_utilization_view TO manager;
GRANT SELECT ON redeye.shuttles_due_for_maintenance TO manager;
GRANT SELECT ON redeye.upcoming_maintenance_schedule TO manager;
GRANT SELECT ON redeye.top_drivers_by_rides_driven TO manager;
GRANT SELECT ON redeye.top_users_by_rides_taken TO manager;
GRANT SELECT ON redeye.most_booked_routes TO manager;
GRANT SELECT ON redeye.peak_time_for_riding TO manager;
GRANT SELECT ON redeye.average_time_per_route TO manager;
GRANT SELECT ON redeye.average_cancels_per_day TO manager;
GRANT SELECT ON redeye.completely_or_partially_booked_shuttles TO manager;
GRANT SELECT ON redeye.shuttle_efficiency_and_mileage_trends TO manager;
GRANT SELECT ON redeye.maintenance_per_month TO manager;
