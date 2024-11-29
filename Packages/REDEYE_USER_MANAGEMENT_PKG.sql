create or replace PACKAGE redeye_user_management_pkg IS
   -- Users table operations
   PROCEDURE manage_user (
      p_user_id   IN VARCHAR2,
      p_name      IN VARCHAR2 DEFAULT NULL,
      p_email     IN VARCHAR2 DEFAULT NULL,
      p_phone     IN VARCHAR2 DEFAULT NULL,
      p_userType  IN VARCHAR2 DEFAULT NULL,
      p_action    IN VARCHAR2
   );

   -- Roles table operations
   PROCEDURE manage_role (
      p_role_id   IN VARCHAR2,
      p_name      IN VARCHAR2 DEFAULT NULL,
      p_action    IN VARCHAR2
   );

   -- User Roles table operations
   PROCEDURE manage_user_role (
      p_user_role_id IN VARCHAR2,
      p_role_id      IN VARCHAR2 DEFAULT NULL,
      p_user_id      IN VARCHAR2 DEFAULT NULL,
      p_action       IN VARCHAR2
   );
END redeye_user_management_pkg;