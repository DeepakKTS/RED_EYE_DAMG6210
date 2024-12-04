-- Add shuttles
-- BEGIN
--     asset_management_pkg.add_new_shuttle('Toyota', 'ABC123');
--     asset_management_pkg.add_new_shuttle('Honda', 'XYZ456');
--     asset_management_pkg.add_new_shuttle('Ford', 'DEF789');
--     asset_management_pkg.add_new_shuttle('Chevrolet', 'GHI101');
--     asset_management_pkg.add_new_shuttle('Nissan', 'JKL112');
-- END;


-- -- Add user
-- BEGIN
--     asset_management_pkg.add_new_user('Piyush Dongre', 'piyush@redeye.com','7377377327');
-- END;

-- Schedule shifts
BEGIN
    shift_management_pkg.create_shifts(SYSDATE);
END;

SELECT * FROM SHUTTLES;
SELECT * FROM shifts;

TRUNCATE table shifts;

SELECT * FROM DRIVERS;

SELECT shuttle_id
FROM shuttles
WHERE shuttle_id NOT IN (
    SELECT shuttle_id
    FROM shifts
    WHERE trunc(start_time) = trunc(SYSDATE)
) AND shuttle_id NOT IN (
    SELECT shuttle_id
    FROM maintenance_schedules 
    WHERE maintenance_date = trunc(SYSDATE)
)
AND is_active = 1;

SELECT * FROM shifts;
SELECT driver_id
FROM drivers
WHERE driver_id NOT IN (
    SELECT driver_id
    FROM shifts
    WHERE trunc(start_time) = trunc(SYSDATE) - 1
    OR trunc(start_time) = trunc(SYSDATE)
    or trunc(start_time) = trunc(SYSDATE) + 1
)
AND is_active = 1;

SELECT sysdate from dual;
