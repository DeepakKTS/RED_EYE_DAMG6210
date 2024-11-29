---PROCEDURES---
/*Procedure 1:Vehicle Maintenance Scheduling
This procedure automates the scheduling of vehicle maintenance based on mileage, usage, or a predefined maintenance threshold. The procedure:

Checks shuttles with mileage exceeding a set threshold or scheduled maintenance overdue.
Schedules maintenance for such shuttles by creating entries in the maintenance_schedules table.
Notifies about unscheduled or overdue maintenance.*/

CREATE OR REPLACE PROCEDURE schedule_vehicle_maintenance IS
    v_shuttle_id shuttles.shuttle_id%TYPE;
    v_model shuttles.model%TYPE;
    v_licensePlate shuttles.licensePlate%TYPE;
    v_mileage shuttles.mileage%TYPE;
    v_next_maintenance_date DATE;
    CURSOR overdue_shuttles IS
        SELECT shuttle_id, model, licensePlate, mileage
        FROM shuttles
        WHERE mileage >= 100000
           OR shuttle_id NOT IN (
               SELECT shuttle_id 
               FROM maintenance_schedules 
               WHERE maintenanceDate >= SYSDATE
           ); -- No upcoming maintenance scheduled
BEGIN
    OPEN overdue_shuttles;

    LOOP
        FETCH overdue_shuttles INTO v_shuttle_id, v_model, v_licensePlate, v_mileage;
        EXIT WHEN overdue_shuttles%NOTFOUND;

        -- Schedule maintenance
        v_next_maintenance_date := SYSDATE + INTERVAL '7' DAY; -- Schedule one week from today

        -- Use a sequence to ensure unique maintenance IDs
        INSERT INTO maintenance_schedules (maintenance_id, shuttle_id, maintenanceDate, description)
        VALUES (
            'MNT_' || v_shuttle_id || '_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') || '_' || TO_CHAR(DBMS_RANDOM.VALUE(1000, 9999), 'FM0000'),
            v_shuttle_id,
            v_next_maintenance_date,
            'Routine maintenance scheduled automatically'
        );

        DBMS_OUTPUT.PUT_LINE('Maintenance scheduled for Shuttle: ' || v_shuttle_id || ', License Plate: ' || v_licensePlate || ', Model: ' || v_model);
    END LOOP;

    CLOSE overdue_shuttles;
END;
/
