SELECT
    f.Year AS FestivalYear,             -- Year of the festival
    DATE(e.Start_Time) AS AssignmentDate, -- The specific date of the event assignment
    s.Role AS StaffCategory,            -- The role/category of the staff
    COUNT(DISTINCT sa.Staff_ID) AS RequiredStaffCount -- Count unique staff for that category on that day
FROM
    StaffAssignment sa
JOIN
    Staff s ON sa.Staff_ID = s.Staff_ID       -- Get staff details (specifically Role)
JOIN
    Event e ON sa.Event_ID = e.Event_ID       -- Get event details (Start_Time for date, Festival_ID)
JOIN
    Festival f ON e.Festival_ID = f.Festival_ID -- Get festival details (Year)
GROUP BY
    f.Year,                            -- Group by the festival year
    DATE(e.Start_Time),                -- Group by the specific date
    s.Role                             -- Group by the staff role/category
ORDER BY
    FestivalYear ASC,                  -- Sort results chronologically
    AssignmentDate ASC,                -- Sort by date within the year
    StaffCategory ASC;                 -- Sort by category within the date