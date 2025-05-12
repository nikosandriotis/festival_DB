WITH GenreYearlyPerformanceCounts AS (
    -- Step 1: Count performances for each genre in each year
    SELECT
        ag.Genre_ID,
        mg.Name AS GenreName,
        YEAR(p.Start_Time) AS PerformanceYear,
        COUNT(p.Performance_ID) AS PerformanceCount
    FROM
        Performance p
    JOIN
        ArtistGenre ag ON p.Artist_ID = ag.Artist_ID
    JOIN
        MusicGenre mg ON ag.Genre_ID = mg.Genre_ID
    WHERE
        p.Artist_ID IS NOT NULL -- Focus on solo artist performances for clear genre attribution
    GROUP BY
        ag.Genre_ID, mg.Name, YEAR(p.Start_Time)
    -- Step 2: Filter for genres/years with at least 3 performances
    HAVING
        COUNT(p.Performance_ID) >= 3
)
-- Step 3: Find genres with the same performance count in two consecutive years
SELECT
    gypc1.GenreName,
    gypc1.PerformanceYear AS Year1,
    gypc2.PerformanceYear AS Year2,
    gypc1.PerformanceCount -- This count is the same for both years
FROM
    GenreYearlyPerformanceCounts gypc1
JOIN
    GenreYearlyPerformanceCounts gypc2
    ON gypc1.Genre_ID = gypc2.Genre_ID                      -- Must be the same genre
    AND gypc1.PerformanceYear = gypc2.PerformanceYear - 1   -- Years must be consecutive (gypc1 is the earlier year)
    AND gypc1.PerformanceCount = gypc2.PerformanceCount     -- Performance counts must be the same
ORDER BY
    gypc1.GenreName,
    Year1;