--_____ DDL ______//
-- Drop existing data if any
BEGIN
    FOR table_name IN (
        SELECT table_name 
        FROM user_tables 
        WHERE table_name IN (
            'SHIFTS', 'MAINTENANCE_SCHEDULES', 'THIRD_PARTY_SERVICES', 
            'DRIVERS', 'RIDES', 'TRIPS', 'SHUTTLES', 'LOCATIONS', 
            'PERMISSIONS', 'USER_ROLES', 'ROLES', 'USERS', 'SHUTTLE_MILEAGE_RECORDS'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || table_name.table_name || ' CASCADE CONSTRAINTS';
        DBMS_OUTPUT.PUT_LINE('Dropped table ' || table_name.table_name);
    END LOOP;
END;
/

-- THIRD PARTY SERVICES TABLE (Created first as it is referenced by DRIVERS)
CREATE TABLE third_party_services (
    tp_id VARCHAR2(50) PRIMARY KEY,
    service_name VARCHAR2(100),
    contact_email VARCHAR2(100)
);



-- USERS TABLE (Created before USER_ROLES)
CREATE TABLE users (
    user_id VARCHAR2(50) PRIMARY KEY,
    name VARCHAR2(100),
    email VARCHAR2(100) UNIQUE,
    phone VARCHAR2(15),
    is_active NUMBER(1) DEFAULT 1
);

-- ROLES TABLE (Created before USER_ROLES)
CREATE TABLE roles (
    role_id VARCHAR2(50) PRIMARY KEY,
    name VARCHAR2(50)
);

-- USER ROLES TABLE (References ROLES and USERS)
CREATE TABLE user_roles (
    user_role_id VARCHAR2(50) PRIMARY KEY,
    role_id VARCHAR2(50),
    user_id VARCHAR2(50),
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- DRIVERS TABLE (References DRIVER_VERIFICATIONS and USER_ROLES)
CREATE TABLE drivers (
    driver_id VARCHAR2(50) PRIMARY KEY, 
    verification_flag  VARCHAR2(50),
    user_role_id VARCHAR2(50) UNIQUE,
    license_number VARCHAR2(50) UNIQUE,
    tp_id VARCHAR2(50),
    is_active NUMBER(1) DEFAULT 1,
    FOREIGN KEY (user_role_id) REFERENCES user_roles(user_role_id), -- Connect to user_roles
    FOREIGN KEY (tp_id) REFERENCES third_party_services(tp_id) -- Connect to third_party_services
);

-- PERMISSIONS TABLE (References ROLES)
CREATE TABLE permissions (
    permission_id VARCHAR2(50) PRIMARY KEY,
    role_id VARCHAR2(50),
    permission_details VARCHAR2(255),
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
);

-- LOCATIONS TABLE (No dependencies)
CREATE TABLE locations (
    location_id VARCHAR2(50) PRIMARY KEY,
    name VARCHAR2(100) UNIQUE,
    address VARCHAR2(255),
    is_active NUMBER(1) DEFAULT 1
);

-- SHUTTLES TABLE (No dependencies)
CREATE TABLE shuttles (
    shuttle_id VARCHAR2(50) PRIMARY KEY,
    model VARCHAR2(50),
    capacity NUMBER DEFAULT 2,
    license_plate VARCHAR2(50) UNIQUE,
    is_active NUMBER(1) DEFAULT 1
);

-- TRIPS TABLE (References SHUTTLES)
CREATE TABLE trips (
    trip_id VARCHAR2(50) PRIMARY KEY,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR2(50),
    shuttle_id VARCHAR2(50),
    FOREIGN KEY (shuttle_id) REFERENCES shuttles(shuttle_id) ON DELETE CASCADE
);

-- RIDES TABLE (References TRIPS, LOCATIONS, and USERS)
CREATE TABLE rides (
    ride_id VARCHAR2(50) PRIMARY KEY,
    pickup_location_id VARCHAR2(50),
    dropoff_location_id VARCHAR2(50),
    trip_id VARCHAR2(50),
    user_id VARCHAR2(50),
    status VARCHAR2(50),
    FOREIGN KEY (pickup_location_id) REFERENCES locations(location_id) ON DELETE SET NULL,
    FOREIGN KEY (dropoff_location_id) REFERENCES locations(location_id) ON DELETE SET NULL,
    FOREIGN KEY (trip_id) REFERENCES trips(trip_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- SHIFTS TABLE (References SHUTTLES and DRIVERS)
CREATE TABLE shifts (
    shift_id VARCHAR2(50) PRIMARY KEY,
    shuttle_id VARCHAR2(50),
    driver_id VARCHAR2(50),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    FOREIGN KEY (shuttle_id) REFERENCES shuttles(shuttle_id) ON DELETE CASCADE, -- Deleting a shuttle deletes associated shifts
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id) ON DELETE SET NULL -- Removing a driver nullifies the shift reference
);


-- MAINTENANCE SCHEDULES TABLE (References SHUTTLES)
CREATE TABLE maintenance_schedules (
    maintenance_id VARCHAR2(50) PRIMARY KEY,
    shuttle_id VARCHAR2(50),
    last_maintenance_mileage NUMBER,
    maintenance_date DATE,
    description VARCHAR2(255),
    FOREIGN KEY (shuttle_id) REFERENCES shuttles(shuttle_id) ON DELETE CASCADE
);


-- SHUTTLE MILEAGE RECORDS TABLE (References SHUTTLES)
CREATE TABLE shuttle_mileage_records (
    record_id VARCHAR2(50) PRIMARY KEY,
    shuttle_id VARCHAR2(50),
    trip_id VARCHAR2(50),
    mileage_added NUMBER,
    updated_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_shuttle_id FOREIGN KEY (shuttle_id) REFERENCES shuttles(shuttle_id),
    CONSTRAINT fk_trip_id FOREIGN KEY (trip_id) REFERENCES trips(trip_id)
);
