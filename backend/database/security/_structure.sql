/**
 * @summary
 * This file defines the schema and table structures for the 'security' schema.
 * It is responsible for creating tables for authentication and authorization.
 */

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'security')
BEGIN
    EXEC('CREATE SCHEMA security');
END
GO

-- Tables for the 'security' schema will be defined here in feature implementations.

GO
