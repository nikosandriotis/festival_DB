WITH VisitorYearlyEventAttendance AS (
    SELECT
        t.Visitor_ID,
        YEAR(e.Start_Time) AS AttendanceYear,
        COUNT(DISTINCT p.Event_ID) AS EventAttendanceCount
    FROM
        Ticket t
    JOIN
        Performance p ON t.Performance_ID = p.Performance_ID
    JOIN
        Event e ON p.Event_ID = e.Event_ID 
    GROUP BY
        t.Visitor_ID,
        YEAR(e.Start_Time)
    HAVING
        COUNT(DISTINCT p.Event_ID) > 3
),
RankedEventAttendance AS (
    SELECT
        Visitor_ID,
        AttendanceYear,
        EventAttendanceCount,
        COUNT(*) OVER (PARTITION BY AttendanceYear, EventAttendanceCount) AS GroupSize
    FROM
        VisitorYearlyEventAttendance
)
SELECT
    CONCAT(v.First_Name, ' ', v.Last_Name) AS VisitorName,
    rea.AttendanceYear,
    rea.EventAttendanceCount 
FROM
    RankedEventAttendance rea
JOIN
    Visitor v ON rea.Visitor_ID = v.Visitor_ID
WHERE
    rea.GroupSize > 1 
ORDER BY
    rea.AttendanceYear, 
    rea.EventAttendanceCount, 
    VisitorName;      
