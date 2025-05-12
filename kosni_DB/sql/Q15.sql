SELECT
    CONCAT(v.First_Name, ' ', v.Last_Name) AS VisitorName,
    a.Stage_Name AS ArtistName,
    SUM(e.Overall_Impression) AS TotalOverallRatingToArtist
FROM
    Evaluation e
JOIN
    Visitor v ON e.Visitor_ID = v.Visitor_ID
JOIN
    Performance p ON e.Performance_ID = p.Performance_ID
JOIN
    Artist a ON p.Artist_ID = a.Artist_ID  -- Assuming evaluation is for a solo artist
WHERE
    p.Artist_ID IS NOT NULL -- Crucial: ensures we are linking to an Artist, not a Band, for the rating
GROUP BY
    v.Visitor_ID, a.Artist_ID, VisitorName, ArtistName -- Group by each unique visitor-artist pair
ORDER BY
    TotalOverallRatingToArtist DESC
LIMIT 5;