-- 1
SELECT 
    f.Year,
    t.Payment_Method,
    SUM(t.Cost) AS Total_Revenue
FROM Ticket t
JOIN Performance p ON t.Performance_ID = p.Performance_ID
JOIN Event e ON p.Event_ID = e.Event_ID
JOIN Festival f ON e.Festival_ID = f.Festival_ID
GROUP BY f.Year, t.Payment_Method
ORDER BY f.Year, t.Payment_Method;

-- 2
SELECT 
    a.Artist_ID,
    a.Stage_Name,
    g.Name AS Genre_Name,
    f.Year AS Participated_Year
FROM Artist a
JOIN ArtistGenre ag ON a.Artist_ID = ag.Artist_ID
JOIN MusicGenre g ON ag.Genre_ID = g.Genre_ID
LEFT JOIN Performance p ON a.Artist_ID = p.Artist_ID
LEFT JOIN Event e ON p.Event_ID = e.Event_ID
LEFT JOIN Festival f ON e.Festival_ID = f.Festival_ID
WHERE g.Name = 'Rock'
GROUP BY a.Artist_ID, f.Year;

-- 3
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

-- 4
SELECT 
    a.Artist_ID,
    a.Stage_Name,
    ROUND(AVG(e.Artist_Performance), 2) AS Avg_Artist_Performance,
    ROUND(AVG(e.Overall_Impression), 2) AS Avg_Overall_Impression
FROM Artist a
JOIN Performance p ON a.Artist_ID = p.Artist_ID
JOIN Evaluation e ON p.Performance_ID = e.Performance_ID
GROUP BY a.Artist_ID, a.Stage_Name
ORDER BY Avg_Artist_Performance DESC;

-- 5
SELECT 
    a.Artist_ID,
    a.Stage_Name,
    TIMESTAMPDIFF(YEAR, a.Birthdate, CURDATE()) AS Age,
    COUNT(DISTINCT f.Festival_ID) AS Festival_Count
FROM Artist a
JOIN Performance p ON a.Artist_ID = p.Artist_ID
JOIN Event e ON p.Event_ID = e.Event_ID
JOIN Festival f ON e.Festival_ID = f.Festival_ID
WHERE TIMESTAMPDIFF(YEAR, a.Birthdate, CURDATE()) < 30
GROUP BY a.Artist_ID
ORDER BY Festival_Count DESC
LIMIT 10;

-- 6
SELECT 
    v.First_Name,
    v.Last_Name,
    p.Performance_ID,
    p.Type,
    p.Start_Time,
    a.Stage_Name AS Artist_Name,
    ROUND(AVG(
        (e.Artist_Performance + e.Sound_Lighting + e.Stage_Presence + e.Organization + e.Overall_Impression) / 5
    ), 2) AS Avg_Rating
FROM Visitor v
JOIN Evaluation e ON v.Visitor_ID = e.Visitor_ID
JOIN Performance p ON e.Performance_ID = p.Performance_ID
JOIN Artist a ON p.Artist_ID = a.Artist_ID
WHERE v.First_Name = 'Mary' AND v.Last_Name = 'Choi'  -- ✅ Change to desired name
GROUP BY v.First_Name, v.Last_Name, p.Performance_ID, a.Stage_Name, p.Type, p.Start_Time
ORDER BY p.Start_Time;

-- 7
SELECT 
    F.Festival_ID,
    F.Year,
    AVG(
        CASE S.Experience_Level
            WHEN 'Intern' THEN 1
            WHEN 'Beginner' THEN 2
            WHEN 'Intermediate' THEN 3
            WHEN 'Experienced' THEN 4
            WHEN 'Expert' THEN 5
        END
    ) AS Avg_Experience_Score
FROM Festival F
JOIN Event E ON F.Festival_ID = E.Festival_ID
JOIN StaffAssignment SA ON E.Event_ID = SA.Event_ID
JOIN Staff S ON SA.Staff_ID = S.Staff_ID
WHERE S.Role = 'Technical'
GROUP BY F.Festival_ID, F.Year
ORDER BY Avg_Experience_Score ASC;
-- LIMIT 1;

