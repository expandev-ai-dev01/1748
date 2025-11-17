/**
 * @summary
 * This file defines the schema and table structures for the 'functional' schema.
 * It is responsible for creating tables related to core business entities.
 */

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'functional')
BEGIN
    EXEC('CREATE SCHEMA functional');
END
GO

-- Tables for the 'functional' schema will be defined here in feature implementations.

GO
