SELECT
    a.Artist_ID,
    a.Stage_Name,
    COUNT(DISTINCT loc.Continent) AS DistinctContinents
FROM
    Artist a
JOIN
    Performance p ON a.Artist_ID = p.Artist_ID 
JOIN
    Event e ON p.Event_ID = e.Event_ID         
JOIN
    Festival f ON e.Festival_ID = f.Festival_ID
JOIN
    Location loc ON f.Location_ID = loc.Location_ID 
WHERE
    p.Artist_ID IS NOT NULL 
    AND loc.Continent IS NOT NULL AND loc.Continent != '' 
GROUP BY
    a.Artist_ID, a.Stage_Name                 
HAVING
    COUNT(DISTINCT loc.Continent) >= 3     
ORDER BY
    DistinctContinents DESC,                 
    a.Stage_Name ASC;