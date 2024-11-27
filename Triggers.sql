//TRIGGERS
/*Trigger 1: Enforce Booking Time Limits
This trigger ensures that users cannot book a shuttle ride more than 30 days in advance.*/
CREATE OR REPLACE TRIGGER enforce_booking_time_limit
BEFORE INSERT OR UPDATE ON rides
FOR EACH ROW
DECLARE
    trip_start_date DATE;
BEGIN
    -- Retrieve the trip's start date
    BEGIN
        SELECT t.startTime INTO trip_start_date
        FROM trips t
        WHERE t.trip_id = :NEW.trip_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'Invalid trip_id: No matching trip found.');
    END;

    -- Check booking time limit
    IF TRUNC(trip_start_date) > TRUNC(SYSDATE) + 30 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Booking cannot be made more than 30 days in advance.');
    END IF;
END;
/
/*Trigger 2: Enforce Cancellation Policy
This trigger ensures that cancellations are not allowed within 2 hours of the ride's start time.
*/
CREATE OR REPLACE TRIGGER enforce_cancellation_policy
BEFORE UPDATE OF status ON rides
FOR EACH ROW
DECLARE
    ride_start_time TIMESTAMP;
    time_difference NUMBER;
BEGIN
    -- Retrieve the trip's start time
    SELECT t.startTime INTO ride_start_time
    FROM trips t
    WHERE t.trip_id = :OLD.trip_id;

    -- Calculate the time difference in hours
    time_difference := (CAST(ride_start_time AS DATE) - CAST(SYSTIMESTAMP AS DATE)) * 24;

    -- Check cancellation time limit
    IF :NEW.status = 'Cancelled' AND time_difference < 2 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cancellations must be made at least 2 hours before the ride.');
    END IF;
END;
/
/* Trigger 3: Vehicle Mileage Constraints
This trigger ensures that shuttles with mileage exceeding the predefined threshold 
cannot be assigned to shifts, enforcing regular vehicle maintenance and operational safety.*/

CREATE OR REPLACE TRIGGER enforce_vehicle_mileage_constraint
BEFORE INSERT OR UPDATE ON shifts
FOR EACH ROW
DECLARE
    mileage_threshold NUMBER := 100000; -- Example mileage threshold
    current_mileage NUMBER;
BEGIN
    -- Fetch the current mileage of the shuttle
    SELECT mileage INTO current_mileage
    FROM shuttles
    WHERE shuttle_id = :NEW.shuttle_id;

    -- Check if the mileage exceeds the threshold
    IF current_mileage > mileage_threshold THEN
        RAISE_APPLICATION_ERROR(-20004, 'Shuttle cannot be assigned as mileage exceeds the threshold.');
    END IF;
END;
/