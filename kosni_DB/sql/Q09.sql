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
