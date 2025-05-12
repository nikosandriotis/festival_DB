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