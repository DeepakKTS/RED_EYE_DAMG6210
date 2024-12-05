-- Get all dropoff locations
SELECT * FROM redeye.view_all_dropoff_locations;

BEGIN
  -- Test booking a ride
  redeye.redeye_user_management_pkg.book_ride(
    'piyush1@redeye.com',
    'Store 1'
  );
END;
/

BEGIN
  -- Test cancelling a ride
  redeye.redeye_user_management_pkg.cancel_ride(
    'piyush@redeye.com'
  );
END;
/

BEGIN
  -- Test updating user details
  redeye.redeye_user_management_pkg.update_user(
    'Piyush',
    'piyush@redeye.com; DROP TABLE users;'
  );
END;
