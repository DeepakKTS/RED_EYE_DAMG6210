-- Add shuttles
BEGIN
    asset_management_pkg.add_new_shuttle('Toyota', 'ABC123');
    asset_management_pkg.add_new_shuttle('Honda', 'XYZ456');
    asset_management_pkg.add_new_shuttle('Ford', 'DEF789');
    asset_management_pkg.add_new_shuttle('Chevrolet', 'GHI101');
    asset_management_pkg.add_new_shuttle('Nissan', 'JKL112');
END;
/

-- Add user
BEGIN
    asset_management_pkg.add_new_user('Piyush Dongre', 'piyush@redeye.com','7377377327');
END;
/

-- Schedule shifts
BEGIN
    shift_management_pkg.create_shifts(SYSDATE);
END;
/
