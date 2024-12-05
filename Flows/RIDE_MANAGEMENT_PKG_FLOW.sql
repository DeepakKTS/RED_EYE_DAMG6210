BEGIN
  -- Test booking a ride
  redeye_user_management_pkg.book_ride(
    'piyush@redeye.com',
    'Main Office'
  );
END;
/
