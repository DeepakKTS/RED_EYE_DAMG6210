create or replace PACKAGE BODY asset_management_pkg IS

   -- Shuttles table operations
   PROCEDURE manage_shuttle (
      p_shuttle_id   IN VARCHAR2,
      p_model        IN VARCHAR2 DEFAULT NULL,
      p_capacity     IN NUMBER DEFAULT NULL,
      p_licensePlate IN VARCHAR2 DEFAULT NULL,
      p_action       IN VARCHAR2
   ) IS
      v_count NUMBER;
   BEGIN
      SELECT COUNT(*)
      INTO v_count
      FROM shuttles
      WHERE shuttle_id = p_shuttle_id;

      IF p_action = 'INSERT' THEN
         IF v_count = 0 THEN
            INSERT INTO shuttles (shuttle_id, model, capacity, licensePlate)
            VALUES (p_shuttle_id, p_model, p_capacity, p_licensePlate);
            DBMS_OUTPUT.PUT_LINE('? Successfully inserted shuttle with ID: ' || p_shuttle_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? Shuttle with ID: ' || p_shuttle_id || ' already exists.');
         END IF;
      ELSIF p_action = 'UPDATE' THEN
         IF v_count > 0 THEN
            UPDATE shuttles
            SET model = p_model,
                capacity = p_capacity,
                licensePlate = p_licensePlate
            WHERE shuttle_id = p_shuttle_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully updated shuttle with ID: ' || p_shuttle_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No shuttle found with ID: ' || p_shuttle_id);
         END IF;
      ELSIF p_action = 'DELETE' THEN
         IF v_count > 0 THEN
            DELETE FROM shuttles WHERE shuttle_id = p_shuttle_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully deleted shuttle with ID: ' || p_shuttle_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No shuttle found with ID: ' || p_shuttle_id);
         END IF;
      ELSE
         DBMS_OUTPUT.PUT_LINE('? Invalid action specified.');
      END IF;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
         RAISE_APPLICATION_ERROR(-20001, '? Failed to manage shuttle with ID: ' || p_shuttle_id);
   END manage_shuttle;

   -- Locations table operations
   PROCEDURE manage_location (
      p_location_id IN VARCHAR2,
      p_name        IN VARCHAR2 DEFAULT NULL,
      p_address     IN VARCHAR2 DEFAULT NULL,
      p_coordinates IN VARCHAR2 DEFAULT NULL,
      p_action      IN VARCHAR2
   ) IS
      v_count NUMBER;
   BEGIN
      SELECT COUNT(*)
      INTO v_count
      FROM locations
      WHERE location_id = p_location_id;

      IF p_action = 'INSERT' THEN
         IF v_count = 0 THEN
            INSERT INTO locations (location_id, name, address, coordinates)
            VALUES (p_location_id, p_name, p_address, p_coordinates);
            DBMS_OUTPUT.PUT_LINE('? Successfully inserted location with ID: ' || p_location_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? Location with ID: ' || p_location_id || ' already exists.');
         END IF;
      ELSIF p_action = 'UPDATE' THEN
         IF v_count > 0 THEN
            UPDATE locations
            SET name = p_name,
                address = p_address,
                coordinates = p_coordinates
            WHERE location_id = p_location_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully updated location with ID: ' || p_location_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No location found with ID: ' || p_location_id);
         END IF;
      ELSIF p_action = 'DELETE' THEN
         IF v_count > 0 THEN
            DELETE FROM locations WHERE location_id = p_location_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully deleted location with ID: ' || p_location_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No location found with ID: ' || p_location_id);
         END IF;
      ELSE
         DBMS_OUTPUT.PUT_LINE('? Invalid action specified.');
      END IF;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
         RAISE_APPLICATION_ERROR(-20002, '? Failed to manage location with ID: ' || p_location_id);
   END manage_location;

   -- Permissions table operations
   PROCEDURE manage_permission (
   p_permission_id     IN VARCHAR2,
   p_role_id           IN VARCHAR2 DEFAULT NULL,
   p_permissionDetails IN VARCHAR2 DEFAULT NULL,
   p_action            IN VARCHAR2
) IS
   v_count NUMBER;
BEGIN
   -- Check if the permission exists
   SELECT COUNT(*)
   INTO v_count
   FROM permissions
   WHERE permission_id = p_permission_id;

   IF p_action = 'INSERT' THEN
      IF v_count = 0 THEN
         INSERT INTO permissions (permission_id, role_id, permissionDetails)
         VALUES (p_permission_id, p_role_id, p_permissionDetails);
         DBMS_OUTPUT.PUT_LINE('? Successfully inserted permission with ID: ' || p_permission_id);
      ELSE
         DBMS_OUTPUT.PUT_LINE('?? Permission with ID: ' || p_permission_id || ' already exists.');
      END IF;
   ELSIF p_action = 'UPDATE' THEN
      IF v_count > 0 THEN
         UPDATE permissions
         SET role_id = p_role_id,
             permissionDetails = p_permissionDetails
         WHERE permission_id = p_permission_id;
         DBMS_OUTPUT.PUT_LINE('? Successfully updated permission with ID: ' || p_permission_id);
      ELSE
         DBMS_OUTPUT.PUT_LINE('?? No permission found with ID: ' || p_permission_id);
      END IF;
   ELSIF p_action = 'DELETE' THEN
      IF v_count > 0 THEN
         DELETE FROM permissions WHERE permission_id = p_permission_id;
         DBMS_OUTPUT.PUT_LINE('? Successfully deleted permission with ID: ' || p_permission_id);
      ELSE
         DBMS_OUTPUT.PUT_LINE('?? No permission found with ID: ' || p_permission_id);
      END IF;
   ELSE
      DBMS_OUTPUT.PUT_LINE('? Invalid action specified.');
   END IF;
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
      DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
      RAISE_APPLICATION_ERROR(-20004, '? Failed to manage permission with ID: ' || p_permission_id);
END manage_permission;
END asset_management_pkg;