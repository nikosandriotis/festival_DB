SELECT 
    a.Artist_ID,
    a.Stage_Name,
    ROUND(AVG(e.Artist_Performance), 2) AS Avg_Artist_Performance,
    ROUND(AVG(e.Overall_Impression), 2) AS Avg_Overall_Impression
FROM Artist a
JOIN Performance p ON a.Artist_ID = p.Artist_ID
JOIN Evaluation e ON p.Performance_ID = e.Performance_ID
WHERE a.Stage_Name = 'Lady Gaga'
GROUP BY a.Artist_ID, a.Stage_Name
ORDER BY Avg_Artist_Performance DESC;