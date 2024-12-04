BEGIN
  -- Test booking a ride
  RIDE_MANAGEMENT_PKG.book_ride(
    'L3',
    'U4'
  );

  -- Verify the ride was booked
  DECLARE
    v_count INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_count FROM RIDES WHERE user_id = 'U2' AND dropoff_location_id = 'L3' and status = 'BOOKED';
    IF v_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Test Failed: Ride not booked');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Test Passed: Ride booked successfully');
    END IF;
  END;

  -- -- Test canceling a ride
  -- transport_management_pkg.cancel_ride(
  --   'U2'
  -- );

  -- Verify the ride was canceled
  DECLARE
    v_count INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_count FROM RIDES WHERE user_id = 'U2' AND dropoff_location_id = 'L3' and status = 'BOOKED';
    IF v_count > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Test Failed: Ride not canceled');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Test Passed: Ride canceled successfully');
    END IF;
  END;
END;
/

SELECT * FROM TRIPS;
SELECT * FROM RIDES;


-- ROLLBACK;
