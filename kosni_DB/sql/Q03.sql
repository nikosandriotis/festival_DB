SELECT 
    a.Artist_ID,
    a.Stage_Name,
    f.Year,
    COUNT(*) AS Warmup_Count
FROM Performance p
JOIN Artist a ON p.Artist_ID = a.Artist_ID
JOIN Event e ON p.Event_ID = e.Event_ID
JOIN Festival f ON e.Festival_ID = f.Festival_ID
WHERE p.Type = 'warm up'
GROUP BY a.Artist_ID, f.Year
HAVING COUNT(*) > 2;