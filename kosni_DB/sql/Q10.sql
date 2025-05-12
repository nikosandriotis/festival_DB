SELECT
    mg1.Name AS Genre1, 
    mg2.Name AS Genre2, 
    COUNT(DISTINCT ag1.Artist_ID) AS PairCount 
FROM
    ArtistGenre ag1 
INNER JOIN 
    ArtistGenre ag2 ON ag1.Artist_ID = ag2.Artist_ID AND ag1.Genre_ID < ag2.Genre_ID
    
INNER JOIN 
    MusicGenre mg1 ON ag1.Genre_ID = mg1.Genre_ID
INNER JOIN
    MusicGenre mg2 ON ag2.Genre_ID = mg2.Genre_ID
WHERE
    EXISTS (SELECT 1 FROM Performance p WHERE p.Artist_ID = ag1.Artist_ID)
GROUP BY
    mg1.Genre_ID, mg2.Genre_ID, Genre1, Genre2 
ORDER BY
    PairCount DESC
LIMIT 3;