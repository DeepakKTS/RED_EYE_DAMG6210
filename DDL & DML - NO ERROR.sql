//-----------------------------------


-- Drop existing data if any
BEGIN
    FOR table_name IN (
        SELECT table_name 
        FROM user_tables 
        WHERE table_name IN (
            'SHIFTS', 'MAINTENANCE_SCHEDULES', 'THIRD_PARTY_SERVICES', 
            'DRIVERS', 'RIDES', 'TRIPS', 'SHUTTLES', 'LOCATIONS', 
            'PERMISSIONS', 'USER_ROLES', 'ROLES', 'USERS'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || table_name.table_name || ' CASCADE CONSTRAINTS';
        DBMS_OUTPUT.PUT_LINE('Dropped table ' || table_name.table_name);
    END LOOP;
END;
/

-- Recreate tables
-- Users table
CREATE TABLE users (
    user_id VARCHAR2(50) PRIMARY KEY,
    name VARCHAR2(100),
    email VARCHAR2(100) UNIQUE,
    phone VARCHAR2(15),
    userType VARCHAR2(50)
);

-- Roles table
CREATE TABLE roles (
    role_id VARCHAR2(50) PRIMARY KEY,
    name VARCHAR2(50)
);

-- User Roles table
CREATE TABLE user_roles (
    user_role_id VARCHAR2(50) PRIMARY KEY,
    role_id VARCHAR2(50),
    user_id VARCHAR2(50),
    FOREIGN KEY (role_id) REFERENCES roles(role_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Permissions table
CREATE TABLE permissions (
    permission_id VARCHAR2(50) PRIMARY KEY,
    role_id VARCHAR2(50),
    permissionDetails VARCHAR2(255),
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- Locations table
CREATE TABLE locations (
    location_id VARCHAR2(50) PRIMARY KEY,
    name VARCHAR2(100),
    address VARCHAR2(255),
    coordinates VARCHAR2(100)
);

-- Shuttles table
CREATE TABLE shuttles (
    shuttle_id VARCHAR2(50) PRIMARY KEY,
    model VARCHAR2(50),
    capacity NUMBER,
    licensePlate VARCHAR2(50) UNIQUE
);

-- Trips table
CREATE TABLE trips (
    trip_id VARCHAR2(50) PRIMARY KEY,
    startTime TIMESTAMP,
    endTime TIMESTAMP,
    status VARCHAR2(50),
    shuttle_id VARCHAR2(50),
    FOREIGN KEY (shuttle_id) REFERENCES shuttles(shuttle_id)
);

-- Rides table
CREATE TABLE rides (
    ride_id VARCHAR2(50) PRIMARY KEY,
    pickupLocationId VARCHAR2(50),
    dropoffLocationId VARCHAR2(50),
    trip_id VARCHAR2(50),
    user_id VARCHAR2(50),
    status VARCHAR2(50),
    FOREIGN KEY (pickupLocationId) REFERENCES locations(location_id),
    FOREIGN KEY (dropoffLocationId) REFERENCES locations(location_id),
    FOREIGN KEY (trip_id) REFERENCES trips(trip_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Third Party Services table
CREATE TABLE third_party_services (
    tp_id VARCHAR2(50) PRIMARY KEY,
    name VARCHAR2(100),
    contactInfo VARCHAR2(255)
);

-- Drivers table
CREATE TABLE drivers (
    driver_id VARCHAR2(50) PRIMARY KEY,
    user_role_id VARCHAR2(50) UNIQUE,
    licenseNumber VARCHAR2(50) UNIQUE,
    tp_id VARCHAR2(50),
    FOREIGN KEY (user_role_id) REFERENCES user_roles(user_role_id),
    FOREIGN KEY (tp_id) REFERENCES third_party_services(tp_id)
);

-- Shifts table
CREATE TABLE shifts (
    shift_id VARCHAR2(50) PRIMARY KEY,
    shuttle_id VARCHAR2(50),
    driver_id VARCHAR2(50),
    startTime TIMESTAMP,
    endTime TIMESTAMP,
    FOREIGN KEY (shuttle_id) REFERENCES shuttles(shuttle_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

-- Maintenance Schedules table
CREATE TABLE maintenance_schedules (
    maintenance_id VARCHAR2(50) PRIMARY KEY,
    shuttle_id VARCHAR2(50),
    maintenanceDate DATE,
    description VARCHAR2(255),
    FOREIGN KEY (shuttle_id) REFERENCES shuttles(shuttle_id)
);

-- Inserting data into tables in the correct order

-- Users
INSERT INTO users VALUES ('U1', 'John Doe', 'john@example.com', '1234567890', 'Student');
INSERT INTO users VALUES ('U2', 'Jane Smith', 'jane@example.com', '0987654321', 'Staff');

-- Roles
INSERT INTO roles VALUES ('R1', 'Admin');
INSERT INTO roles VALUES ('R2', 'Driver');

-- User Roles
INSERT INTO user_roles VALUES ('UR1', 'R2', 'U1');
INSERT INTO user_roles VALUES ('UR2', 'R1', 'U2');

-- Permissions
INSERT INTO permissions VALUES ('P1', 'R1', 'Can manage users');
INSERT INTO permissions VALUES ('P2', 'R2', 'Can drive shuttle');

-- Locations
INSERT INTO locations VALUES ('L1', 'Main Campus', '123 Main St', '40.7128,-74.0060');
INSERT INTO locations VALUES ('L2', 'North Campus', '456 North St', '40.7129,-74.0050');

-- Shuttles
INSERT INTO shuttles VALUES ('S1', 'Model X', 30, 'ABC123');
INSERT INTO shuttles VALUES ('S2', 'Model Y', 25, 'DEF456');

-- Trips
INSERT INTO trips VALUES ('T1', TO_TIMESTAMP('2024-11-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-01 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Completed', 'S1');

-- Rides
INSERT INTO rides VALUES ('R1', 'L1', 'L2', 'T1', 'U1', 'Completed');

-- Third Party Services
INSERT INTO third_party_services VALUES ('TPS1', 'Transport Co', 'contact@transportco.com');

-- Drivers
INSERT INTO drivers VALUES ('D1', 'UR1', 'LIC123', 'TPS1');

-- Shifts
INSERT INTO shifts VALUES ('SH1', 'S1', 'D1', TO_TIMESTAMP('2024-11-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-01 16:00:00', 'YYYY-MM-DD HH24:MI:SS'));

-- Maintenance Schedules
INSERT INTO maintenance_schedules VALUES ('M1', 'S1', TO_DATE('2024-11-05', 'YYYY-MM-DD'), 'Routine maintenance');
