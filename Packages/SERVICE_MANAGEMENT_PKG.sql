create or replace PACKAGE service_management_pkg IS

   -- Shifts table operations
   PROCEDURE manage_shift (
      p_shift_id   IN VARCHAR2,
      p_shuttle_id IN VARCHAR2 DEFAULT NULL,
      p_driver_id  IN VARCHAR2 DEFAULT NULL,
      p_startTime  IN TIMESTAMP DEFAULT NULL,
      p_endTime    IN TIMESTAMP DEFAULT NULL,
      p_action     IN VARCHAR2
   );

   -- Maintenance Schedules table operations
   PROCEDURE manage_maintenance_schedule (
      p_maintenance_id IN VARCHAR2,
      p_shuttle_id     IN VARCHAR2 DEFAULT NULL,
      p_maintenanceDate IN DATE DEFAULT NULL,
      p_description    IN VARCHAR2 DEFAULT NULL,
      p_action         IN VARCHAR2
   );

   -- Third Party Services table operations
   PROCEDURE manage_third_party_service (
      p_tp_id      IN VARCHAR2,
      p_name       IN VARCHAR2 DEFAULT NULL,
      p_contactInfo IN VARCHAR2 DEFAULT NULL,
      p_action     IN VARCHAR2
   );

END service_management_pkg;