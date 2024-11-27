CREATE OR REPLACE PACKAGE Shuttle_Management_Pkg AS
    -- Procedure to generate shuttle utilization report
    PROCEDURE Generate_Shuttle_Utilization_Report;

    -- Procedure to generate driver shift schedule
    PROCEDURE Generate_Driver_Shift_Schedule;

    -- Procedure to manage ride notifications
    PROCEDURE Manage_Ride_Notifications;

    -- Procedure to check vehicle maintenance status
    PROCEDURE Check_Maintenance_Status;

    -- Function to calculate average trip time for a route
    FUNCTION Calculate_Average_Trip_Time(pickup_location_id IN VARCHAR2, dropoff_location_id IN VARCHAR2) RETURN NUMBER;

    -- Procedure to flag underutilized routes
    PROCEDURE Flag_Underutilized_Routes(threshold IN NUMBER);
END Shuttle_Management_Pkg;
/
