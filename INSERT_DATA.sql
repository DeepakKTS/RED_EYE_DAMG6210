-- Users
INSERT INTO users VALUES ('U1', 'John Doe', 'john@example.com', '1234567890', 'Student');
INSERT INTO users VALUES ('U2', 'Jane Smith', 'jane@example.com', '0987654321', 'Staff');
INSERT INTO users VALUES ('U3', 'Alice Brown', 'alice@example.com', '5551234567', 'Faculty');
INSERT INTO users VALUES ('U4', 'Bob White', 'bob@example.com', '4449876543', 'Student');
INSERT INTO users VALUES ('U5', 'Chris Green', 'chris@example.com', '3335558888', 'Staff');
COMMIT;

-- Roles
INSERT INTO roles VALUES ('R1', 'Admin');
INSERT INTO roles VALUES ('R2', 'Driver');
INSERT INTO roles VALUES ('R3', 'Supervisor');
INSERT INTO roles VALUES ('R4', 'Dispatcher');
INSERT INTO roles VALUES ('R5', 'Maintenance');
COMMIT;

-- Insert data into User Roles
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR1', 'R2', 'U1');
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR2', 'R1', 'U2');
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR3', 'R3', 'U3');
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR4', 'R4', 'U4');
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR5', 'R5', 'U5');
COMMIT;

-- Permissions
INSERT INTO permissions VALUES ('P1', 'R1', 'Can manage users');
INSERT INTO permissions VALUES ('P2', 'R2', 'Can drive shuttle');
INSERT INTO permissions VALUES ('P3', 'R3', 'Can supervise drivers');
INSERT INTO permissions VALUES ('P4', 'R4', 'Can dispatch shuttles');
INSERT INTO permissions VALUES ('P5', 'R5', 'Can perform maintenance');
COMMIT;

-- Locations
INSERT INTO locations VALUES ('L1', 'Main Campus', '123 Main St', '40.7128,-74.0060');
INSERT INTO locations VALUES ('L2', 'North Campus', '456 North St', '40.7129,-74.0050');
INSERT INTO locations VALUES ('L3', 'South Campus', '789 South St', '40.7130,-74.0040');
INSERT INTO locations VALUES ('L4', 'East Campus', '101 East St', '40.7131,-74.0030');
INSERT INTO locations VALUES ('L5', 'West Campus', '202 West St', '40.7132,-74.0020');
COMMIT;

-- Shuttles
INSERT INTO shuttles (shuttle_id, model, capacity, licensePlate, mileage) VALUES ('S1', 'Model X', 30, 'ABC123', 25);
INSERT INTO shuttles (shuttle_id, model, capacity, licensePlate, mileage) VALUES ('S2', 'Model Y', 25, 'DEF456', 20);
INSERT INTO shuttles (shuttle_id, model, capacity, licensePlate, mileage) VALUES ('S3', 'Model Z', 20, 'GHI789', 18);
INSERT INTO shuttles (shuttle_id, model, capacity, licensePlate, mileage) VALUES ('S4', 'Model A', 15, 'JKL012', 15);
INSERT INTO shuttles (shuttle_id, model, capacity, licensePlate, mileage) VALUES ('S5', 'Model B', 10, 'MNO345', 12);

COMMIT;

