create or replace PACKAGE BODY transport_management_pkg IS

   -- Trips table operations
   PROCEDURE manage_trip (
      p_trip_id   IN VARCHAR2,
      p_startTime IN TIMESTAMP DEFAULT NULL,
      p_endTime   IN TIMESTAMP DEFAULT NULL,
      p_status    IN VARCHAR2 DEFAULT NULL,
      p_shuttle_id IN VARCHAR2 DEFAULT NULL,
      p_action    IN VARCHAR2
   ) IS
      v_count NUMBER;
   BEGIN
      SELECT COUNT(*)
      INTO v_count
      FROM trips
      WHERE trip_id = p_trip_id;

      IF p_action = 'INSERT' THEN
         IF v_count = 0 THEN
            INSERT INTO trips (trip_id, startTime, endTime, status, shuttle_id)
            VALUES (p_trip_id, p_startTime, p_endTime, p_status, p_shuttle_id);
            DBMS_OUTPUT.PUT_LINE('? Successfully inserted trip with ID: ' || p_trip_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? Trip with ID: ' || p_trip_id || ' already exists.');
         END IF;
      ELSIF p_action = 'UPDATE' THEN
         IF v_count > 0 THEN
            UPDATE trips
            SET startTime = p_startTime,
                endTime = p_endTime,
                status = p_status,
                shuttle_id = p_shuttle_id
            WHERE trip_id = p_trip_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully updated trip with ID: ' || p_trip_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No trip found with ID: ' || p_trip_id);
         END IF;
      ELSIF p_action = 'DELETE' THEN
         IF v_count > 0 THEN
            DELETE FROM trips WHERE trip_id = p_trip_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully deleted trip with ID: ' || p_trip_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No trip found with ID: ' || p_trip_id);
         END IF;
      ELSE
         DBMS_OUTPUT.PUT_LINE('? Invalid action specified.');
      END IF;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
         RAISE_APPLICATION_ERROR(-20001, '? Failed to manage trip with ID: ' || p_trip_id);
   END manage_trip;

   -- Rides table operations
   PROCEDURE manage_ride (
      p_ride_id           IN VARCHAR2,
      p_pickupLocationId  IN VARCHAR2 DEFAULT NULL,
      p_dropoffLocationId IN VARCHAR2 DEFAULT NULL,
      p_trip_id           IN VARCHAR2 DEFAULT NULL,
      p_user_id           IN VARCHAR2 DEFAULT NULL,
      p_status            IN VARCHAR2 DEFAULT NULL,
      p_action            IN VARCHAR2
   ) IS
      v_count NUMBER;
   BEGIN
      SELECT COUNT(*)
      INTO v_count
      FROM rides
      WHERE ride_id = p_ride_id;

      IF p_action = 'INSERT' THEN
         IF v_count = 0 THEN
            INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, user_id, status)
            VALUES (p_ride_id, p_pickupLocationId, p_dropoffLocationId, p_trip_id, p_user_id, p_status);
            DBMS_OUTPUT.PUT_LINE('? Successfully inserted ride with ID: ' || p_ride_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? Ride with ID: ' || p_ride_id || ' already exists.');
         END IF;
      ELSIF p_action = 'UPDATE' THEN
         IF v_count > 0 THEN
            UPDATE rides
            SET pickupLocationId = p_pickupLocationId,
                dropoffLocationId = p_dropoffLocationId,
                trip_id = p_trip_id,
                user_id = p_user_id,
                status = p_status
            WHERE ride_id = p_ride_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully updated ride with ID: ' || p_ride_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No ride found with ID: ' || p_ride_id);
         END IF;
      ELSIF p_action = 'DELETE' THEN
         IF v_count > 0 THEN
            DELETE FROM rides WHERE ride_id = p_ride_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully deleted ride with ID: ' || p_ride_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No ride found with ID: ' || p_ride_id);
         END IF;
      ELSE
         DBMS_OUTPUT.PUT_LINE('? Invalid action specified.');
      END IF;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
         RAISE_APPLICATION_ERROR(-20002, '? Failed to manage ride with ID: ' || p_ride_id);
   END manage_ride;

   -- Drivers table operations
  PROCEDURE manage_driver (
   p_driver_id     IN VARCHAR2,
   p_user_role_id  IN VARCHAR2 DEFAULT NULL,
   p_licenseNumber IN VARCHAR2 DEFAULT NULL,
   p_tp_id         IN VARCHAR2 DEFAULT NULL,
   p_action        IN VARCHAR2
) IS
   v_count NUMBER;
BEGIN
   -- Check if the driver exists
   SELECT COUNT(*)
   INTO v_count
   FROM drivers
   WHERE driver_id = p_driver_id;

   IF p_action = 'INSERT' THEN
      IF v_count = 0 THEN
         INSERT INTO drivers (driver_id, user_role_id, licenseNumber, tp_id)
         VALUES (p_driver_id, p_user_role_id, p_licenseNumber, p_tp_id);
         DBMS_OUTPUT.PUT_LINE('? Successfully inserted driver with ID: ' || p_driver_id);
      ELSE
         DBMS_OUTPUT.PUT_LINE('?? Driver with ID: ' || p_driver_id || ' already exists.');
      END IF;
   ELSIF p_action = 'UPDATE' THEN
      IF v_count > 0 THEN
         UPDATE drivers
         SET user_role_id  = p_user_role_id,
             licenseNumber = p_licenseNumber,
             tp_id         = p_tp_id
         WHERE driver_id = p_driver_id;
         DBMS_OUTPUT.PUT_LINE('? Successfully updated driver with ID: ' || p_driver_id);
      ELSE
         DBMS_OUTPUT.PUT_LINE('?? No driver found with ID: ' || p_driver_id);
      END IF;
   ELSIF p_action = 'DELETE' THEN
      IF v_count > 0 THEN
         DELETE FROM drivers WHERE driver_id = p_driver_id;
         DBMS_OUTPUT.PUT_LINE('? Successfully deleted driver with ID: ' || p_driver_id);
      ELSE
         DBMS_OUTPUT.PUT_LINE('?? No driver found with ID: ' || p_driver_id);
      END IF;
   ELSE
      DBMS_OUTPUT.PUT_LINE('? Invalid action specified.');
   END IF;
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
      DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
      RAISE_APPLICATION_ERROR(-20003, '? Failed to manage driver with ID: ' || p_driver_id);
END manage_driver;
END transport_management_pkg;