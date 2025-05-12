SELECT
    mg1.Name AS Genre1, -- Name of the first genre in the pair
    mg2.Name AS Genre2, -- Name of the second genre in the pair
    COUNT(DISTINCT ag1.Artist_ID) AS PairCount -- Count of distinct artists sharing this pair
FROM
    ArtistGenre ag1 -- Start with artist-genre links
INNER JOIN -- Join to itself to find pairs for the same artist
    ArtistGenre ag2 ON ag1.Artist_ID = ag2.Artist_ID AND ag1.Genre_ID < ag2.Genre_ID
    -- ^ Ensures pairs like (Rock, Pop) are counted, but not (Pop, Rock) or (Rock, Rock)
INNER JOIN -- Get the name for the first genre ID
    MusicGenre mg1 ON ag1.Genre_ID = mg1.Genre_ID
INNER JOIN -- Get the name for the second genre ID
    MusicGenre mg2 ON ag2.Genre_ID = mg2.Genre_ID
WHERE
    -- Ensure the artist has actually performed (exists in Performance table with Artist_ID)
    EXISTS (SELECT 1 FROM Performance p WHERE p.Artist_ID = ag1.Artist_ID)
GROUP BY
    mg1.Genre_ID, mg2.Genre_ID, Genre1, Genre2 -- Group by the specific pair of genres
ORDER BY
    PairCount DESC -- Order to find the most common pairs first
LIMIT 3; -- Return only the top 3