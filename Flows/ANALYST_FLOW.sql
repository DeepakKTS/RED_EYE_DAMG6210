-- Check mileage records for shuttle with license plate 'DEF789'
SELECT * FROM redeye.shuttle_mileage_records WHERE shuttle_id = 'DEF789';

-- Check the shift logs for shuttle with license plate 'DEF789'
SELECT * FROM redeye.shift_logs_view WHERE shuttle_id = 'DEF789';

-- Check the route utilization for shuttle with license plate 'DEF789'
SELECT * FROM redeye.route_utilization_view WHERE shuttle_id = 'DEF789';

-- Check the maintenance schedule for shuttle with license plate 'DEF789'
SELECT * FROM redeye.upcoming_maintenance_schedule WHERE shuttle_id = 'DEF789';

-- Check the top drivers by rides driven
SELECT * FROM redeye.top_drivers_by_rides_driven;

-- Check the top users by rides taken
SELECT * FROM redeye.top_users_by_rides_taken;

-- Check the most booked routes
SELECT * FROM redeye.most_booked_routes;

-- Check the peak time for riding
SELECT * FROM redeye.peak_time_for_riding;

-- Check the average time per route
SELECT * FROM redeye.average_time_per_route;  

-- Check the average cancels per day
SELECT * FROM redeye.average_cancels_per_day;

-- Check the completely or partially booked shuttles
SELECT * FROM redeye.completely_or_partially_booked_shuttles;

-- Check the shuttle efficiency and mileage trends
SELECT * FROM redeye.shuttle_efficiency_and_mileage_trends;

-- Check the maintenance per month
SELECT * FROM redeye.maintenance_per_month; 

-- --------------------------------------------------------
