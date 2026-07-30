USE SalesAnalyticsDB;
GO

CREATE OR ALTER VIEW view_bi.vw_Master_Sales_Enriched AS
SELECT 
    d.FullDate AS DataVanzare, d.MonthNum AS Luna, d.WeekNum AS Saptamana,
    CASE WHEN d.WeekDayNum IN (6, 7) THEN 'Weekend' ELSE 'Zi Lucratoare' END AS TipZi, f.SalesDocumentNumber AS NumarDocument,
    f.SalesHour AS OraVanzarii,
    CASE 
        WHEN f.SalesHour BETWEEN 6 AND 11 THEN 'Dimineata' WHEN f.SalesHour BETWEEN 12 AND 17 THEN 'Dupa-amiaza'
        WHEN f.SalesHour BETWEEN 18 AND 23 THEN 'Seara' ELSE 'Noapte'
    END AS PerioadaZilei,
    p.ProductCode AS CodProdus, p.ProductName AS NumeProdus, p.CategoryLevel1Name AS Categorie, p.CategoryLevel0Name AS Subcategorie,
    c.CustomerName AS NumeClient, CASE WHEN c.DiscountCardNo IS NOT NULL AND LTRIM(RTRIM(c.DiscountCardNo)) <> '' THEN 'Client Fidelizat' ELSE 'Client Standard' END AS TipClient,
    m.ManagerName AS Casier, w.WarehouseName AS Depozit, f.Quantity AS Cantitate, f.Price AS PretUnitar, f.TotalAmount AS ValoareBruta, f.VATAmount AS ValoareTVA,
    (f.TotalAmount - ISNULL(f.VATAmount, 0)) AS ValoareNeta
FROM fact.SalesLine f
JOIN dimension.[Date] d ON f.DateKey = d.DateKey
JOIN dimension.Product p ON f.ProductKey = p.ProductKey
JOIN dimension.Customer c ON f.CustomerKey = c.CustomerKey
JOIN dimension.SalesManager m ON f.ManagerKey = m.ManagerKey
JOIN dimension.Warehouse w ON f.WarehouseKey = w.WarehouseKey;
GO