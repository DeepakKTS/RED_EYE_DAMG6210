CREATE OR REPLACE PACKAGE redeye_user_management_pkg IS
   -- Procedure to update user details
   PROCEDURE update_user (
      p_name IN users.name%TYPE DEFAULT NULL,
      p_email IN users.email%TYPE DEFAULT NULL,
      p_phone IN users.phone%TYPE DEFAULT NULL
   );

END redeye_user_management_pkg;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY redeye_user_management_pkg IS
   PROCEDURE update_user (
      p_name IN users.name%TYPE DEFAULT NULL,
      p_email IN users.email%TYPE DEFAULT NULL,
      p_phone IN users.phone%TYPE DEFAULT NULL
   ) IS
   BEGIN
      assets_management_pkg.update_user(p_name, p_email, p_phone);
   END update_user;

END redeye_user_management_pkg;
/
