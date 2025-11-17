/**
 * @summary
 * This file defines the schema and table structures for the 'config' schema.
 * It is responsible for creating tables that hold system-wide configuration.
 */

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'config')
BEGIN
    EXEC('CREATE SCHEMA config');
END
GO

-- Tables for the 'config' schema will be defined here in feature implementations.

GO
