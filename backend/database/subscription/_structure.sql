/**
 * @summary
 * This file defines the schema and table structures for the 'subscription' schema.
 * It is responsible for creating tables related to multi-tenancy and accounts.
 */

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'subscription')
BEGIN
    EXEC('CREATE SCHEMA subscription');
END
GO

-- Tables for the 'subscription' schema will be defined here in feature implementations.

GO
