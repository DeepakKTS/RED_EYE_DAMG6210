create or replace PACKAGE asset_management_pkg IS
   -- Shuttles table operations
   PROCEDURE manage_shuttle (
      p_shuttle_id   IN VARCHAR2,
      p_model        IN VARCHAR2 DEFAULT NULL,
      p_capacity     IN NUMBER DEFAULT NULL,
      p_licensePlate IN VARCHAR2 DEFAULT NULL,
      p_action       IN VARCHAR2
   );

   -- Locations table operations
   PROCEDURE manage_location (
      p_location_id IN VARCHAR2,
      p_name        IN VARCHAR2 DEFAULT NULL,
      p_address     IN VARCHAR2 DEFAULT NULL,
      p_coordinates IN VARCHAR2 DEFAULT NULL,
      p_action      IN VARCHAR2
   );

   -- Permissions table operations
   PROCEDURE manage_permission (
      p_permission_id     IN VARCHAR2,
      p_role_id           IN VARCHAR2 DEFAULT NULL,
      p_permissionDetails IN VARCHAR2 DEFAULT NULL,
      p_action            IN VARCHAR2
   );
END asset_management_pkg;