-- Users
INSERT INTO users (user_id, name, email, phone, is_active) VALUES ('U1', 'John Doe', 'john@example.com', '1234567890', 1);
INSERT INTO users (user_id, name, email, phone, is_active) VALUES ('U2', 'Jane Smith', 'jane@example.com', '0987654321', 1);
INSERT INTO users (user_id, name, email, phone, is_active) VALUES ('U3', 'Alice Brown', 'alice@example.com', '5551234567', 1);
INSERT INTO users (user_id, name, email, phone, is_active) VALUES ('U4', 'Bob White', 'bob@example.com', '4449876543', 1);
INSERT INTO users (user_id, name, email, phone, is_active) VALUES ('U5', 'Chris Green', 'chris@example.com', '3335558888', 1);
INSERT INTO users (user_id, name, email, phone, is_active) VALUES ('U6', 'David Black', 'david@example.com', '2223334444', 1);
INSERT INTO users (user_id, name, email, phone, is_active) VALUES ('U7', 'Emma White', 'emma@example.com', '1112223333', 1);
INSERT INTO users (user_id, name, email, phone, is_active) VALUES ('U8', 'Frank Blue', 'frank@example.com', '6667778888', 1);
INSERT INTO users (user_id, name, email, phone, is_active) VALUES ('U9', 'Grace Yellow', 'grace@example.com', '9998887777', 1);
INSERT INTO users (user_id, name, email, phone, is_active) VALUES ('U10', 'Hannah Red', 'hannah@example.com', '5556667777', 1);
COMMIT;

-- Roles
INSERT INTO roles VALUES ('R1', 'Manager');
INSERT INTO roles VALUES ('R2', 'Driver');
INSERT INTO roles VALUES ('R3', 'Analyst');
INSERT INTO roles VALUES ('R4', 'Rider');
COMMIT;

-- Insert data into User Roles
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR1', 'R4', 'U1');
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR2', 'R4', 'U2');
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR3', 'R4', 'U3');
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR4', 'R4', 'U4');
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR5', 'R4', 'U5');
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR6', 'R2', 'U6');
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR7', 'R2', 'U7');
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR8', 'R2', 'U8');
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR9', 'R2', 'U9');
INSERT INTO user_roles (user_role_id, role_id, user_id) 
VALUES ('UR10', 'R2', 'U10');
COMMIT;

-- Permissions
INSERT INTO permissions VALUES ('P1', 'R1', 'Can manage users');
INSERT INTO permissions VALUES ('P2', 'R2', 'Can drive shuttle');
INSERT INTO permissions VALUES ('P3', 'R3', 'Can check reports');
INSERT INTO permissions VALUES ('P4', 'R4', 'Can take rides');
COMMIT;

-- Locations
INSERT INTO locations VALUES ('L1', 'Main Campus', '123 Main St', 1);
INSERT INTO locations VALUES ('L2', 'North Campus', '456 North St', 1);
INSERT INTO locations VALUES ('L3', 'South Campus', '789 South St', 1);
INSERT INTO locations VALUES ('L4', 'East Campus', '101 East St', 1);
INSERT INTO locations VALUES ('L5', 'West Campus', '202 West St', 1);
INSERT INTO locations VALUES ('L6', 'Snell', '341 Huntington Ave', 1);
COMMIT;


-- Third Party Services
INSERT INTO third_party_services VALUES ('TPS1', 'Transport Co', 'contact@transportco.com');
INSERT INTO third_party_services VALUES ('TPS2', 'City Shuttle Services', 'info@cityshuttle.com');
INSERT INTO third_party_services VALUES ('TPS3', 'Green Rides', 'support@greenrides.com');
INSERT INTO third_party_services VALUES ('TPS4', 'Urban Transit', 'hello@urbantransit.com');
INSERT INTO third_party_services VALUES ('TPS5', 'Eco Transport', 'contact@ecotransport.com');
COMMIT;

-- Insert data into Drivers (referencing user_roles)
INSERT INTO drivers (driver_id, user_role_id, license_number, tp_id) 
VALUES ('D1', 'UR6', 'LIC123', 'TPS1');
INSERT INTO drivers (driver_id, user_role_id, license_number, tp_id) 
VALUES ('D2', 'UR7', 'LIC456', 'TPS2');
INSERT INTO drivers (driver_id, user_role_id, license_number, tp_id) 
VALUES ('D3', 'UR8', 'LIC789', 'TPS3');
INSERT INTO drivers (driver_id, user_role_id, license_number, tp_id) 
VALUES ('D4', 'UR9', 'LIC012', 'TPS4');
INSERT INTO drivers (driver_id, user_role_id, license_number, tp_id) 
VALUES ('D5', 'UR10', 'LIC345', 'TPS5');
COMMIT;
