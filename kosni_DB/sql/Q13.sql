SELECT
    a.Artist_ID,
    a.Stage_Name,
    COUNT(DISTINCT loc.Continent) AS DistinctContinents
FROM
    Artist a
JOIN
    Performance p ON a.Artist_ID = p.Artist_ID -- Link artist to their performances
JOIN
    Event e ON p.Event_ID = e.Event_ID         -- Link performance to the event
JOIN
    Festival f ON e.Festival_ID = f.Festival_ID -- Link event to the festival
JOIN
    Location loc ON f.Location_ID = loc.Location_ID -- Link festival to its location to get the continent
WHERE
    p.Artist_ID IS NOT NULL -- Ensure we are considering solo artist performances
    AND loc.Continent IS NOT NULL AND loc.Continent != '' -- Ensure continent data is valid
GROUP BY
    a.Artist_ID, a.Stage_Name                 -- Group by each artist
HAVING
    COUNT(DISTINCT loc.Continent) >= 3     -- Filter for artists who have performed on at least 3 distinct continents
ORDER BY
    DistinctContinents DESC,                 -- Optional: Order by the number of continents
    a.Stage_Name ASC;