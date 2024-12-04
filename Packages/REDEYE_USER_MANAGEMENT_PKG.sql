CREATE OR REPLACE PACKAGE redeye_user_management_pkg IS
   -- Procedure to update user details
   PROCEDURE update_user (
      p_name IN users.name%TYPE DEFAULT NULL,
      p_email IN users.email%TYPE DEFAULT NULL,
      p_phone IN users.phone%TYPE DEFAULT NULL
   );

   -- Procedure to view all past rides
   PROCEDURE view_past_rides (
      p_email IN users.email%TYPE
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
      -- Ensure asset_management_pkg is defined and accessible
      asset_management_pkg.update_user(
         p_name  => p_name,
         p_email => p_email,
         p_phone => p_phone
      );
   END update_user;

   PROCEDURE view_past_rides (
      p_email IN users.email%TYPE
   ) IS
   BEGIN
      -- Ensure ride_management_pkg is defined and accessible
      ride_management_pkg.view_past_rides(p_email);
   END view_past_rides;

END redeye_user_management_pkg;
/
