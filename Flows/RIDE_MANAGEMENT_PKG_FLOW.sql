BEGIN
  -- Test booking a ride
  RIDE_MANAGEMENT_PKG.book_ride(
    'piyush@redeye.com',
    'Main Office'
  );
END;
/
