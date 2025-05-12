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
WHERE v.First_Name = 'Mary' AND v.Last_Name = 'Choi'
GROUP BY v.First_Name, v.Last_Name, p.Performance_ID, a.Stage_Name, p.Type, p.Start_Time
ORDER BY p.Start_Time;