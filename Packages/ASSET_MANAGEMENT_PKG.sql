create or replace PACKAGE asset_management_pkg IS

   -- Procedure to add new users
   PROCEDURE add_new_user (
      p_name IN users.name%TYPE,
      p_email IN users.email%TYPE, 
      p_phone IN users.phone%TYPE
   );
   
   -- Procedure to add new drivers 
   PROCEDURE add_new_driver (
      p_name IN users.name%TYPE,
      p_email IN users.email%TYPE,
      p_phone IN users.phone%TYPE,
      p_license_number IN drivers.license_number%TYPE,
      p_tp_id IN third_party_services.tp_id%TYPE
   );

   -- Procedure to delete users (soft delete)
   PROCEDURE delete_user (
      p_email IN users.email%TYPE
   );

   -- Procedure to update user details
   PROCEDURE update_user (
      p_name IN users.name%TYPE DEFAULT NULL,
      p_email IN users.email%TYPE DEFAULT NULL,
      p_phone IN users.phone%TYPE DEFAULT NULL
   );

   -- Restore deleted user
   PROCEDURE restore_user (
      p_email IN users.email%TYPE
   );

   -- Procedure to Add new location
   PROCEDURE add_new_location (
      p_name IN locations.name%TYPE,
      p_address IN locations.address%TYPE
   );

   -- Procedure to delete location
   PROCEDURE delete_location (
      p_name IN locations.name%TYPE
   );

   -- Procedure to restore location
   PROCEDURE restore_location (
      p_name IN locations.name%TYPE
   );

   -- Procedure to add new shuttle 
   PROCEDURE add_new_shuttle (
      p_model IN shuttles.model%TYPE,
      p_license_plate IN shuttles.license_plate%TYPE
   );

   -- Procedure to delete shuttle
   PROCEDURE delete_shuttle (
      p_license_plate IN shuttles.license_plate%TYPE
   );

   -- Procedure to schedule vehicle maintenance
   PROCEDURE schedule_vehicle_maintenance (
      p_license_plate IN shuttles.license_plate%TYPE,
      p_maintenance_date IN maintenance_schedules.maintenance_date%TYPE 
   );

END asset_management_pkg;
