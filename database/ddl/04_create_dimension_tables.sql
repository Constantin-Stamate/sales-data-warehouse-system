USE SalesAnalyticsDB;
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dimension.Product') AND type in (N'U'))
BEGIN
    CREATE TABLE dimension.Product (
        ProductKey INT IDENTITY(1,1) PRIMARY KEY, ProductCode NVARCHAR(50) NOT NULL,
        ProductUniqueID_x36 NVARCHAR(50) NULL, ProductName NVARCHAR(255) NULL,
        ProductFullName NVARCHAR(500) NULL, CategoryLevel1Code NVARCHAR(50) NULL,
        CategoryLevel1Name NVARCHAR(200) NULL, CategoryLevel0Code NVARCHAR(50) NULL,
        CategoryLevel0Name NVARCHAR(200) NULL, BarCode_EAN13 NVARCHAR(50) NULL,
        UnitMeasureCode NVARCHAR(50) NULL, UnitMeasureName NVARCHAR(50) NULL,
        UnitMeasureKoef DECIMAL(10,4) NULL, Weight DECIMAL(10,4) NULL, Volume DECIMAL(10,4) NULL
    );
    CREATE NONCLUSTERED INDEX IX_DimProd_Code ON dimension.Product(ProductCode);
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dimension.Customer') AND type in (N'U'))
BEGIN
    CREATE TABLE dimension.Customer (
        CustomerKey INT IDENTITY(1,1) PRIMARY KEY, CustomerCode NVARCHAR(50) NOT NULL,
        CustomerName NVARCHAR(200) NULL, DiscountCardNo NVARCHAR(50) NULL
    );
    CREATE NONCLUSTERED INDEX IX_DimCust_Code ON dimension.Customer(CustomerCode);
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dimension.SalesManager') AND type in (N'U'))
BEGIN
    CREATE TABLE dimension.SalesManager (
        ManagerKey INT IDENTITY(1,1) PRIMARY KEY, ManagerCode NVARCHAR(50) NOT NULL,
        ManagerID_x36 NVARCHAR(100) NULL, ManagerName NVARCHAR(200) NULL,
        ManagerLogin NVARCHAR(100) NULL, ManagerLoginID_x36 NVARCHAR(100) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dimension.Warehouse') AND type in (N'U'))
BEGIN
    CREATE TABLE dimension.Warehouse (
        WarehouseKey INT IDENTITY(1,1) PRIMARY KEY, WarehouseCode NVARCHAR(50) NOT NULL,
        WarehouseName NVARCHAR(200) NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dimension.[Date]') AND type in (N'U'))
BEGIN
    CREATE TABLE dimension.[Date] (
        DateKey INT PRIMARY KEY, FullDate DATE NOT NULL, WeekDayNum INT NULL,
        WeekNum INT NULL, WeekStart DATE NULL, WeekEnd DATE NULL, MonthNum INT NULL, MonthDayNum INT NULL
    );
END;
GO