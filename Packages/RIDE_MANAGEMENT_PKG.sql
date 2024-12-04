CREATE OR REPLACE PACKAGE ride_management_pkg IS

   -- Procedure to book a ride
   PROCEDURE book_ride (
      p_dropoff_location_id IN VARCHAR2,
      p_email             IN VARCHAR2
   );

   -- Procedure to handle ride cancellations
   PROCEDURE cancel_ride (
      p_email IN VARCHAR2
   );

END ride_management_pkg;
/