-- 8
SELECT
    s.Staff_ID,
    s.Name,
    s.Role,
    s.Experience_Level
FROM
    Staff s
WHERE NOT EXISTS (
    -- Subquery to find if the staff member IS assigned to an event on the specific date
    SELECT 1 -- We only care about existence, so selecting 1 is efficient
    FROM
        StaffAssignment sa
    JOIN
        Event e ON sa.Event_ID = e.Event_ID
    WHERE
        sa.Staff_ID = s.Staff_ID -- Link to the staff member in the outer query
        -- Check if the specific date falls within the event's date range
        AND '2022-10-10' BETWEEN DATE(e.Start_Time) AND DATE(e.End_Time)
)
-- Add this condition to filter the *outer* query results
AND s.Role = 'Auxiliary';

-- 9
      
WITH VisitorYearlyEventAttendance AS (
    -- Step 1: Calculate distinct event attendances per visitor per year, filtering for > 3
    SELECT
        t.Visitor_ID,
        YEAR(e.Start_Time) AS AttendanceYear, -- Use Event Start_Time for the year
        COUNT(DISTINCT p.Event_ID) AS EventAttendanceCount -- Count DISTINCT events
    FROM
        Ticket t
    JOIN
        Performance p ON t.Performance_ID = p.Performance_ID
    JOIN
        Event e ON p.Event_ID = e.Event_ID -- Join to get the Event_ID and its Start_Time
    -- WHERE t.Activated = 1 -- Optional: Uncomment if "attended" strictly means the ticket was activated
    GROUP BY
        t.Visitor_ID,
        YEAR(e.Start_Time) -- Group by visitor and the year of the event
    HAVING
        COUNT(DISTINCT p.Event_ID) > 3 -- Filter for > 3 distinct events attended in that year
),
RankedEventAttendance AS (
    -- Step 2: For each visitor's yearly event count, find how many *other* visitors
    --         had the same count in the same year using a window function.
    SELECT
        Visitor_ID,
        AttendanceYear,
        EventAttendanceCount,
        COUNT(*) OVER (PARTITION BY AttendanceYear, EventAttendanceCount) AS GroupSize
        -- Counts rows within the partition defined by Year and Event Count
    FROM
        VisitorYearlyEventAttendance
)
-- Step 3: Select the visitors who belong to a group (GroupSize > 1)
--         and join to get their names.
SELECT
    CONCAT(v.First_Name, ' ', v.Last_Name) AS VisitorName,
    rea.AttendanceYear,
    rea.EventAttendanceCount -- This is the number of distinct events attended by this visitor in this year
FROM
    RankedEventAttendance rea
JOIN
    Visitor v ON rea.Visitor_ID = v.Visitor_ID
WHERE
    rea.GroupSize > 1 -- Filter to include only visitors who are part of a group (size > 1)
ORDER BY
    rea.AttendanceYear,  -- Group results visually
    rea.EventAttendanceCount, -- Group results visually
    VisitorName;        -- Alphabetical within the group

-- 10
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

-- 11
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

    
-- 12 
SELECT
    f.Year AS FestivalYear,             -- Year of the festival
    DATE(e.Start_Time) AS AssignmentDate, -- The specific date of the event assignment
    s.Role AS StaffCategory,            -- The role/category of the staff
    COUNT(DISTINCT sa.Staff_ID) AS RequiredStaffCount -- Count unique staff for that category on that day
FROM
    StaffAssignment sa
JOIN
    Staff s ON sa.Staff_ID = s.Staff_ID       -- Get staff details (specifically Role)
JOIN
    Event e ON sa.Event_ID = e.Event_ID       -- Get event details (Start_Time for date, Festival_ID)
JOIN
    Festival f ON e.Festival_ID = f.Festival_ID -- Get festival details (Year)
GROUP BY
    f.Year,                            -- Group by the festival year
    DATE(e.Start_Time),                -- Group by the specific date
    s.Role                             -- Group by the staff role/category
ORDER BY
    FestivalYear ASC,                  -- Sort results chronologically
    AssignmentDate ASC,                -- Sort by date within the year
    StaffCategory ASC;                 -- Sort by category within the date

-- 13
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
    
-- 15
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