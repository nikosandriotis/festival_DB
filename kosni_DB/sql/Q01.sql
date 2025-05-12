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