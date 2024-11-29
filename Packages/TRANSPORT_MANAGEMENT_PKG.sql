create or replace PACKAGE transport_management_pkg IS
   -- Trips table operations
   PROCEDURE manage_trip (
      p_trip_id   IN VARCHAR2,
      p_startTime IN TIMESTAMP DEFAULT NULL,
      p_endTime   IN TIMESTAMP DEFAULT NULL,
      p_status    IN VARCHAR2 DEFAULT NULL,
      p_shuttle_id IN VARCHAR2 DEFAULT NULL,
      p_action    IN VARCHAR2
   );

   -- Rides table operations
   PROCEDURE manage_ride (
      p_ride_id           IN VARCHAR2,
      p_pickupLocationId  IN VARCHAR2 DEFAULT NULL,
      p_dropoffLocationId IN VARCHAR2 DEFAULT NULL,
      p_trip_id           IN VARCHAR2 DEFAULT NULL,
      p_user_id           IN VARCHAR2 DEFAULT NULL,
      p_status            IN VARCHAR2 DEFAULT NULL,
      p_action            IN VARCHAR2
   );

   -- Drivers table operations
   PROCEDURE manage_driver (
      p_driver_id    IN VARCHAR2,
      p_user_role_id IN VARCHAR2 DEFAULT NULL,
      p_licenseNumber IN VARCHAR2 DEFAULT NULL,
      p_tp_id        IN VARCHAR2 DEFAULT NULL,
      p_action       IN VARCHAR2
   );
END transport_management_pkg;