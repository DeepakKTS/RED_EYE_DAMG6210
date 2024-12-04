CREATE OR REPLACE PACKAGE redeye_user_management_pkg IS
   -- Procedure to update user details
   PROCEDURE update_user (
      p_name IN users.name%TYPE DEFAULT NULL,
      p_email IN users.email%TYPE DEFAULT NULL,
      p_phone IN users.phone%TYPE DEFAULT NULL
   );

   PROCEDURE book_ride (
      p_email IN users.email%TYPE,
      p_dropoff_location_name IN locations.name%TYPE
   );

   PROCEDURE cancel_ride (
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
      assets_management_pkg.update_user(p_name, p_email, p_phone);
   END update_user;

   PROCEDURE book_ride (
      p_email IN users.email%TYPE,
      p_dropoff_location_name IN locations.name%TYPE
   ) IS
   BEGIN
      ride_management_pkg.book_ride(p_email, p_dropoff_location_name);
   END book_ride;

   PROCEDURE cancel_ride (
      p_email IN users.email%TYPE
   ) IS
   BEGIN
      ride_management_pkg.cancel_ride(p_email);
   END cancel_ride;

END redeye_user_management_pkg;
/
