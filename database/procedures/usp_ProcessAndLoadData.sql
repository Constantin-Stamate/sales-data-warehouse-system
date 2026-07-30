USE SalesAnalyticsDB;
GO

CREATE OR ALTER PROCEDURE staging.usp_ProcessAndLoadData
AS
BEGIN
    SET NOCOUNT ON;

   -- Validarea datelor și identificarea erorilor
    INSERT INTO staging.ErrorLog (ErrorReason, DocID, DocLineNo, RawData)
    SELECT 
        CASE 
            WHEN SalesDocument_Unique_IDx36 IS NULL THEN 'Eroare: ID Document lipsa'
            WHEN TRY_CAST(SalesDocument_Date AS DATE) IS NULL THEN 'Eroare: Format data tranzactie invalid'
            WHEN TRY_CAST(SalesDocument_LineNo AS INT) IS NULL THEN 'Eroare: Numar linie document invalid'
            WHEN TRY_CAST(Quantity AS DECIMAL(18,4)) IS NULL OR TRY_CAST(Quantity AS DECIMAL(18,4)) <= 0 THEN 'Eroare Business: Cantitate zero sau negativa'
            WHEN TRY_CAST(Price AS DECIMAL(18,4)) IS NULL OR TRY_CAST(Price AS DECIMAL(18,4)) < 0 THEN 'Eroare Business: Pret negativ'
            WHEN TRY_CAST(TotalAmount AS DECIMAL(18,4)) IS NULL THEN 'Eroare Business: Valoare Totala invalida'
            WHEN NULLIF(LTRIM(RTRIM(Prod_Code)), '') IS NULL THEN 'Eroare Integritate: Cod Produs lipsa'
            WHEN NULLIF(LTRIM(RTRIM(Customer_Code)), '') IS NULL THEN 'Eroare Integritate: Cod Client lipsa'
            ELSE 'Eroare date corupte'
        END AS ErrorReason,
        SalesDocument_Unique_IDx36, SalesDocument_LineNo, 
        CONCAT('Date: ', SalesDocument_Date, ' | Prod: ', Prod_Code, ' | Qty: ', Quantity)
    FROM staging.Sales_Raw
    WHERE SalesDocument_Unique_IDx36 IS NULL 
       OR TRY_CAST(SalesDocument_Date AS DATE) IS NULL
       OR TRY_CAST(SalesDocument_LineNo AS INT) IS NULL
       OR TRY_CAST(Quantity AS DECIMAL(18,4)) IS NULL OR TRY_CAST(Quantity AS DECIMAL(18,4)) <= 0
       OR TRY_CAST(Price AS DECIMAL(18,4)) IS NULL OR TRY_CAST(Price AS DECIMAL(18,4)) < 0
       OR TRY_CAST(TotalAmount AS DECIMAL(18,4)) IS NULL
       OR NULLIF(LTRIM(RTRIM(Prod_Code)), '') IS NULL
       OR NULLIF(LTRIM(RTRIM(Customer_Code)), '') IS NULL;

    DELETE FROM staging.Sales_Raw
    WHERE SalesDocument_Unique_IDx36 IS NULL 
       OR TRY_CAST(SalesDocument_Date AS DATE) IS NULL
       OR TRY_CAST(SalesDocument_LineNo AS INT) IS NULL
       OR TRY_CAST(Quantity AS DECIMAL(18,4)) IS NULL OR TRY_CAST(Quantity AS DECIMAL(18,4)) <= 0
       OR TRY_CAST(Price AS DECIMAL(18,4)) IS NULL OR TRY_CAST(Price AS DECIMAL(18,4)) < 0
       OR TRY_CAST(TotalAmount AS DECIMAL(18,4)) IS NULL
       OR NULLIF(LTRIM(RTRIM(Prod_Code)), '') IS NULL
       OR NULLIF(LTRIM(RTRIM(Customer_Code)), '') IS NULL;

    -- Curățarea datelor
    UPDATE staging.Sales_Raw
    SET 
        Prod_Code = LTRIM(RTRIM(Prod_Code)), Customer_Code = LTRIM(RTRIM(Customer_Code)),
        SalesManager_Code = LTRIM(RTRIM(SalesManager_Code)), WH_Code = LTRIM(RTRIM(WH_Code)),
        Prod_Name = ISNULL(NULLIF(LTRIM(RTRIM(Prod_Name)), ''), 'Produs Necunoscut'),
        Prod_FullName = ISNULL(NULLIF(LTRIM(RTRIM(Prod_FullName)), ''), 'Nume Complet Necunoscut'),
        Customer_Name = ISNULL(NULLIF(LTRIM(RTRIM(Customer_Name)), ''), 'Client Anonim'),
        SalesManager_Name = ISNULL(NULLIF(LTRIM(RTRIM(SalesManager_Name)), ''), 'Casier Necunoscut'),
        WH_Name = ISNULL(NULLIF(LTRIM(RTRIM(WH_Name)), ''), 'Depozit Nespecificat'),
        VAT = REPLACE(ISNULL(VAT, '0'), '%', '');

    -- Populare dimensiuni noi
    WITH UniqueProducts AS (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY Prod_Code ORDER BY (SELECT NULL)) AS rn 
        FROM staging.Sales_Raw
    )
    INSERT INTO dimension.Product (ProductCode, ProductUniqueID_x36, ProductName, ProductFullName, CategoryLevel1Code, CategoryLevel1Name, CategoryLevel0Code, CategoryLevel0Name, BarCode_EAN13, UnitMeasureCode, UnitMeasureName, UnitMeasureKoef, Weight, Volume)
    SELECT Prod_Code, LTRIM(RTRIM(Prod_Unique_IDx36)), Prod_Name, Prod_FullName, ProdParent1_Code, ProdParent1_Name, ProdParent0_Code, ProdParent0_Name, BarCode_EAN13, UnitMeasure_Code, UnitMeasure_Name, TRY_CAST(UnitMeasure_Koef AS DECIMAL(10,4)), TRY_CAST(_Weight AS DECIMAL(10,4)), TRY_CAST(_Volume AS DECIMAL(10,4))
    FROM UniqueProducts WHERE rn = 1 AND Prod_Code NOT IN (SELECT ProductCode FROM dimension.Product);

    WITH UniqueCustomers AS (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY Customer_Code ORDER BY (SELECT NULL)) AS rn 
        FROM staging.Sales_Raw
    )
    INSERT INTO dimension.Customer (CustomerCode, CustomerName, DiscountCardNo)
    SELECT Customer_Code, Customer_Name, DiscountCardNo
    FROM UniqueCustomers WHERE rn = 1 AND Customer_Code NOT IN (SELECT CustomerCode FROM dimension.Customer);

    WITH UniqueManagers AS (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY SalesManager_Code ORDER BY (SELECT NULL)) AS rn 
        FROM staging.Sales_Raw
    )
    INSERT INTO dimension.SalesManager (ManagerCode, ManagerID_x36, ManagerName, ManagerLogin, ManagerLoginID_x36)
    SELECT SalesManager_Code, LTRIM(RTRIM(SalesManager_IDx36)), SalesManager_Name, SalesManager_Login, SalesManager_Login_IDx36
    FROM UniqueManagers WHERE rn = 1 AND SalesManager_Code NOT IN (SELECT ManagerCode FROM dimension.SalesManager);

    WITH UniqueWarehouses AS (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY WH_Code ORDER BY (SELECT NULL)) AS rn 
        FROM staging.Sales_Raw
    )
    INSERT INTO dimension.Warehouse (WarehouseCode, WarehouseName)
    SELECT WH_Code, WH_Name
    FROM UniqueWarehouses WHERE rn = 1 AND WH_Code NOT IN (SELECT w.WarehouseCode FROM dimension.Warehouse w);

    INSERT INTO dimension.[Date] (DateKey, FullDate, WeekDayNum, WeekNum, WeekStart, WeekEnd, MonthNum, MonthDayNum)
    SELECT DISTINCT 
        CONVERT(INT, FORMAT(TRY_CAST(SalesDocument_Date AS DATE), 'yyyyMMdd')),
        TRY_CAST(SalesDocument_Date AS DATE), TRY_CAST(SalesDate_WeekDay AS INT),
        TRY_CAST(SalesDate_WeekNum AS INT), TRY_CAST(SalesDate_WeekStart AS DATE),
        TRY_CAST(SalesDate_WeekEnd AS DATE), TRY_CAST(SalesDate_MonthNum AS INT),
        TRY_CAST(SalesDate_MonthDayNum AS INT)
    FROM staging.Sales_Raw
    WHERE CONVERT(INT, FORMAT(TRY_CAST(SalesDocument_Date AS DATE), 'yyyyMMdd')) NOT IN (SELECT DateKey FROM dimension.[Date]);

    -- Reduplicare forțată
    WITH SequencedStaging AS (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY LTRIM(RTRIM(SalesDocument_Unique_IDx36)), TRY_CAST(SalesDocument_LineNo AS INT) 
                   ORDER BY (SELECT NULL)
               ) AS Stg_Rn
        FROM staging.Sales_Raw
    ),
    CleansedFacts AS (
        SELECT 
            LTRIM(RTRIM(s.SalesDocument_Unique_IDx36)) AS DocID, 
            TRY_CAST(s.SalesDocument_LineNo AS INT) AS DocLineNo,
            s.DATE_TIME_IDDOC_x36 AS DateTimeDoc, s.SalesDocument_Number AS DocNum,
            TRY_CAST(s.SalesDate_Hour AS TINYINT) AS SalesHour,
            CONVERT(INT, FORMAT(TRY_CAST(s.SalesDocument_Date AS DATE), 'yyyyMMdd')) AS DateKey,
            
            p.ProductKey, c.CustomerKey, m.ManagerKey, w.WarehouseKey,
            
            TRY_CAST(s.Quantity AS DECIMAL(18,4)) AS Qty, TRY_CAST(s.Price AS DECIMAL(18,4)) AS UnitPrice,
            TRY_CAST(s.TotalAmount AS DECIMAL(18,4)) AS TotalAmt, TRY_CAST(s.VAT AS DECIMAL(5,2)) AS VATRate,
            TRY_CAST(s.VATamount AS DECIMAL(18,4)) AS VATAmt,
            TRY_CAST(s.checksum_TotalAmount AS DECIMAL(18,4)) AS ChkTotal, TRY_CAST(s.checksum_VATAmount AS DECIMAL(18,4)) AS ChkVAT
        FROM SequencedStaging s
        INNER JOIN (SELECT ProductCode, MAX(ProductKey) AS ProductKey FROM dimension.Product GROUP BY ProductCode) p ON s.Prod_Code = p.ProductCode
        INNER JOIN (SELECT CustomerCode, MAX(CustomerKey) AS CustomerKey FROM dimension.Customer GROUP BY CustomerCode) c ON s.Customer_Code = c.CustomerCode
        INNER JOIN (SELECT ManagerCode, MAX(ManagerKey) AS ManagerKey FROM dimension.SalesManager GROUP BY ManagerCode) m ON s.SalesManager_Code = m.ManagerCode
        INNER JOIN (SELECT WarehouseCode, MAX(WarehouseKey) AS WarehouseKey FROM dimension.Warehouse GROUP BY WarehouseCode) w ON s.WH_Code = w.WarehouseCode
        WHERE s.Stg_Rn = 1
    )
    MERGE INTO fact.SalesLine AS Target
    USING CleansedFacts AS Source
    ON Target.SalesDocumentID_x36 = Source.DocID AND Target.SalesDocumentLineNo = Source.DocLineNo

    WHEN MATCHED THEN 
        UPDATE SET 
            Target.DateTime_IDDoc_x36 = Source.DateTimeDoc,
            Target.Quantity = Source.Qty, Target.Price = Source.UnitPrice,
            Target.TotalAmount = Source.TotalAmt, Target.VATRate = Source.VATRate,
            Target.VATAmount = Source.VATAmt, Target.Checksum_TotalAmount = Source.ChkTotal,
            Target.Checksum_VATAmount = Source.ChkVAT, Target.ETL_LoadDate = GETDATE()

    WHEN NOT MATCHED BY TARGET THEN 
        INSERT (DateKey, ProductKey, CustomerKey, ManagerKey, WarehouseKey, 
                DateTime_IDDoc_x36, SalesDocumentID_x36, SalesDocumentLineNo, SalesDocumentNumber, SalesHour,
                Quantity, Price, TotalAmount, VATRate, VATAmount, Checksum_TotalAmount, Checksum_VATAmount)
        VALUES (Source.DateKey, Source.ProductKey, Source.CustomerKey, Source.ManagerKey, Source.WarehouseKey,
                Source.DateTimeDoc, Source.DocID, Source.DocLineNo, Source.DocNum, Source.SalesHour,
                Source.Qty, Source.UnitPrice, Source.TotalAmt, Source.VATRate, Source.VATAmt, Source.ChkTotal, Source.ChkVAT);

    TRUNCATE TABLE staging.Sales_Raw;
END;
GO