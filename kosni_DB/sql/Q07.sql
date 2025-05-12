SELECT 
    F.Festival_ID,
    F.Year,
    AVG(
        CASE S.Experience_Level
            WHEN 'Intern' THEN 1
            WHEN 'Beginner' THEN 2
            WHEN 'Intermediate' THEN 3
            WHEN 'Experienced' THEN 4
            WHEN 'Expert' THEN 5
        END
    ) AS Avg_Experience_Score
FROM Festival F
JOIN Event E ON F.Festival_ID = E.Festival_ID
JOIN StaffAssignment SA ON E.Event_ID = SA.Event_ID
JOIN Staff S ON SA.Staff_ID = S.Staff_ID
WHERE S.Role = 'Technical'
GROUP BY F.Festival_ID, F.Year
ORDER BY Avg_Experience_Score ASC
LIMIT 1;