-- Trips
INSERT INTO trips VALUES ('T1', TO_TIMESTAMP('2024-11-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-01 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Completed', 'S1');
INSERT INTO trips VALUES ('T2', TO_TIMESTAMP('2024-11-02 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-02 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Completed', 'S2');
INSERT INTO trips VALUES ('T3', TO_TIMESTAMP('2024-11-03 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-03 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Scheduled', 'S3');
INSERT INTO trips VALUES ('T4', TO_TIMESTAMP('2024-12-26 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-12-26 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Scheduled', 'S4');--Adding futuristic date for the UPCOMING_BOOKINGS_VIEW to have data
INSERT INTO trips VALUES ('T5', TO_TIMESTAMP('2024-12-25 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-12-25 17:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Scheduled', 'S5');--Adding futuristic date for the UPCOMING_BOOKINGS_VIEW to have data
COMMIT;

-- Rides
INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, user_id, status) VALUES ('R1', 'L1', 'L2', 'T1', 'U1', 'Completed');
INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, user_id, status) VALUES ('R2', 'L2', 'L3', 'T2', 'U2', 'In Progress');
INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, user_id, status) VALUES ('R3', 'L3', 'L4', 'T3', 'U1', 'Pending');
INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, user_id, status) VALUES ('R4', 'L4', 'L5', 'T4', 'U2', 'Completed');
INSERT INTO rides (ride_id, pickupLocationId, dropoffLocationId, trip_id, user_id, status) VALUES ('R5', 'L5', 'L1', 'T5', 'U1', 'Completed');
COMMIT;

-- Third Party Services
INSERT INTO third_party_services VALUES ('TPS1', 'Transport Co', 'contact@transportco.com');
INSERT INTO third_party_services VALUES ('TPS2', 'City Shuttle Services', 'info@cityshuttle.com');
INSERT INTO third_party_services VALUES ('TPS3', 'Green Rides', 'support@greenrides.com');
INSERT INTO third_party_services VALUES ('TPS4', 'Urban Transit', 'hello@urbantransit.com');
INSERT INTO third_party_services VALUES ('TPS5', 'Eco Transport', 'contact@ecotransport.com');
COMMIT;

-- Insert data into Drivers (referencing user_roles)
INSERT INTO drivers (driver_id, user_role_id, licenseNumber, tp_id) 
VALUES ('D1', 'UR1', 'LIC123', 'TPS1');
INSERT INTO drivers (driver_id, user_role_id, licenseNumber, tp_id) 
VALUES ('D2', 'UR2', 'LIC456', 'TPS2');
INSERT INTO drivers (driver_id, user_role_id, licenseNumber, tp_id) 
VALUES ('D3', 'UR3', 'LIC789', 'TPS3');
INSERT INTO drivers (driver_id, user_role_id, licenseNumber, tp_id) 
VALUES ('D4', 'UR4', 'LIC012', 'TPS4');
INSERT INTO drivers (driver_id, user_role_id, licenseNumber, tp_id) 
VALUES ('D5', 'UR5', 'LIC345', 'TPS5');
COMMIT;

-- Shifts
INSERT INTO shifts VALUES ('SH1', 'S1', 'D1', TO_TIMESTAMP('2024-11-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-01 16:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO shifts VALUES ('SH2', 'S2', 'D2', TO_TIMESTAMP('2024-11-02 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-02 16:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO shifts VALUES ('SH3', 'S3', 'D3', TO_TIMESTAMP('2024-11-03 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-03 16:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO shifts VALUES ('SH4', 'S4', 'D4', TO_TIMESTAMP('2024-11-04 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-04 16:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO shifts VALUES ('SH5', 'S5', 'D5', TO_TIMESTAMP('2024-11-05 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-05 16:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO shifts VALUES ('SH6', 'S3', NULL, TO_TIMESTAMP('2024-11-06 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-05 12:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO shifts VALUES ('SH7', 'S1', NULL, TO_TIMESTAMP('2024-11-06 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-05 15:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO shifts VALUES ('SH8', 'S3', NULL, TO_TIMESTAMP('2024-11-05 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-05 16:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO shifts VALUES ('SH9', 'S2', NULL, TO_TIMESTAMP('2024-11-06 7:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-05 16:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO shifts VALUES ('SH10', 'S4', NULL, TO_TIMESTAMP('2024-11-06 8:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-05 10:00:00', 'YYYY-MM-DD HH24:MI:SS'));

COMMIT;

-- Maintenance Schedules
INSERT INTO maintenance_schedules VALUES ('M1', 'S1', TO_DATE('2024-11-05', 'YYYY-MM-DD'), 'Routine maintenance');
INSERT INTO maintenance_schedules VALUES ('M2', 'S2', TO_DATE('2024-11-06', 'YYYY-MM-DD'), 'Oil change');
INSERT INTO maintenance_schedules VALUES ('M3', 'S3', TO_DATE('2024-11-07', 'YYYY-MM-DD'), 'Tire replacement');
INSERT INTO maintenance_schedules VALUES ('M4', 'S4', TO_DATE('2024-11-08', 'YYYY-MM-DD'), 'Engine check');
INSERT INTO maintenance_schedules VALUES ('M5', 'S5', TO_DATE('2024-11-09', 'YYYY-MM-DD'), 'Brake inspection');
COMMIT;





