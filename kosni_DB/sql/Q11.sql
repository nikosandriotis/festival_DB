WITH ArtistPerformanceCounts AS (
    -- Step 1: Count performances for each solo artist
    SELECT
        p.Artist_ID,
        COUNT(p.Performance_ID) AS AppearanceCount
    FROM
        Performance p
    WHERE
        p.Artist_ID IS NOT NULL -- Only count solo artist performances
    GROUP BY
        p.Artist_ID
),
MaxAppearances AS (
    -- Step 2: Find the single maximum appearance count
    SELECT MAX(AppearanceCount) AS MaxCount
    FROM ArtistPerformanceCounts
)
-- Step 3 & 4: Select artists whose count is <= (MaxCount - 5)
SELECT
    a.Artist_ID,
    a.Stage_Name, -- Or Real_Name, whichever you prefer
    apc.AppearanceCount
FROM
    ArtistPerformanceCounts apc
JOIN
    Artist a ON apc.Artist_ID = a.Artist_ID -- Join to get artist names
CROSS JOIN -- Allows comparing each artist count to the single max value
    MaxAppearances ma
WHERE
    apc.AppearanceCount <= (ma.MaxCount - 5) -- The core filter condition
ORDER BY
    apc.AppearanceCount ASC; -- Optional: Order by appearance count