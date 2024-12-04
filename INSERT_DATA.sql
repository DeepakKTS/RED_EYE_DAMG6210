-- Roles
INSERT INTO roles VALUES ('R1', 'Manager');
INSERT INTO roles VALUES ('R2', 'Driver');
INSERT INTO roles VALUES ('R3', 'Analyst');
INSERT INTO roles VALUES ('R4', 'Rider');
COMMIT;

-- Permissions
INSERT INTO permissions VALUES ('P1', 'R1', 'Can manage users');
INSERT INTO permissions VALUES ('P2', 'R2', 'Can drive shuttle');
INSERT INTO permissions VALUES ('P3', 'R3', 'Can check reports');
INSERT INTO permissions VALUES ('P4', 'R4', 'Can take rides');
COMMIT;


-- Third Party Services
INSERT INTO third_party_services VALUES ('TPS1', 'Transport Co', 'contact@transportco.com');
INSERT INTO third_party_services VALUES ('TPS2', 'City Shuttle Services', 'info@cityshuttle.com');
INSERT INTO third_party_services VALUES ('TPS3', 'Green Rides', 'support@greenrides.com');
INSERT INTO third_party_services VALUES ('TPS4', 'Urban Transit', 'hello@urbantransit.com');
INSERT INTO third_party_services VALUES ('TPS5', 'Eco Transport', 'contact@ecotransport.com');
COMMIT;
