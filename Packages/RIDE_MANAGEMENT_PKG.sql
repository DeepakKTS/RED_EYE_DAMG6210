create or replace package ride_management_pkg is

   -- Procedure to book a ride
   procedure book_ride (
      p_email         in varchar2,
      p_dropoff_location_name in varchar2
   );

   -- Procedure to handle ride cancellations
   procedure cancel_ride (
      p_email in varchar2
   );

end ride_management_pkg;
/
