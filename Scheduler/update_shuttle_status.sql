-- ****
-- DO NOT EXECUTE THIS
-- ****


SET SERVEROUTPUT ON;

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'UPDATE_TRIP_STATUS_JOB',
    job_type        => 'STORED_PROCEDURE',
    job_action      => 'ride_management_pkg.update_trip_status', 
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=SECONDLY;INTERVAL=10',
    enabled         => TRUE,
    comments        => 'Job to update trip and ride statuses every 10 seconds'
  );
END;
/
BEGIN
  DBMS_SCHEDULER.DROP_JOB (
    job_name => 'UPDATE_TRIP_STATUS_JOB',
    force    => TRUE
  );
END;
/
