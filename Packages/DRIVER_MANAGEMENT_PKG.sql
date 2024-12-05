CREATE OR REPLACE PACKAGE driver_management_pkg as

    PROCEDURE update_driver_details (
      p_name IN users.name%TYPE DEFAULT NULL,
      p_email IN users.email%TYPE DEFAULT NULL,
      p_phone IN users.phone%TYPE DEFAULT NULL
    );

END driver_management_pkg;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY driver_management_pkg AS

    PROCEDURE update_driver_details (
      p_name IN users.name%TYPE DEFAULT NULL,
      p_email IN users.email%TYPE DEFAULT NULL,
      p_phone IN users.phone%TYPE DEFAULT NULL
    ) IS
    BEGIN
      asset_management_pkg.update_user(p_name, p_email, p_phone);
    END update_driver_details;

END driver_management_pkg;
