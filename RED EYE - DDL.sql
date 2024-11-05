DECLARE
    table_count NUMBER;
    tables_to_drop SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST(
        'SHIFTS', 'MAINTENANCE_SCHEDULES', 'THIRD_PARTY_SERVICES', 
        'DRIVERS', 'RIDES', 'TRIPS', 'SHUTTLES', 'LOCATIONS', 
        'PERMISSIONS', 'USER_ROLES', 'ROLES', 'USERS'
    );
BEGIN
    FOR i IN 1 .. tables_to_drop.COUNT LOOP
        SELECT COUNT(*)
        INTO table_count
        FROM user_tables
        WHERE table_name = tables_to_drop(i);

        IF table_count > 0 THEN
            EXECUTE IMMEDIATE 'DROP TABLE ' || tables_to_drop(i) || ' CASCADE CONSTRAINTS';
            DBMS_OUTPUT.PUT_LINE('Dropped table ' || tables_to_drop(i));
        ELSE
            DBMS_OUTPUT.PUT_LINE('Table ' || tables_to_drop(i) || ' does not exist.');
        END IF;
    END LOOP;
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
    user_role_id VARCHAR2(50) PRIMARY KEY,  -- unique identifier for each user-role assignment
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
    user_role_id VARCHAR2(50) UNIQUE,  -- Unique constraint to link to specific user-role combination
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
