BEGIN
    FOR table_name IN (
        SELECT table_name 
        FROM user_tables 
        WHERE table_name IN (
            'SHIFTS', 'MAINTENANCE_SCHEDULES', 'THIRD_PARTY_SERVICES', 
            'DRIVERS', 'RIDES', 'TRIPS', 'SHUTTLES', 'LOCATIONS', 
            'PERMISSIONS', 'USER_ROLES', 'ROLES', 'USERS', 'DRIVER_VERIFICATIONS'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || table_name.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;
/
 
//_____ DDL ______//
 
-- DRIVER VERIFICATIONS TABLE (Must be created first as it is referenced by drivers)
CREATE TABLE driver_verifications (
    driver_id VARCHAR2(50) PRIMARY KEY,
    background_check VARCHAR2(10)
);
 
-- USERS TABLE
CREATE TABLE users (
    user_id VARCHAR2(50) PRIMARY KEY,
    name VARCHAR2(100),
    email VARCHAR2(100) UNIQUE,
    phone VARCHAR2(15),
    userType VARCHAR2(50)
);
 
-- ROLES TABLE
CREATE TABLE roles (
    role_id VARCHAR2(50) PRIMARY KEY,
    name VARCHAR2(50)
);
 
-- USER ROLES TABLE
CREATE TABLE user_roles (
    user_role_id VARCHAR2(50) PRIMARY KEY,
    role_id VARCHAR2(50),
    user_id VARCHAR2(50),
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
 
-- DRIVERS TABLE (References driver_verifications and user_roles)
CREATE TABLE drivers (
    driver_id VARCHAR2(50) PRIMARY KEY,
    user_role_id VARCHAR2(50),
    licenseNumber VARCHAR2(50) UNIQUE,
    FOREIGN KEY (user_role_id) REFERENCES user_roles(user_role_id) ON DELETE SET NULL, -- User role removal nullifies driver reference
    FOREIGN KEY (driver_id) REFERENCES driver_verifications(driver_id) ON DELETE CASCADE -- Deleting verification removes driver
);
 
-- PERMISSIONS TABLE
CREATE TABLE permissions (
    permission_id VARCHAR2(50) PRIMARY KEY,
    role_id VARCHAR2(50),
    permissionDetails VARCHAR2(255),
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
);
 
-- LOCATIONS TABLE
CREATE TABLE locations (
    location_id VARCHAR2(50) PRIMARY KEY,
    name VARCHAR2(100),
    address VARCHAR2(255),
    coordinates VARCHAR2(100)
);
 
-- SHUTTLES TABLE
CREATE TABLE shuttles (
    shuttle_id VARCHAR2(50) PRIMARY KEY,
    model VARCHAR2(50),
    capacity NUMBER,
    licensePlate VARCHAR2(50) UNIQUE,
    mileage NUMBER
);
 
-- TRIPS TABLE (References shuttles)
CREATE TABLE trips (
    trip_id VARCHAR2(50) PRIMARY KEY,
    startTime TIMESTAMP,
    endTime TIMESTAMP,
    status VARCHAR2(50),
    shuttle_id VARCHAR2(50),
    FOREIGN KEY (shuttle_id) REFERENCES shuttles(shuttle_id) ON DELETE CASCADE
);
 
-- RIDES TABLE (References trips, locations, and users)
CREATE TABLE rides (
    ride_id VARCHAR2(50) PRIMARY KEY,
    pickupLocationId VARCHAR2(50),
    dropoffLocationId VARCHAR2(50),
    trip_id VARCHAR2(50),
    user_id VARCHAR2(50),
    status VARCHAR2(50),
    FOREIGN KEY (pickupLocationId) REFERENCES locations(location_id) ON DELETE SET NULL,
    FOREIGN KEY (dropoffLocationId) REFERENCES locations(location_id) ON DELETE SET NULL,
    FOREIGN KEY (trip_id) REFERENCES trips(trip_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);
 
-- SHIFTS TABLE (References shuttles and drivers)
CREATE TABLE shifts (
    shift_id VARCHAR2(50) PRIMARY KEY,
    shuttle_id VARCHAR2(50),
    driver_id VARCHAR2(50),
    startTime TIMESTAMP,
    endTime TIMESTAMP,
    FOREIGN KEY (shuttle_id) REFERENCES shuttles(shuttle_id) ON DELETE CASCADE, -- Deleting a shuttle deletes associated shifts
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id) ON DELETE SET NULL -- Removing a driver nullifies the shift reference
);
 
-- MAINTENANCE SCHEDULES TABLE (References shuttles)
CREATE TABLE maintenance_schedules (
    maintenance_id VARCHAR2(50) PRIMARY KEY,
    shuttle_id VARCHAR2(50),
    maintenanceDate DATE,
    description VARCHAR2(255),
    FOREIGN KEY (shuttle_id) REFERENCES shuttles(shuttle_id) ON DELETE CASCADE
);
 
