CREATE OR REPLACE PACKAGE BODY ride_management_pkg IS

   -- Constants for status
   C_STATUS_AVAILABLE CONSTANT VARCHAR2(20) := 'AVAILABLE';
   C_STATUS_IN_PROGRESS CONSTANT VARCHAR2(20) := 'IN PROGRESS';
   C_STATUS_COMPLETED CONSTANT VARCHAR2(20) := 'COMPLETED';
   C_STATUS_BOOKED CONSTANT VARCHAR2(20) := 'BOOKED';
   C_STATUS_CANCELLED CONSTANT VARCHAR2(20) := 'CANCELLED';


   PROCEDURE update_trip_status IS
   BEGIN
      -- Update trips to completed
      UPDATE trips 
      SET status = C_STATUS_COMPLETED
      WHERE status = C_STATUS_IN_PROGRESS
      AND endTime < SYSTIMESTAMP;

      -- Update rides to completed
      UPDATE rides 
      SET status = C_STATUS_COMPLETED
      WHERE trip_id IN (
         SELECT trip_id 
         FROM trips 
         WHERE status = C_STATUS_COMPLETED
      )
      AND status = C_STATUS_IN_PROGRESS;

      
   RETURN;
   END update_trip_status;

   PROCEDURE create_new_trip (
      p_shuttle_id IN VARCHAR2
   ) IS
      v_trip_id VARCHAR2(50);
   BEGIN
      v_trip_id := 'TRIP_' || p_shuttle_id || '_' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISS');
      
      -- Debugging output
      DBMS_OUTPUT.PUT_LINE('v_trip_id: ' || v_trip_id);
      DBMS_OUTPUT.PUT_LINE('p_shuttle_id: ' || p_shuttle_id);
      
      INSERT INTO trips (trip_id, startTime, endTime, status, shuttle_id)
      VALUES (v_trip_id, SYSTIMESTAMP, NULL, C_STATUS_AVAILABLE, p_shuttle_id);
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
      SELECT starttime INTO v_start_time FROM trips where trip_id = p_trip_id;
      
      v_end_time := v_start_time + INTERVAL '2' MINUTE * v_rider_count;
      
      UPDATE trips SET status = C_STATUS_IN_PROGRESS, endTime = SYSTIMESTAMP + INTERVAL '2' MINUTE * v_rider_count WHERE trip_id = p_trip_id;
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

   END start_trip;

   PROCEDURE book_ride (
      p_dropoffLocationId IN VARCHAR2,
      p_user_id           IN VARCHAR2
   ) IS
      v_trip_id VARCHAR2(50);
      v_shuttle_id VARCHAR2(50);
      v_rider_count NUMBER;
      v_trip_start_time TIMESTAMP;
      v_current_hour NUMBER;
      v_ride_id VARCHAR2(50);
      v_current_ride_id NUMBER;
   BEGIN

      SELECT TO_CHAR(systimestamp at time zone 'US/Eastern', 'HH24')   
      INTO v_current_hour
      from DUAL;

      update_trip_status();

      -- Check if the current time is within the allowed booking hours
      IF v_current_hour BETWEEN 17 AND 23 OR v_current_hour BETWEEN 0 AND 5 THEN

         -- If the user has an active ride, stop
         SELECT COUNT(*)
         INTO v_current_ride_id
         FROM rides
         WHERE user_id = p_user_id
         AND status IN (C_STATUS_BOOKED, C_STATUS_IN_PROGRESS);

         IF v_current_ride_id > 0 THEN
         DBMS_OUTPUT.PUT_LINE('User ' || p_user_id || ' already has an active ride.');
         RETURN;
         END IF;

         -- Check for available trips
         BEGIN 
            SELECT t.trip_id, shuttle_id, COUNT(ride_id) AS rider_count, startTime
            INTO v_trip_id, v_shuttle_id, v_rider_count, v_trip_start_time
            FROM trips t
            LEFT JOIN rides r ON t.trip_id = r.trip_id
            WHERE t.status =C_STATUS_AVAILABLE and r.status = C_STATUS_BOOKED
            GROUP BY t.trip_id, shuttle_id, startTime
            HAVING COUNT(ride_id) < 2
            ORDER BY startTime
            FETCH FIRST 1 ROWS ONLY;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_trip_id := NULL;
         END;

         -- If no trip is available, create a new trip
         IF v_trip_id IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('There are no active trips available. Creating a new trip');
            -- Find an available shuttle
            BEGIN
               SELECT shuttle_id
               INTO v_shuttle_id
               FROM shuttles s
               WHERE NOT EXISTS (
                  SELECT 1
                  FROM trips t
                  WHERE t.shuttle_id = s.shuttle_id
                  AND t.status IN (C_STATUS_AVAILABLE, C_STATUS_IN_PROGRESS)
               )
               AND ROWNUM = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_shuttle_id := NULL;
            END;
            -- If no shuttle is available, raise an exception
            IF v_shuttle_id IS NULL THEN
               DBMS_OUTPUT.PUT_LINE('There are no shuttles available and a trip could not be started');
               RETURN;
            END IF;

            DBMS_OUTPUT.PUT_LINE('Shuttle ' || v_shuttle_id || ' is available');
            -- CREATE NEW TRIP AND GET THE TRIP ID
            create_new_trip(v_shuttle_id);
            SELECT trip_id INTO v_trip_id FROM trips WHERE shuttle_id = v_shuttle_id AND status = C_STATUS_AVAILABLE;
            DBMS_OUTPUT.PUT_LINE('New trip started with trip_id ' || v_trip_id);
         END IF;

         DBMS_OUTPUT.PUT_LINE('Found trip available with trip_id ' || v_trip_id);
         

         -- If the trip has been available for more than 3 minutes, mark it as started
         IF SYSDATE - v_trip_start_time > INTERVAL '3' MINUTE THEN
            start_trip(v_trip_id, v_shuttle_id);
            DBMS_OUTPUT.PUT_LINE('Trip has already started. Please try again');
            RETURN;
         END IF;


         -- Generate a new ride_id
         v_ride_id := 'RIDE_' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISS');
         -- Book the ride
         INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, user_id, status)
         VALUES (v_ride_id, 'L1', p_dropoffLocationId, v_trip_id, p_user_id, C_STATUS_BOOKED);
         DBMS_OUTPUT.PUT_LINE('Booked a ride for user: '|| p_user_id || ' ride_id: ' || v_ride_id);

         -- IF the trip has 2 riders start the trip
         IF v_rider_count + 1 = 2 THEN
            start_trip(v_trip_id, v_shuttle_id);
         END IF;

      ELSE
         DBMS_OUTPUT.PUT_LINE('Booking is not allowed before 5 PM and after 5 AM.');
      END IF;
   END book_ride;

   

   PROCEDURE cancel_ride (
      p_user_id IN VARCHAR2
   ) IS
      v_rider_count NUMBER;
      v_booked_rides NUMBER;
      v_in_progress_rides NUMBER;
   BEGIN

      BEGIN
         SELECT count(ride_id)
         INTO v_booked_rides
         from RIDES
         WHERE user_id = p_user_id AND status = C_STATUS_BOOKED;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_booked_rides := 0;
            DBMS_OUTPUT.PUT_LINE('Rider does not have any available rides');
            RETURN;
      END;

      BEGIN
         SELECT count(ride_id)
         INTO v_in_progress_rides
         from RIDES
         WHERE user_id = p_user_id AND status = C_STATUS_IN_PROGRESS;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_in_progress_rides := 0;
      END;

      IF v_in_progress_rides > 0 THEN
         DBMS_OUTPUT.PUT_LINE('Cannot cancel a ride that is in progress');
         RETURN;
      END IF;

      UPDATE rides SET status = C_STATUS_CANCELLED  WHERE user_id = p_user_id AND status = C_STATUS_BOOKED;
      DBMS_OUTPUT.PUT_LINE('Successfully cancelled booking for user ' || p_user_id);
   END cancel_ride;

   FUNCTION check_shuttle_availability (
      p_date IN DATE
   ) RETURN BOOLEAN IS
      v_count NUMBER;
   BEGIN
      SELECT COUNT(*) INTO v_count FROM shuttles WHERE shuttle_id NOT IN (SELECT shuttle_id FROM trips WHERE TRUNC(startTime) = TRUNC(p_date));
      RETURN v_count > 0;
   END check_shuttle_availability;
END ride_management_pkg;
/
