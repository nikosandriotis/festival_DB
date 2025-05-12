WITH ArtistPerformanceCounts AS (
    SELECT
        p.Artist_ID,
        COUNT(p.Performance_ID) AS AppearanceCount
    FROM
        Performance p
    WHERE
        p.Artist_ID IS NOT NULL 
    GROUP BY
        p.Artist_ID
),
MaxAppearances AS (
    SELECT MAX(AppearanceCount) AS MaxCount
    FROM ArtistPerformanceCounts
)
SELECT
    a.Artist_ID,
    a.Stage_Name, 
    apc.AppearanceCount
FROM
    ArtistPerformanceCounts apc
JOIN
    Artist a ON apc.Artist_ID = a.Artist_ID 
CROSS JOIN 
    MaxAppearances ma
WHERE
    apc.AppearanceCount <= (ma.MaxCount - 5) 
ORDER BY
    apc.AppearanceCount ASC; 