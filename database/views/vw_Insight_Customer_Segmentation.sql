USE SalesAnalyticsDB;
GO

CREATE OR ALTER VIEW view_bi.vw_Insight_Customer_Segmentation AS
SELECT 
    c.CustomerCode AS CodClient, c.CustomerName AS NumeClient, COUNT(DISTINCT f.SalesDocumentNumber) AS TotalTranzactii, SUM(f.TotalAmount) AS RulajTotalFiniciar,
    CASE
        WHEN SUM(f.TotalAmount) > 20000 THEN 'Tier 1 - VIP (High Value)' WHEN SUM(f.TotalAmount) BETWEEN 5000 AND 20000 THEN 'Tier 2 - Premium'
        WHEN SUM(f.TotalAmount) > 0 THEN 'Tier 3 - Standard' ELSE 'Inactiv / Retur'
    END AS SegmentClient
FROM fact.SalesLine f
JOIN dimension.Customer c ON f.CustomerKey = c.CustomerKey
GROUP BY c.CustomerCode, c.CustomerName;
GO

EXEC staging.usp_ProcessAndLoadData;
GO