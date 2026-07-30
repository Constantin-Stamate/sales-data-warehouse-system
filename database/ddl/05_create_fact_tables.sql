USE SalesAnalyticsDB;
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'fact.SalesLine') AND type in (N'U'))
BEGIN
    CREATE TABLE fact.SalesLine (
        DateKey INT NOT NULL, 
        ProductKey INT NOT NULL, 
        CustomerKey INT NOT NULL,
        ManagerKey INT NOT NULL, 
        WarehouseKey INT NOT NULL,
        DateTime_IDDoc_x36 NVARCHAR(100) NULL, 
        SalesDocumentID_x36 NVARCHAR(50) NOT NULL, 
        SalesDocumentLineNo INT NOT NULL, 
        SalesDocumentNumber NVARCHAR(50) NOT NULL, 
        SalesHour TINYINT NULL,
        Quantity DECIMAL(18,4) NOT NULL, 
        Price DECIMAL(18,4) NOT NULL, 
        TotalAmount DECIMAL(18,4) NOT NULL, 
        VATRate DECIMAL(5,2) NULL, 
        VATAmount DECIMAL(18,4) NULL,
        Checksum_TotalAmount DECIMAL(18,4) NULL, 
        Checksum_VATAmount DECIMAL(18,4) NULL,
        ETL_LoadDate DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT PK_FactSales PRIMARY KEY (SalesDocumentID_x36, SalesDocumentLineNo),
        CONSTRAINT FK_Sales_Date FOREIGN KEY (DateKey) REFERENCES dimension.[Date](DateKey),
        CONSTRAINT FK_Sales_Product FOREIGN KEY (ProductKey) REFERENCES dimension.Product(ProductKey),
        CONSTRAINT FK_Sales_Customer FOREIGN KEY (CustomerKey) REFERENCES dimension.Customer(CustomerKey),
        CONSTRAINT FK_Sales_Manager FOREIGN KEY (ManagerKey) REFERENCES dimension.SalesManager(ManagerKey),
        CONSTRAINT FK_Sales_Warehouse FOREIGN KEY (WarehouseKey) REFERENCES dimension.Warehouse(WarehouseKey)
    );
   
    CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_FactSales ON fact.SalesLine 
    (DateKey, ProductKey, CustomerKey, ManagerKey, WarehouseKey, Quantity, Price, TotalAmount);
END;
GO