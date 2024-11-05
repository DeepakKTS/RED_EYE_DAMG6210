-- Sample data for users
INSERT INTO users (user_id, name, email, phone, userType) VALUES ('U1', 'John Doe', 'john.doe@example.com', '1234567890', 'Passenger');
INSERT INTO users (user_id, name, email, phone, userType) VALUES ('U2', 'Jane Smith', 'jane.smith@example.com', '0987654321', 'Driver');
INSERT INTO users (user_id, name, email, phone, userType) VALUES ('U3', 'Alice Johnson', 'alice.johnson@example.com', '1112223333', 'Passenger');
INSERT INTO users (user_id, name, email, phone, userType) VALUES ('U4', 'Bob Brown', 'bob.brown@example.com', '4445556666', 'Driver');
INSERT INTO users (user_id, name, email, phone, userType) VALUES ('U5', 'Charlie Green', 'charlie.green@example.com', '7778889999', 'Passenger');

-- Sample data for roles
INSERT INTO roles (role_id, name) VALUES ('R1', 'Admin');
INSERT INTO roles (role_id, name) VALUES ('R2', 'Driver');
INSERT INTO roles (role_id, name) VALUES ('R3', 'Passenger');

-- Sample data for user_roles
INSERT INTO user_roles (role_id, user_id, roleId) VALUES ('R1', 'U1', 'R1');
INSERT INTO user_roles (role_id, user_id, roleId) VALUES ('R2', 'U2', 'R2');
INSERT INTO user_roles (role_id, user_id, roleId) VALUES ('R3', 'U3', 'R3');
INSERT INTO user_roles (role_id, user_id, roleId) VALUES ('R2', 'U4', 'R2');
INSERT INTO user_roles (role_id, user_id, roleId) VALUES ('R3', 'U5', 'R3');

-- Sample data for permissions
INSERT INTO permissions (permission_id, role_id, permissionDetails) VALUES ('P1', 'R1', 'Full Access');
INSERT INTO permissions (permission_id, role_id, permissionDetails) VALUES ('P2', 'R2', 'Driver Access');
INSERT INTO permissions (permission_id, role_id, permissionDetails) VALUES ('P3', 'R3', 'Passenger Access');

-- Sample data for locations
INSERT INTO locations (location_id, name, address, coordinates) VALUES ('L1', 'Main Street', '123 Main St', '41.40338, 2.17403');
INSERT INTO locations (location_id, name, address, coordinates) VALUES ('L2', 'Downtown', '456 Downtown Ave', '42.40338, 2.17503');
INSERT INTO locations (location_id, name, address, coordinates) VALUES ('L3', 'Central Park', '789 Park Lane', '43.40338, 2.17603');
INSERT INTO locations (location_id, name, address, coordinates) VALUES ('L4', 'City Center', '101 Center St', '44.40338, 2.17703');
INSERT INTO locations (location_id, name, address, coordinates) VALUES ('L5', 'North Avenue', '202 North Ave', '45.40338, 2.17803');

-- Sample data for shuttles
INSERT INTO shuttles (shuttle_id, model, capacity, licensePlate) VALUES ('S1', 'Model X', 15, 'ABC123');
INSERT INTO shuttles (shuttle_id, model, capacity, licensePlate) VALUES ('S2', 'Model Y', 20, 'XYZ456');
INSERT INTO shuttles (shuttle_id, model, capacity, licensePlate) VALUES ('S3', 'Model Z', 18, 'DEF789');
INSERT INTO shuttles (shuttle_id, model, capacity, licensePlate) VALUES ('S4', 'Model A', 25, 'GHI101');
INSERT INTO shuttles (shuttle_id, model, capacity, licensePlate) VALUES ('S5', 'Model B', 12, 'JKL202');

-- Sample data for trips
INSERT INTO trips (trip_id, startTime, endTime, status, shuttle_id) VALUES ('T1', TO_TIMESTAMP('2024-10-10 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-10-10 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Completed', 'S1');
INSERT INTO trips (trip_id, startTime, endTime, status, shuttle_id) VALUES ('T2', TO_TIMESTAMP('2024-10-10 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-10-10 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Pending', 'S2');
INSERT INTO trips (trip_id, startTime, endTime, status, shuttle_id) VALUES ('T3', TO_TIMESTAMP('2024-10-10 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-10-10 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'In Progress', 'S3');
INSERT INTO trips (trip_id, startTime, endTime, status, shuttle_id) VALUES ('T4', TO_TIMESTAMP('2024-10-10 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-10-10 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Completed', 'S4');
INSERT INTO trips (trip_id, startTime, endTime, status, shuttle_id) VALUES ('T5', TO_TIMESTAMP('2024-10-10 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-10-10 17:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Pending', 'S5');

-- Sample data for rides
INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, user_id, status) VALUES ('R1', 'L1', 'L2', 'T1', 'U1', 'Completed');
INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, user_id, status) VALUES ('R2', 'L2', 'L3', 'T2', 'U3', 'Pending');
INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, user_id, status) VALUES ('R3', 'L3', 'L4', 'T3', 'U1', 'In Progress');
INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, user_id, status) VALUES ('R4', 'L4', 'L5', 'T4', 'U5', 'Completed');
INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, user_id, status) VALUES ('R5', 'L5', 'L1', 'T5', 'U3', 'Pending');

-- Sample data for maintenance_schedules
INSERT INTO maintenance_schedules (maintenance_id, shuttle_id, maintenanceDate, description) VALUES ('M1', 'S1', TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'Engine Check');
INSERT INTO maintenance_schedules (maintenance_id, shuttle_id, maintenanceDate, description) VALUES ('M2', 'S2', TO_DATE('2024-11-02', 'YYYY-MM-DD'), 'Tire Replacement');
INSERT INTO maintenance_schedules (maintenance_id, shuttle_id, maintenanceDate, description) VALUES ('M3', 'S3', TO_DATE('2024-11-03', 'YYYY-MM-DD'), 'Oil Change');
INSERT INTO maintenance_schedules (maintenance_id, shuttle_id, maintenanceDate, description) VALUES ('M4', 'S4', TO_DATE('2024-11-04', 'YYYY-MM-DD'), 'Brake Inspection');
INSERT INTO maintenance_schedules (maintenance_id, shuttle_id, maintenanceDate, description) VALUES ('M5', 'S5', TO_DATE('2024-11-05', 'YYYY-MM-DD'), 'Battery Check');

-- Sample data for shifts
INSERT INTO shifts (shift_id, shuttle_id, driver_id, startTime, endTime) VALUES ('Shift1', 'S1', 'U2', TO_TIMESTAMP('2024-10-10 06:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-10-10 10:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO shifts (shift_id, shuttle_id, driver_id, startTime, endTime) VALUES ('Shift2', 'S2', 'U4', TO_TIMESTAMP('2024-10-10 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-10-10 12:00:00', 'YYYY-MM
