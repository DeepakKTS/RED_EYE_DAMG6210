create or replace PACKAGE BODY service_management_pkg IS

   -- Shifts table operations
   PROCEDURE manage_shift (
      p_shift_id   IN VARCHAR2,
      p_shuttle_id IN VARCHAR2 DEFAULT NULL,
      p_driver_id  IN VARCHAR2 DEFAULT NULL,
      p_start_time  IN TIMESTAMP DEFAULT NULL,
      p_end_time    IN TIMESTAMP DEFAULT NULL,
      p_action     IN VARCHAR2
   ) IS
      v_count NUMBER;
   BEGIN
      SELECT COUNT(*)
      INTO v_count
      FROM shifts
      WHERE shift_id = p_shift_id;

      IF p_action = 'INSERT' THEN
         IF v_count = 0 THEN
            INSERT INTO shifts (shift_id, shuttle_id, driver_id, start_time, end_time)
            VALUES (p_shift_id, p_shuttle_id, p_driver_id, p_start_time, p_end_time);
            DBMS_OUTPUT.PUT_LINE('? Successfully inserted shift with ID: ' || p_shift_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? Shift with ID: ' || p_shift_id || ' already exists.');
         END IF;
      ELSIF p_action = 'UPDATE' THEN
         IF v_count > 0 THEN
            UPDATE shifts
            SET shuttle_id = p_shuttle_id,
                driver_id = p_driver_id,
                start_time = p_start_time,
                end_time = p_end_time
            WHERE shift_id = p_shift_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully updated shift with ID: ' || p_shift_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No shift found with ID: ' || p_shift_id);
         END IF;
      ELSIF p_action = 'DELETE' THEN
         IF v_count > 0 THEN
            DELETE FROM shifts WHERE shift_id = p_shift_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully deleted shift with ID: ' || p_shift_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No shift found with ID: ' || p_shift_id);
         END IF;
      ELSE
         DBMS_OUTPUT.PUT_LINE('? Invalid action specified.');
      END IF;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
         RAISE_APPLICATION_ERROR(-20001, '? Failed to manage shift with ID: ' || p_shift_id);
   END manage_shift;

   -- Maintenance Schedules table operations
   PROCEDURE manage_maintenance_schedule (
      p_maintenance_id IN VARCHAR2,
      p_shuttle_id     IN VARCHAR2 DEFAULT NULL,
      p_maintenance_date IN DATE DEFAULT NULL,
      p_description    IN VARCHAR2 DEFAULT NULL,
      p_action         IN VARCHAR2
   ) IS
      v_count NUMBER;
   BEGIN
      SELECT COUNT(*)
      INTO v_count
      FROM maintenance_schedules
      WHERE maintenance_id = p_maintenance_id;

      IF p_action = 'INSERT' THEN
         IF v_count = 0 THEN
            INSERT INTO maintenance_schedules (maintenance_id, shuttle_id, maintenance_date, description)
            VALUES (p_maintenance_id, p_shuttle_id, p_maintenance_date, p_description);
            DBMS_OUTPUT.PUT_LINE('? Successfully inserted maintenance schedule with ID: ' || p_maintenance_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? Maintenance schedule with ID: ' || p_maintenance_id || ' already exists.');
         END IF;
      ELSIF p_action = 'UPDATE' THEN
         IF v_count > 0 THEN
            UPDATE maintenance_schedules
            SET shuttle_id = p_shuttle_id,
                maintenance_date = p_maintenance_date,
                description = p_description
            WHERE maintenance_id = p_maintenance_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully updated maintenance schedule with ID: ' || p_maintenance_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No maintenance schedule found with ID: ' || p_maintenance_id);
         END IF;
      ELSIF p_action = 'DELETE' THEN
         IF v_count > 0 THEN
            DELETE FROM maintenance_schedules WHERE maintenance_id = p_maintenance_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully deleted maintenance schedule with ID: ' || p_maintenance_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No maintenance schedule found with ID: ' || p_maintenance_id);
         END IF;
      ELSE
         DBMS_OUTPUT.PUT_LINE('? Invalid action specified.');
      END IF;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
         RAISE_APPLICATION_ERROR(-20002, '? Failed to manage maintenance schedule with ID: ' || p_maintenance_id);
   END manage_maintenance_schedule;

   -- Third Party Services table operations
  
PROCEDURE manage_third_party_service (
   p_tp_id       IN VARCHAR2,
   p_name        IN VARCHAR2 DEFAULT NULL,
   p_contactInfo IN VARCHAR2 DEFAULT NULL,
   p_action      IN VARCHAR2
) IS
   v_count NUMBER;
BEGIN
   -- Check if the third party service exists
   SELECT COUNT(*)
   INTO v_count
   FROM third_party_services
   WHERE tp_id = p_tp_id;

   IF p_action = 'INSERT' THEN
      IF v_count = 0 THEN
         INSERT INTO third_party_services (tp_id, name, contactInfo)
         VALUES (p_tp_id, p_name, p_contactInfo);
         DBMS_OUTPUT.PUT_LINE('? Successfully inserted third party service with ID: ' || p_tp_id);
      ELSE
         DBMS_OUTPUT.PUT_LINE('?? Third party service with ID: ' || p_tp_id || ' already exists.');
      END IF;
   ELSIF p_action = 'UPDATE' THEN
      IF v_count > 0 THEN
         UPDATE third_party_services
         SET name = p_name,
             contactInfo = p_contactInfo
         WHERE tp_id = p_tp_id;
         DBMS_OUTPUT.PUT_LINE('? Successfully updated third party service with ID: ' || p_tp_id);
      ELSE
         DBMS_OUTPUT.PUT_LINE('?? No third party service found with ID: ' || p_tp_id);
      END IF;
   ELSIF p_action = 'DELETE' THEN
      IF v_count > 0 THEN
         DELETE FROM third_party_services WHERE tp_id = p_tp_id;
         DBMS_OUTPUT.PUT_LINE('? Successfully deleted third party service with ID: ' || p_tp_id);
      ELSE
         DBMS_OUTPUT.PUT_LINE('?? No third party service found with ID: ' || p_tp_id);
      END IF;
   ELSE
      DBMS_OUTPUT.PUT_LINE('? Invalid action specified.');
   END IF;
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
      DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
      RAISE_APPLICATION_ERROR(-20005, '? Failed to manage third party service with ID: ' || p_tp_id);
END manage_third_party_service;
END service_management_pkg;
