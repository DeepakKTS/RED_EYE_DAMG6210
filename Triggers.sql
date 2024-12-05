//TRIGGERS
/*This trigger enforces validation of the LICENSE_NUMBER field in the drivers table, ensuring it is mandatory and at least 9 characters long before insert or update operations.*/
CREATE OR REPLACE TRIGGER enforce_driver_background_check_trg
BEFORE INSERT OR UPDATE OF LICENSE_NUMBER ON drivers
FOR EACH ROW
BEGIN
    -- Check if the license number is NULL
    IF :NEW.LICENSE_NUMBER IS NULL THEN
        -- Log an error message for missing license number
        DBMS_OUTPUT.PUT_LINE('License number is mandatory.');
    ELSIF LENGTH(:NEW.LICENSE_NUMBER) < 9 THEN
        -- Log an error message for invalid license number
        DBMS_OUTPUT.PUT_LINE('Invalid license number. Must be at least 9 characters.');
    END IF;
END enforce_driver_background_check_trg;
/