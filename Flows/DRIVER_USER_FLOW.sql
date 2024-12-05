
ALTER SESSION SET CURRENT_SCHEMA = schema_name;

-- view shifts
SELECT * FROM weekly_driver_schedule;

-- update driver profile
BEGIN
redeye.driver_management_pkg.update_driver_profile(
    'Jane',
    'jane.doe@example.com',
    1234567890
    );
END;
