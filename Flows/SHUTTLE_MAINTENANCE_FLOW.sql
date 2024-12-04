-- Run the view to get all shuttles that need maintenance

SELECT * FROM shuttles_due_for_maintenance;

-- Call the procedure to schedule maintenance for shuttles with license plates 'ABC123' and maintenance date '01-JAN-22'

BEGIN
    asset_management_pkg.schedule_vehicle_maintenance('DEF789', TO_DATE('05-DEC-2024', 'DD-MON-YY'));
END;

ROLLBACK;

-- CHECK maintenance schedule

SELECT * FROM UPCOMING_MAINTENANCE_SCHEDULE;
