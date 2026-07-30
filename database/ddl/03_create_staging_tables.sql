USE SalesAnalyticsDB;
GO

IF NOT EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'staging.Sales_Raw') 
AND type in (N'U'))
BEGIN
CREATE TABLE staging.Sales_Raw (
    DATE_TIME_IDDOC_x36 NVARCHAR(MAX), 
    SalesDocument_Unique_IDx36 NVARCHAR(MAX),
    SalesDocument_Number NVARCHAR(MAX), 
    SalesDocument_LineNo NVARCHAR(MAX),
    SalesDocument_Date NVARCHAR(MAX), 
    SalesManager_Login_IDx36 NVARCHAR(MAX),
    SalesManager_Login NVARCHAR(MAX), 
    SalesManager_IDx36 NVARCHAR(MAX),
    SalesManager_Code NVARCHAR(MAX), 
    SalesManager_Name NVARCHAR(MAX),
    SalesDate_Hour NVARCHAR(MAX), 
    SalesDate_WeekDay NVARCHAR(MAX),
    SalesDate_WeekNum NVARCHAR(MAX), 
    SalesDate_WeekStart NVARCHAR(MAX),
    SalesDate_WeekEnd NVARCHAR(MAX), 
    SalesDate_MonthNum NVARCHAR(MAX),
    SalesDate_MonthDayNum NVARCHAR(MAX), 
    Customer_Code NVARCHAR(MAX),
    Customer_Name NVARCHAR(MAX), 
    DiscountCardNo NVARCHAR(MAX),
    BarCode_EAN13 NVARCHAR(MAX), 
    Prod_Unique_IDx36 NVARCHAR(MAX),
    Prod_Code NVARCHAR(MAX), 
    Prod_Name NVARCHAR(MAX),
    Prod_FullName NVARCHAR(MAX), 
    ProdParent1_Code NVARCHAR(MAX),
    ProdParent1_Name NVARCHAR(MAX),
    ProdParent0_Code NVARCHAR(MAX),
    ProdParent0_Name NVARCHAR(MAX), 
    WH_Code NVARCHAR(MAX), 
    WH_Name NVARCHAR(MAX),
    Quantity NVARCHAR(MAX), 
    Price NVARCHAR(MAX), 
    TotalAmount NVARCHAR(MAX),
    VATamount NVARCHAR(MAX), 
    VAT NVARCHAR(MAX),
    checksum_TotalAmount NVARCHAR(MAX),
    checksum_VATAmount NVARCHAR(MAX), 
    UnitMeasure_Koef NVARCHAR(MAX),
    _Weight NVARCHAR(MAX), 
    _Volume NVARCHAR(MAX), 
    UnitMeasure_Code NVARCHAR(MAX),
    UnitMeasure_Name NVARCHAR(MAX), 
    SourceFileName NVARCHAR(255)
);
END;
GO

IF NOT EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'staging.ErrorLog') 
AND type in (N'U'))
BEGIN
CREATE TABLE staging.ErrorLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    ErrorTime DATETIME2 DEFAULT GETDATE(),
    ErrorReason NVARCHAR(500),
    DocID NVARCHAR(100),
    DocLineNo NVARCHAR(50),
    RawData NVARCHAR(MAX)
);
END;
GO