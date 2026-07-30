IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'SalesAnalyticsDB')
BEGIN
    CREATE DATABASE SalesAnalyticsDB;
END
GO