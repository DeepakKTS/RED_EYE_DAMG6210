-- SET SCHEMA 'REDEYE';
ALTER SESSION SET CURRENT_SCHEMA = REDEYE;

-- Add shuttles
BEGIN
    asset_management_pkg.add_new_shuttle('Toyota', 'ABC123');
    asset_management_pkg.add_new_shuttle('Honda', 'XYZ456');
    asset_management_pkg.add_new_shuttle('Ford', 'DEF789');
    asset_management_pkg.add_new_shuttle('Chevrolet', 'GHI101');
    asset_management_pkg.add_new_shuttle('Nissan', 'JKL112');
END;
/

-- -- Add user
BEGIN
    asset_management_pkg.add_new_user('Piyush Dongre1', 'piyush1@redeye.com','7377377327');
    asset_management_pkg.add_new_user('Sneha1', 'sneha1@redeye.com','7377377328');
    asset_management_pkg.add_new_user('Deepak1', 'deepak1@redeye.com','7377377329');
    asset_management_pkg.add_new_user('Bhavya1', 'bhavya1@redeye.com','7377377320');
END;
/
-- Calling the asset_management_pkg.add_new_driver procedure for 8 drivers with TP_IDs from TPS1 to TPS5
BEGIN
    asset_management_pkg.add_new_driver('John Doe', 'john.doe@example.com', 1234567890, 'DL1234567', 'TPS1');
    asset_management_pkg.add_new_driver('Jane Smith', 'jane.smith@example.com', 9876543210, 'DL2345678', 'TPS2');
    asset_management_pkg.add_new_driver('Robert Brown', 'robert.brown@example.com', 5551234567, 'DL3456789', 'TPS3');
    asset_management_pkg.add_new_driver('Emily Clark', 'emily.clark@example.com', 4443217654, 'DL4567890', 'TPS4');
    asset_management_pkg.add_new_driver('Michael Johnson', 'michael.johnson@example.com', 3339876543, 'DL5678901', 'TPS5');
    asset_management_pkg.add_new_driver('Sarah Lee', 'sarah.lee@example.com', 2226543210, 'DL6789012', 'TPS1');
    asset_management_pkg.add_new_driver('David Kim', 'david.kim@example.com', 1113219876, 'DL7890123', 'TPS2');
    asset_management_pkg.add_new_driver('Olivia Wilson', 'olivia.wilson@example.com', 8883216543, 'DL8901234', 'TPS3');
END;
/

----calling procedure  for location 
-- Calling the asset_management_pkg.add_new_location procedure for 8 simple locations

BEGIN
asset_management_pkg.add_new_location('Main Office', '123 Main St, City');
asset_management_pkg.add_new_location('Warehouse', '456 Industrial Rd, City');
asset_management_pkg.add_new_location('Store 1', '789 Market St, City');
asset_management_pkg.add_new_location('Store 2', '101 High St, City');
asset_management_pkg.add_new_location('Parking Lot', '202 Oak St, City');
asset_management_pkg.add_new_location('Reception', '303 Pine St, City');
asset_management_pkg.add_new_location('Conference Room', '404 Elm St, City');
asset_management_pkg.add_new_location('Staff Room', '505 Maple St, City');
END;
/
----Updating the users
BEGIN
-- Updating the user 'Piyush Dongre1'
asset_management_pkg.update_user(p_name => 'Piyush Dongre1 Updated', p_email => 'piyush1.updated@redeye.com', p_phone => 7377377327);
-- Updating the user 'Sneha1'
asset_management_pkg.update_user(p_name => 'Sneha1 Updated', p_email => 'sneha1.updated@redeye.com', p_phone => 7377377328);
-- Updating the user 'Deepak1'
asset_management_pkg.update_user(p_name => 'Deepak1 Updated', p_email => 'deepak1.updated@redeye.com', p_phone => 7377377329);
-- Updating the user 'Bhavya1'
asset_management_pkg.update_user(p_name => 'Bhavya1 Updated', p_email => 'bhavya1.updated@redeye.com', p_phone => 7377377320);
END;
/

-- Schedule shifts
BEGIN
    shift_management_pkg.create_shifts(SYSDATE);
END;


-- Run the view to get all shuttles that need maintenance

SELECT * FROM shuttles_due_for_maintenance;

-- Call the procedure to schedule maintenance for shuttles with license plates 'ABC123' and maintenance date '01-JAN-22'

BEGIN
    asset_management_pkg.schedule_vehicle_maintenance('DEF789', TO_DATE('05-DEC-2024', 'DD-MON-YY'));
END;

ROLLBACK;

-- CHECK maintenance schedule

SELECT * FROM UPCOMING_MAINTENANCE_SCHEDULE;
