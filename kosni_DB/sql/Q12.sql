SELECT
    f.Year AS FestivalYear,             
    DATE(e.Start_Time) AS AssignmentDate, 
    s.Role AS StaffCategory,            
    COUNT(DISTINCT sa.Staff_ID) AS RequiredStaffCount 
FROM
    StaffAssignment sa
JOIN
    Staff s ON sa.Staff_ID = s.Staff_ID       
JOIN
    Event e ON sa.Event_ID = e.Event_ID       
JOIN
    Festival f ON e.Festival_ID = f.Festival_ID 
GROUP BY
    f.Year,                            
    DATE(e.Start_Time),                
    s.Role                             
ORDER BY
    FestivalYear ASC,                  
    AssignmentDate ASC,                
    StaffCategory ASC;                 