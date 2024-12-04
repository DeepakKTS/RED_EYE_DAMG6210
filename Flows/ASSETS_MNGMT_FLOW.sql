-- Test for adding a new user
begin
   asset_management_pkg.add_new_user(
      p_name  => 'John Doey',
      p_email => 'john.doe1@example.com',
      p_phone => '1234567890'
   );
end;
/

-- Test for adding a new driver
begin
   asset_management_pkg.add_new_driver(
      p_name          => 'Jane Smithy',
      p_email         => 'jane@a.com',
      p_phone         => '1234567890',
      p_licence_number => 'D1234567',
      p_tp_id         => 'TPS2'
   );
end;
/
