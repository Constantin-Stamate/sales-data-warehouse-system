USE SalesAnalyticsDB;
GO

CREATE OR ALTER VIEW view_bi.vw_Insight_Anomalies AS
SELECT 
    d.FullDate AS DataTranzactiei, f.SalesDocumentNumber AS Document, m.ManagerName AS Casier, p.ProductName AS Produs,
    f.Quantity AS Cantitate, f.Price AS PretUnitar, (f.Quantity * f.Price) AS TotalTeoretic, f.TotalAmount AS TotalIncasat,
    ABS((f.Quantity * f.Price) - f.TotalAmount) AS DiferentaValoare
FROM fact.SalesLine f
JOIN dimension.[Date] d ON f.DateKey = d.DateKey
JOIN dimension.Product p ON f.ProductKey = p.ProductKey
JOIN dimension.SalesManager m ON f.ManagerKey = m.ManagerKey
WHERE ABS((f.Quantity * f.Price) - f.TotalAmount) > 1;
GO