WITH GenreYearlyPerformanceCounts AS (
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
        p.Artist_ID IS NOT NULL
    GROUP BY
        ag.Genre_ID, mg.Name, YEAR(p.Start_Time)
    
    HAVING
        COUNT(p.Performance_ID) >= 3
)
SELECT
    gypc1.GenreName,
    gypc1.PerformanceYear AS Year1,
    gypc2.PerformanceYear AS Year2,
    gypc1.PerformanceCount 
FROM
    GenreYearlyPerformanceCounts gypc1
JOIN
    GenreYearlyPerformanceCounts gypc2
    ON gypc1.Genre_ID = gypc2.Genre_ID                     
    AND gypc1.PerformanceYear = gypc2.PerformanceYear - 1  
    AND gypc1.PerformanceCount = gypc2.PerformanceCount     
ORDER BY
    gypc1.GenreName,
    Year1;