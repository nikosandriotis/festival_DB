SELECT 
    a.Artist_ID,
    a.Stage_Name,
    TIMESTAMPDIFF(YEAR, a.Birthdate, CURDATE()) AS Age,
    COUNT(DISTINCT f.Festival_ID) AS Festival_Count
FROM Artist a
JOIN Performance p ON a.Artist_ID = p.Artist_ID
JOIN Event e ON p.Event_ID = e.Event_ID
JOIN Festival f ON e.Festival_ID = f.Festival_ID
WHERE TIMESTAMPDIFF(YEAR, a.Birthdate, CURDATE()) < 30
GROUP BY a.Artist_ID
ORDER BY Festival_Count DESC
LIMIT 10;