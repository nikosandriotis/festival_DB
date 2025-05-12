SELECT
    s.Staff_ID,
    s.Name,
    s.Role,
    s.Experience_Level
FROM
    Staff s
WHERE NOT EXISTS (
    -- Subquery to find if the staff member IS assigned to an event on the specific date
    SELECT 1 -- We only care about existence, so selecting 1 is efficient
    FROM
        StaffAssignment sa
    JOIN
        Event e ON sa.Event_ID = e.Event_ID
    WHERE
        sa.Staff_ID = s.Staff_ID -- Link to the staff member in the outer query
        -- Check if the specific date falls within the event's date range
        AND '2022-10-10' BETWEEN DATE(e.Start_Time) AND DATE(e.End_Time)
)
-- Add this condition to filter the *outer* query results
AND s.Role = 'Auxiliary';