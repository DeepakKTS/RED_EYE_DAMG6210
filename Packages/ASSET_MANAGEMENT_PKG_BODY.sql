create or replace PACKAGE BODY asset_management_pkg IS

   FUNCTION is_valid_email(p_email IN VARCHAR2) RETURN BOOLEAN IS
   BEGIN
      RETURN REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
   END is_valid_email;

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
            RETURN FALSE;
      END;

   RETURN TRUE;
   END does_user_exist;

   -- Add new users
   PROCEDURE add_new_user (
      p_name IN users.name%TYPE,
      p_email IN users.email%TYPE,
      p_phone IN users.phone%TYPE
   ) IS
   v_user_id VARCHAR2(50);
   v_role_id VARCHAR2(50);
   v_user_role_id VARCHAR2(50);
   BEGIN


      IF p_name IS NULL OR p_email IS NULL OR p_phone IS NULL THEN
         DBMS_OUTPUT.PUT_LINE('Name, Email, and Phone cannot be null.');
         RETURN;
      END IF;

      IF does_user_exist(p_email) THEN
         DBMS_OUTPUT.PUT_LINE('Email already in use.');
         RETURN;
      END IF;

      v_user_id := 'USER_' || p_email;
      v_role_id := 'R4';
      v_user_role_id := 'UR_' || v_user_id || '_' || v_role_id;

      INSERT INTO users (user_id, name, email, phone)
      VALUES (v_user_id, p_name, p_email, p_phone);

      INSERT INTO user_roles (user_role_id, user_id, role_id)
      VALUES (v_user_role_id, v_user_id, v_role_id);

      DBMS_OUTPUT.PUT_LINE('Successfully added new user with ID: ' || v_user_id);
      COMMIT;

   END;

   -- Add new drivers
   PROCEDURE add_new_driver (
      p_name IN users.name%TYPE,
      p_email IN users.email%TYPE,
      p_phone IN users.phone%TYPE,
      p_license_number IN drivers.license_number%TYPE,
      p_tp_id IN third_party_services.tp_id%TYPE
   ) IS
   v_driver_id VARCHAR2(50);
   v_role_id VARCHAR2(50);
   v_user_role_id VARCHAR2(50);
   v_tp_id VARCHAR2(50);
   BEGIN

      IF p_name IS NULL OR p_email IS NULL OR p_phone IS NULL OR p_license_number IS NULL OR p_tp_id IS NULL THEN
         DBMS_OUTPUT.PUT_LINE('Name, Email, Phone, License Number, and Third Party ID cannot be null.');
         RETURN;
      END IF;

      IF does_user_exist(p_email) THEN
         DBMS_OUTPUT.PUT_LINE('Email already in use.');
         RETURN;
      END IF;

      v_driver_id := 'DRIVER_' || p_email;
      v_role_id := 'R2';
      v_user_role_id := 'UR_' || v_driver_id || '_' || v_role_id;

      INSERT INTO users (user_id, name, email, phone)
      VALUES (v_driver_id, p_name, p_email, p_phone);

      INSERT INTO user_roles (user_role_id, user_id, role_id)
      VALUES (v_user_role_id, v_driver_id, v_role_id);

      INSERT INTO drivers (driver_id, user_role_id, license_number, tp_id)
      VALUES (v_driver_id, v_user_role_id, p_license_number, p_tp_id);


      DBMS_OUTPUT.PUT_LINE('Successfully added new driver with ID: ' || v_driver_id);
      COMMIT;

   END;

   -- Delete users
   PROCEDURE delete_user (
      p_email IN users.email%TYPE
   ) IS
   v_user_id VARCHAR2(50);
   BEGIN
      IF p_email IS NULL THEN
         DBMS_OUTPUT.PUT_LINE('User ID cannot be null.');
         RETURN;
      END IF;

      
      IF NOT does_user_exist(p_email) THEN
         DBMS_OUTPUT.PUT_LINE('User with eamil: ' || p_email || ' does not exist.');
         RETURN;
      END IF;      

      UPDATE users
      SET is_active = 0
      WHERE email = p_email;

      DBMS_OUTPUT.PUT_LINE('Successfully deleted user with email: ' || p_email);
      COMMIT;
   END;

   -- Update user details
   PROCEDURE update_user (
      p_name IN users.name%TYPE DEFAULT NULL,
      p_email IN users.email%TYPE DEFAULT NULL,
      p_phone IN users.phone%TYPE DEFAULT NULL
   ) IS
   v_user_id VARCHAR2(50);
   v_name users.name%TYPE;
   v_phone users.phone%TYPE;
   BEGIN
      IF p_email IS NULL THEN
         DBMS_OUTPUT.PUT_LINE('User ID cannot be null.');
         RETURN;
      END IF;

      IF NOT does_user_exist(p_email) THEN
         DBMS_OUTPUT.PUT_LINE('User with email: ' || p_email || ' does not exist.');
         RETURN;
      END IF;

      IF p_name IS NULL AND p_phone IS NULL THEN
         DBMS_OUTPUT.PUT_LINE('No changes specified.');
         RETURN;
      END IF;

      IF p_name IS NULL THEN
         SELECT name INTO v_name FROM users WHERE email = p_email;
      ELSE
         v_name := p_name;
      END IF;

      IF p_phone IS NULL THEN
         SELECT phone INTO v_phone FROM users WHERE email = p_email;
      ELSE
         v_phone := p_phone;
      END IF;

      UPDATE USERS
      SET name = v_name,
         phone = v_phone
      WHERE email = p_email;

      DBMS_OUTPUT.PUT_LINE('Successfully updated user with email: ' || p_email);
      COMMIT;
   END;

   -- Restore deleted user
   PROCEDURE restore_user (
      p_email IN users.email%TYPE
   ) IS
   v_user_id VARCHAR2(50);
   BEGIN
      IF p_email IS NULL THEN
         DBMS_OUTPUT.PUT_LINE('User email cannot be null.');
         RETURN;
      END IF;

      IF NOT does_user_exist(p_email) THEN
         DBMS_OUTPUT.PUT_LINE('User with email: ' || p_email || ' does not exist.');
         RETURN;
      END IF;

      UPDATE users
      SET is_active = 1
      WHERE email = p_email;

      DBMS_OUTPUT.PUT_LINE('Successfully restored user with email: ' || p_email);
      COMMIT;
   END;

   FUNCTION does_location_exist(p_name IN locations.name%TYPE) RETURN BOOLEAN IS
   v_location_id VARCHAR2(50);
   BEGIN
      BEGIN
         SELECT location_id
         INTO v_location_id
         FROM locations
         WHERE name = p_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
      END;
   
   RETURN TRUE;
   END does_location_exist;

   -- Add new location
   PROCEDURE add_new_location (
      p_name IN locations.name%TYPE,
      p_address IN locations.address%TYPE
   ) IS
   v_location_id VARCHAR2(50);
   BEGIN

      IF p_name IS NULL OR p_address IS NULL THEN
         DBMS_OUTPUT.PUT_LINE('Name and Address cannot be null.');
         RETURN;
      END IF;

      -- check if location already exists
      IF does_location_exist(p_name) THEN
         DBMS_OUTPUT.PUT_LINE('Location already exists.');
         RETURN;
      END IF;

      -- create an id by add _ between the words in the name and adding the current date 
      v_location_id := 'LOC_' || REPLACE(p_name, ' ', '_') || '_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI');

      INSERT INTO locations (location_id, name, address)
      VALUES (v_location_id, p_name, p_address);

      DBMS_OUTPUT.PUT_LINE('Successfully added new location with ID: ' || v_location_id);
      COMMIT;
   END;

   -- Delete location
   PROCEDURE delete_location (
      p_name IN locations.name%TYPE
   ) IS
   v_location_id VARCHAR2(50);
   BEGIN
      IF p_name IS NULL THEN
         DBMS_OUTPUT.PUT_LINE('Location name cannot be null.');
         RETURN; 
      END IF;

      IF NOT does_location_exist(p_name) THEN
         DBMS_OUTPUT.PUT_LINE('Location with name: ' || p_name || ' does not exist.');
         RETURN;
      END IF;

      UPDATE locations
      SET is_active = 0
      WHERE name = p_name;

      DBMS_OUTPUT.PUT_LINE('Successfully deleted location : ' || p_name);
      COMMIT;
   END;

   -- Restore deleted location
   PROCEDURE restore_location (
      p_name IN locations.name%TYPE
   ) IS
   v_location_id VARCHAR2(50);
   BEGIN
      IF p_name IS NULL THEN
         DBMS_OUTPUT.PUT_LINE('Location name cannot be null.');
         RETURN;
      END IF;

      IF NOT does_location_exist(p_name) THEN
         DBMS_OUTPUT.PUT_LINE('Location with name: ' || p_name || ' does not exist.');
         RETURN;
      END IF;

      UPDATE locations
      SET is_active = 1
      WHERE name = p_name;

      DBMS_OUTPUT.PUT_LINE('Successfully restored location: ' || p_name);
      COMMIT;
   END;

   FUNCTION does_shuttle_exist(p_license_plate IN shuttles.license_plate%TYPE) RETURN BOOLEAN IS
   v_shuttle_id VARCHAR2(50);
   BEGIN
      BEGIN
         SELECT shuttle_id
         INTO v_shuttle_id
         FROM shuttles
         WHERE license_plate = p_license_plate;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
      END;

   RETURN TRUE;
   END does_shuttle_exist;

   -- Add new shuttle
   PROCEDURE add_new_shuttle (
      p_model IN shuttles.model%TYPE,
      p_license_plate IN shuttles.license_plate%TYPE
   ) IS
   v_shuttle_id VARCHAR2(50);
   BEGIN
      IF p_model IS NULL OR p_license_plate IS NULL THEN
         DBMS_OUTPUT.PUT_LINE('Model and License Plate cannot be null.');
         RETURN;
      END IF;

      v_shuttle_id := 'SHUTTLE_' || p_license_plate;

      IF does_shuttle_exist(p_license_plate) THEN
         DBMS_OUTPUT.PUT_LINE('Shuttle with license plate: ' || p_license_plate || ' already exists.');
         RETURN;
      END IF;

      INSERT INTO shuttles (shuttle_id, model, license_plate)
      VALUES (v_shuttle_id, p_model, p_license_plate);

      DBMS_OUTPUT.PUT_LINE('Successfully added new shuttle with ID: ' || v_shuttle_id);
      COMMIT;
   END;

   -- Delete shuttle
   PROCEDURE delete_shuttle (
      p_license_plate IN shuttles.license_plate%TYPE
   ) IS
   v_shuttle_id VARCHAR2(50);
   BEGIN
      IF p_license_plate IS NULL THEN
         DBMS_OUTPUT.PUT_LINE('License Plate cannot be null.');
         RETURN;
      END IF;

      IF NOT does_shuttle_exist(p_license_plate) THEN
         DBMS_OUTPUT.PUT_LINE('Shuttle with license plate: ' || p_license_plate || ' does not exist.');
         RETURN;
      END IF;

      UPDATE shuttles
      SET is_active = 0
      WHERE license_plate = p_license_plate;

      DBMS_OUTPUT.PUT_LINE('Successfully deleted shuttle : ' || p_license_plate);
      COMMIT;
   END;


   -- Procedure to update shuttle mileage and schedule maintenance
   PROCEDURE schedule_vehicle_maintenance(
      p_license_plate IN shuttles.license_plate%TYPE,
      p_maintenance_date IN maintenance_schedules.maintenance_date%TYPE 
   ) IS
      v_shuttle_id VARCHAR2(50);
      v_maintenance_required VARCHAR2(50);
      v_total_mileage NUMBER;
      v_next_maintenance_date DATE;
      v_maintenance_id VARCHAR2(50);
      v_schedule_maintenance_date DATE;
   BEGIN

      IF p_license_plate IS NULL THEN
         DBMS_OUTPUT.PUT_LINE('License Plate cannot be null.');
         RETURN;
      END IF;

      IF NOT does_shuttle_exist(p_license_plate) THEN
         DBMS_OUTPUT.PUT_LINE('Shuttle with license plate: ' || p_license_plate || ' does not exist.');
         RETURN;
      END IF;

      IF p_maintenance_date IS NULL THEN
         v_next_maintenance_date := SYSDATE + INTERVAL '1' DAY;
      END IF;

      IF p_maintenance_date < SYSDATE THEN
         DBMS_OUTPUT.PUT_LINE('Maintenance date cannot be in the past.');
         RETURN;
      END IF;

      -- Get shuttle ID
      SELECT shuttle_id
      INTO v_shuttle_id
      FROM shuttles
      WHERE license_plate = p_license_plate;

      
      SELECT maintenance_status, CURRENT_MILEAGE
      INTO v_maintenance_required, v_total_mileage
      from shuttles_due_for_maintenance
      WHERE LICENSE_PLATE = p_license_plate;

   IF v_maintenance_required = 'Required' THEN
      -- Schedule maintenance
      v_next_maintenance_date := p_maintenance_date;
      

      v_maintenance_id := 'MNT_' || v_shuttle_id || '_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI');
      INSERT INTO maintenance_schedules (maintenance_id, shuttle_id, LAST_MAINTENANCE_MILEAGE, maintenance_date, description)
      VALUES (v_maintenance_id, v_shuttle_id, v_total_mileage, v_next_maintenance_date, 'Routine maintenance');

      DBMS_OUTPUT.PUT_LINE('Maintenance scheduled for shuttle: ' || p_license_plate);
      COMMIT;
   ELSE
      DBMS_OUTPUT.PUT_LINE('No maintenance required for shuttle: ' || p_license_plate);
   END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;

END asset_management_pkg;
/
