-- Drop tables if they exist to prevent errors on re-run
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE user_roles CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE users CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE roles CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE permissions CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE drivers CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE rides CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE trips CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE locations CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE shuttles CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE shifts CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE third_party_services CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE maintenance_schedules CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

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

-- User Roles table (junction table)
CREATE TABLE user_roles (
    role_id VARCHAR2(50),
    user_id VARCHAR2(50),
    roleId VARCHAR2(50),
    PRIMARY KEY (role_id),
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

-- Trips table
CREATE TABLE trips (
    trip_id VARCHAR2(50) PRIMARY KEY,
    startTime TIMESTAMP,
    endTime TIMESTAMP,
    status VARCHAR2(50),
    shuttle_id VARCHAR2(50),
    FOREIGN KEY (shuttle_id) REFERENCES shuttles(shuttle_id)
);

-- Shuttles table
CREATE TABLE shuttles (
    shuttle_id VARCHAR2(50) PRIMARY KEY,
    model VARCHAR2(50),
    capacity NUMBER,
    licensePlate VARCHAR2(50) UNIQUE
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

-- Drivers table
CREATE TABLE drivers (
    driver_id VARCHAR2(50) PRIMARY KEY,
    user_id VARCHAR2(50),
    licenseNumber VARCHAR2(50) UNIQUE,
    tp_id VARCHAR2(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (tp_id) REFERENCES third_party_services(tp_id)
);

-- Third Party Services table
CREATE TABLE third_party_services (
    tp_id VARCHAR2(50) PRIMARY KEY,
    name VARCHAR2(100),
    contactInfo VARCHAR2(255)
);

-- Maintenance Schedules table
CREATE TABLE maintenance_schedules (
    maintenance_id VARCHAR2(50) PRIMARY KEY,
    shuttle_id VARCHAR2(50),
    maintenanceDate DATE,
    description VARCHAR2(255),
    FOREIGN KEY (shuttle_id) REFERENCES shuttles(shuttle_id)
);
