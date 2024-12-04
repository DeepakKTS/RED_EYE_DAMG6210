CREATE OR REPLACE PACKAGE BODY ride_management_pkg IS

   -- Constants for status
   C_STATUS_AVAILABLE CONSTANT VARCHAR2(20) := 'AVAILABLE';
   C_STATUS_IN_PROGRESS CONSTANT VARCHAR2(20) := 'IN PROGRESS';
   C_STATUS_COMPLETED CONSTANT VARCHAR2(20) := 'COMPLETED';
   C_STATUS_BOOKED CONSTANT VARCHAR2(20) := 'BOOKED';
   C_STATUS_CANCELLED CONSTANT VARCHAR2(20) := 'CANCELLED';

   -- Function to check if user exists
   FUNCTION does_user_exist(p_email IN users.email%TYPE) RETURN BOOLEAN IS
      v_user_id VARCHAR2(50);
   BEGIN
      BEGIN
         SELECT user_id
         INTO v_user_id
         FROM users
         WHERE email = p_email;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_user_id := NULL;
      END;

      IF v_user_id IS NULL THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
   END does_user_exist;

   FUNCTION does_location_exist(p_location_name IN locations.name%TYPE) RETURN BOOLEAN IS
      v_location_id VARCHAR2(50);
   BEGIN
      BEGIN
         SELECT location_id
         INTO v_location_id
         FROM locations
         WHERE name = p_location_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_location_id := NULL;
      END;

      IF v_location_id IS NULL THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
   END does_location_exist;

   PROCEDURE update_trip_status IS
   BEGIN
      -- Update trips to completed
      UPDATE trips 
      SET status = C_STATUS_COMPLETED
      WHERE status = C_STATUS_IN_PROGRESS
      AND end_time < SYSDATE;

      -- Update rides to completed
      UPDATE rides 
      SET status = C_STATUS_COMPLETED
      WHERE trip_id IN (
         SELECT trip_id 
         FROM trips 
         WHERE status = C_STATUS_COMPLETED
      )
      AND status = C_STATUS_IN_PROGRESS;

      DBMS_OUTPUT.PUT_LINE('Updated trip and ride statuses');
      COMMIT;

      EXCEPTION
         WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
   RETURN;
   END update_trip_status;

   PROCEDURE create_new_trip (
      p_shuttle_id IN VARCHAR2
   ) IS
      v_trip_id VARCHAR2(50);
   BEGIN
      v_trip_id := 'TRIP_' || p_shuttle_id || '_' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISS');
      
      INSERT INTO trips (trip_id, start_time, end_time, status, shuttle_id)
      VALUES (v_trip_id, SYSTIMESTAMP, NULL, C_STATUS_AVAILABLE, p_shuttle_id);

      DBMS_OUTPUT.PUT_LINE('Created new trip : ' || v_trip_id);
      COMMIT;

      EXCEPTION
         WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
   END create_new_trip;

   PROCEDURE start_trip (
      p_trip_id IN VARCHAR2,
      p_shuttle_id IN VARCHAR2
   ) IS
      v_rider_count NUMBER;
      v_start_time TIMESTAMP;
      v_end_time TIMESTAMP;
      v_record_id VARCHAR2(50);
   BEGIN
      
      SELECT COUNT(ride_id) INTO v_rider_count FROM rides WHERE trip_id = p_trip_id AND status = C_STATUS_BOOKED;
      SELECT start_time INTO v_start_time FROM trips where trip_id = p_trip_id;
      
      v_end_time := v_start_time + INTERVAL '2' MINUTE * v_rider_count;
      
      UPDATE trips SET status = C_STATUS_IN_PROGRESS, end_time = SYSTIMESTAMP + INTERVAL '2' MINUTE * v_rider_count WHERE trip_id = p_trip_id;
      UPDATE rides 
      SET status = C_STATUS_IN_PROGRESS 
      WHERE trip_id IN (
         SELECT trip_id 
         FROM trips 
         WHERE status = C_STATUS_IN_PROGRESS 
      )
      AND status = C_STATUS_BOOKED;

      v_record_id := 'smr_' || p_shuttle_id || '_' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISS');
      INSERT INTO shuttle_mileage_records (record_id, shuttle_id, trip_id, mileage_added, updated_at)
      VALUES (v_record_id, p_shuttle_id, p_trip_id, 20 * v_rider_count, SYSTIMESTAMP);

      DBMS_OUTPUT.PUT_LINE('Started trip : ' || p_trip_id || ' that ends at : '|| v_end_time);
      DBMS_OUTPUT.PUT_LINE('Added ' || 20 * v_rider_count ||  ' miles to : '|| p_shuttle_id);

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         RAISE;

   END start_trip;
   
   PROCEDURE book_ride (
      p_email                 IN VARCHAR2,
      p_dropoff_location_name IN VARCHAR2
   ) IS
      v_user_id VARCHAR2(50);
      v_dropoff_location_id VARCHAR2(50);
      v_trip_id VARCHAR2(50);
      v_shuttle_id VARCHAR2(50);
      v_rider_count NUMBER;
      v_trip_start_time TIMESTAMP;
      v_current_hour NUMBER;
      v_ride_id VARCHAR2(50);
      v_current_ride_id NUMBER;
   BEGIN
      -- Check if user exists
      IF NOT does_user_exist(p_email) THEN
         RAISE_APPLICATION_ERROR(-20001, 'User with email ' || p_email || ' does not exist.');
      END IF;

      -- Get user ID
      SELECT user_id INTO v_user_id FROM users WHERE email = p_email;

      -- Check if dropoff location exists
      IF NOT does_location_exist(p_dropoff_location_name) THEN
         RAISE_APPLICATION_ERROR(-20002, 'Location ' || p_dropoff_location_name || ' does not exist.');
      END IF;

      -- Get location ID
      SELECT location_id INTO v_dropoff_location_id FROM locations WHERE name = p_dropoff_location_name;

      -- Get current hour in EST
      SELECT TO_NUMBER(TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'US/Eastern', 'HH24'))   
      INTO v_current_hour
      FROM DUAL;

      -- Update trip status
      update_trip_status();

      -- Check if booking is allowed at current time
      IF v_current_hour NOT BETWEEN 6 AND 18 THEN
         RAISE_APPLICATION_ERROR(-20002, 'Booking is only allowed between 6 AM and 6 PM.');
      END IF;

      -- Check if user already has an active ride
      SELECT COUNT(*)
      INTO v_current_ride_id
      FROM rides
      WHERE user_id = v_user_id
      AND status IN (C_STATUS_BOOKED, C_STATUS_IN_PROGRESS);

      IF v_current_ride_id > 0 THEN
         RAISE_APPLICATION_ERROR(-20003, 'User ' || v_user_id || ' already has an active ride.');
      END IF;

      -- Find available trip
      BEGIN 
         SELECT t.trip_id, t.shuttle_id, COUNT(r.ride_id) AS rider_count, t.start_time
         INTO v_trip_id, v_shuttle_id, v_rider_count, v_trip_start_time
         FROM trips t
         LEFT JOIN rides r ON t.trip_id = r.trip_id AND r.status = C_STATUS_BOOKED
         WHERE t.status = C_STATUS_AVAILABLE
         GROUP BY t.trip_id, t.shuttle_id, t.start_time
         HAVING COUNT(r.ride_id) < 2
         ORDER BY t.start_time
         FETCH FIRST 1 ROW ONLY;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
               v_trip_id := NULL;
      END;

      -- If no trip available, create a new one
      IF v_trip_id IS NULL THEN
         -- Find available shuttle
         BEGIN
               SELECT shuttle_id
               INTO v_shuttle_id
               FROM shuttles s
               WHERE EXISTS (
                  SELECT 1
                  FROM shifts sh
                  WHERE sh.shuttle_id = s.shuttle_id
                  AND trunc(sh.start_time) = trunc(SYSTIMESTAMP)
               )
               AND NOT EXISTS (
                  SELECT 1
                  FROM trips t
                  WHERE t.shuttle_id = s.shuttle_id
                  AND t.status IN (C_STATUS_AVAILABLE, C_STATUS_IN_PROGRESS)
               )
               AND ROWNUM = 1;
         EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RAISE_APPLICATION_ERROR(-20004, 'No shuttles available. Unable to start a new trip.');
         END;

         -- Check if trip has been available for more than 3 minutes
         IF SYSTIMESTAMP - v_trip_start_time > INTERVAL '3' MINUTE THEN
            start_trip(v_trip_id, v_shuttle_id);
            DBMS_OUTPUT.PUT_LINE('Trip ' || v_trip_id || ' has been started. Creating new trip.');
         END IF;

         -- Create new trip
         create_new_trip(v_shuttle_id);
         SELECT trip_id, start_time 
         INTO v_trip_id, v_trip_start_time 
         FROM trips 
         WHERE shuttle_id = v_shuttle_id AND status = C_STATUS_AVAILABLE;
         
         v_rider_count := 0;
      END IF;

      -- Book the ride
      v_ride_id := 'RIDE_' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF');
      INSERT INTO rides (ride_id, pickup_location_id, dropoff_location_id, trip_id, user_id, status)
      VALUES (v_ride_id, 'L1', v_dropoff_location_id, v_trip_id, v_user_id, C_STATUS_BOOKED);

      -- Start trip if it now has 2 riders
      IF v_rider_count + 1 = 2 THEN
         start_trip(v_trip_id, v_shuttle_id);
      END IF;

      COMMIT;
      DBMS_OUTPUT.PUT_LINE('Ride booked successfully. Ride ID: ' || v_ride_id);
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         RAISE;
   END book_ride;
      

   PROCEDURE cancel_ride (
      p_email IN VARCHAR2
   ) IS
      v_user_id VARCHAR2(50);
      v_rider_count NUMBER;
      v_booked_rides NUMBER;
      v_in_progress_rides NUMBER;
   BEGIN

      IF NOT does_user_exist(p_email) THEN
         RAISE_APPLICATION_ERROR(-20001, 'User with email ' || p_email || ' does not exist.');
         RETURN;
      ELSE
         SELECT user_id INTO v_user_id FROM users WHERE email = p_email;
      END IF;

      BEGIN
         SELECT count(ride_id)
         INTO v_booked_rides
         from RIDES
         WHERE user_id = v_user_id AND status = C_STATUS_BOOKED;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_booked_rides := 0;
            RAISE_APPLICATION_ERROR(-20002, 'No booked rides found for user ' || v_user_id);
            RETURN;
      END;

      BEGIN
         SELECT count(ride_id)
         INTO v_in_progress_rides
         from RIDES
         WHERE user_id = v_user_id AND status = C_STATUS_IN_PROGRESS;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_in_progress_rides := 0;
      END;

      IF v_in_progress_rides > 0 THEN
         RAISE_APPLICATION_ERROR(-20003, 'Cannot cancel ride. Ride is already in progress.');
         RETURN;
      END IF;

      UPDATE rides SET status = C_STATUS_CANCELLED  WHERE user_id = v_user_id AND status = C_STATUS_BOOKED;
      DBMS_OUTPUT.PUT_LINE('Successfully cancelled booking for user ' || v_user_id);
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         RAISE;
   END cancel_ride;
   
END ride_management_pkg;
/
