SELECT
    s.Staff_ID,
    s.Name,
    s.Role,
    s.Experience_Level
FROM
    Staff s
WHERE NOT EXISTS (
    SELECT 1 
    FROM
        StaffAssignment sa
    JOIN
        Event e ON sa.Event_ID = e.Event_ID
    WHERE
        sa.Staff_ID = s.Staff_ID 
        AND '2022-10-10' BETWEEN DATE(e.Start_Time) AND DATE(e.End_Time)
)
AND s.Role = 'Auxiliary';