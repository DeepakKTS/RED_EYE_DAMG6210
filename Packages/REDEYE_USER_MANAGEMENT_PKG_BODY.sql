create or replace PACKAGE BODY redeye_user_management_pkg IS

   -- Users table operations
   PROCEDURE manage_user (
      p_user_id   IN VARCHAR2,
      p_name      IN VARCHAR2 DEFAULT NULL,
      p_email     IN VARCHAR2 DEFAULT NULL,
      p_phone     IN VARCHAR2 DEFAULT NULL,
      p_userType  IN VARCHAR2 DEFAULT NULL,
      p_action    IN VARCHAR2
   ) IS
      v_count NUMBER;
   BEGIN
      SELECT COUNT(*)
      INTO v_count
      FROM users
      WHERE user_id = p_user_id;

      IF p_action = 'INSERT' THEN
         IF v_count = 0 THEN
            INSERT INTO users (user_id, name, email, phone, userType)
            VALUES (p_user_id, p_name, p_email, p_phone, p_userType);
            DBMS_OUTPUT.PUT_LINE('? Successfully inserted user with ID: ' || p_user_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? User with ID: ' || p_user_id || ' already exists.');
         END IF;
      ELSIF p_action = 'UPDATE' THEN
         IF v_count > 0 THEN
            UPDATE users
            SET name = p_name,
                email = p_email,
                phone = p_phone,
                userType = p_userType
            WHERE user_id = p_user_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully updated user with ID: ' || p_user_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No user found with ID: ' || p_user_id);
         END IF;
      ELSIF p_action = 'DELETE' THEN
         IF v_count > 0 THEN
            DELETE FROM users WHERE user_id = p_user_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully deleted user with ID: ' || p_user_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No user found with ID: ' || p_user_id);
         END IF;
      ELSE
         DBMS_OUTPUT.PUT_LINE('? Invalid action specified.');
      END IF;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
         RAISE_APPLICATION_ERROR(-20001, '? Failed to manage user with ID: ' || p_user_id);
   END manage_user;

   -- Roles table operations
   PROCEDURE manage_role (
      p_role_id   IN VARCHAR2,
      p_name      IN VARCHAR2 DEFAULT NULL,
      p_action    IN VARCHAR2
   ) IS
      v_count NUMBER;
   BEGIN
      SELECT COUNT(*)
      INTO v_count
      FROM roles
      WHERE role_id = p_role_id;

      IF p_action = 'INSERT' THEN
         IF v_count = 0 THEN
            INSERT INTO roles (role_id, name)
            VALUES (p_role_id, p_name);
            DBMS_OUTPUT.PUT_LINE('? Successfully inserted role with ID: ' || p_role_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? Role with ID: ' || p_role_id || ' already exists.');
         END IF;
      ELSIF p_action = 'UPDATE' THEN
         IF v_count > 0 THEN
            UPDATE roles
            SET name = p_name
            WHERE role_id = p_role_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully updated role with ID: ' || p_role_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No role found with ID: ' || p_role_id);
         END IF;
      ELSIF p_action = 'DELETE' THEN
         IF v_count > 0 THEN
            DELETE FROM roles WHERE role_id = p_role_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully deleted role with ID: ' || p_role_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No role found with ID: ' || p_role_id);
         END IF;
      ELSE
         DBMS_OUTPUT.PUT_LINE('? Invalid action specified.');
      END IF;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
         RAISE_APPLICATION_ERROR(-20002, '? Failed to manage role with ID: ' || p_role_id);
   END manage_role;



   -- User Roles table operations
   PROCEDURE manage_user_role (
      p_user_role_id IN VARCHAR2,
      p_role_id      IN VARCHAR2 DEFAULT NULL,
      p_user_id      IN VARCHAR2 DEFAULT NULL,
      p_action       IN VARCHAR2
   ) IS
      v_count NUMBER;
   BEGIN
      -- Check if the record exists
      SELECT COUNT(*)
      INTO v_count
      FROM user_roles
      WHERE user_role_id = p_user_role_id;

      IF p_action = 'INSERT' THEN
         IF v_count = 0 THEN
            -- Insert new record
            INSERT INTO user_roles (user_role_id, role_id, user_id)
            VALUES (p_user_role_id, p_role_id, p_user_id);
            DBMS_OUTPUT.PUT_LINE('? Successfully inserted user role with ID: ' || p_user_role_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? User role with ID: ' || p_user_role_id || ' already exists.');
         END IF;
      ELSIF p_action = 'UPDATE' THEN
         IF v_count > 0 THEN
            -- Update existing record
            UPDATE user_roles
            SET role_id = p_role_id,
                user_id = p_user_id
            WHERE user_role_id = p_user_role_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully updated user role with ID: ' || p_user_role_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No user role found with ID: ' || p_user_role_id);
         END IF;
      ELSIF p_action = 'DELETE' THEN
         IF v_count > 0 THEN
            -- Delete existing record
            DELETE FROM user_roles WHERE user_role_id = p_user_role_id;
            DBMS_OUTPUT.PUT_LINE('? Successfully deleted user role with ID: ' || p_user_role_id);
         ELSE
            DBMS_OUTPUT.PUT_LINE('?? No user role found with ID: ' || p_user_role_id);
         END IF;
      ELSE
         DBMS_OUTPUT.PUT_LINE('? Invalid action specified.');
      END IF;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
         RAISE_APPLICATION_ERROR(-20003, '? Failed to manage user role with ID: ' || p_user_role_id);

   END manage_user_role;

END redeye_user_management_pkg;
