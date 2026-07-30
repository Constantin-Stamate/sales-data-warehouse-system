USE SalesAnalyticsDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'staging') 
    EXEC('CREATE SCHEMA staging');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dimension') 
    EXEC('CREATE SCHEMA dimension');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'fact') 
    EXEC('CREATE SCHEMA fact');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'view_bi') 
    EXEC('CREATE SCHEMA view_bi');
GO