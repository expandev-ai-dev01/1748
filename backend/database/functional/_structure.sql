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

/**
 * @table {automationSuggestion} Stores AI-generated suggestions for task automation
 * @multitenancy true
 * @softDelete false
 * @alias autSug
 */
CREATE TABLE [functional].[automationSuggestion] (
  [idSuggestion] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idUser] INTEGER NOT NULL,
  [suggestionType] VARCHAR(50) NOT NULL,
  [sourceContent] NVARCHAR(MAX) NULL,
  [suggestedActionPayload] NVARCHAR(MAX) NOT NULL,
  [status] VARCHAR(20) NOT NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL
);

/**
 * @primaryKey {pkAutomationSuggestion}
 * @keyType Object
 */
ALTER TABLE [functional].[automationSuggestion]
ADD CONSTRAINT [pkAutomationSuggestion] PRIMARY KEY CLUSTERED ([idSuggestion]);

/**
 * @foreignKey {fkAutomationSuggestion_Account} Links suggestion to account for multi-tenancy
 * @target {subscription.account}
 * @tenancy true
 */
ALTER TABLE [functional].[automationSuggestion]
ADD CONSTRAINT [fkAutomationSuggestion_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);

/**
 * @foreignKey {fkAutomationSuggestion_User} Links suggestion to the user who received it
 * @target {security.user}
 */
ALTER TABLE [functional].[automationSuggestion]
ADD CONSTRAINT [fkAutomationSuggestion_User] FOREIGN KEY ([idUser])
REFERENCES [security].[user]([idUser]);

/**
 * @check {chkAutomationSuggestion_SuggestionType} Validates suggestion type enumeration
 * @enum {RECURRING_TASK} Suggestion to create a recurring task
 * @enum {TASK_FROM_INTEGRATION} Suggestion to create task from external integration
 * @enum {TAG_SUGGESTION} Suggestion to apply tags to a task
 * @enum {PROJECT_SUGGESTION} Suggestion to assign task to a project
 */
ALTER TABLE [functional].[automationSuggestion]
ADD CONSTRAINT [chkAutomationSuggestion_SuggestionType] CHECK ([suggestionType] IN ('RECURRING_TASK', 'TASK_FROM_INTEGRATION', 'TAG_SUGGESTION', 'PROJECT_SUGGESTION'));

/**
 * @check {chkAutomationSuggestion_Status} Validates suggestion status enumeration
 * @enum {PENDING} Suggestion awaiting user action
 * @enum {ACCEPTED} User accepted the suggestion
 * @enum {REJECTED} User rejected the suggestion
 */
ALTER TABLE [functional].[automationSuggestion]
ADD CONSTRAINT [chkAutomationSuggestion_Status] CHECK ([status] IN ('PENDING', 'ACCEPTED', 'REJECTED'));

/**
 * @default {dfAutomationSuggestion_Status} Default status for new suggestions
 */
ALTER TABLE [functional].[automationSuggestion]
ADD CONSTRAINT [dfAutomationSuggestion_Status] DEFAULT ('PENDING') FOR [status];

/**
 * @default {dfAutomationSuggestion_DateCreated} Default creation timestamp
 */
ALTER TABLE [functional].[automationSuggestion]
ADD CONSTRAINT [dfAutomationSuggestion_DateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];

/**
 * @default {dfAutomationSuggestion_DateModified} Default modification timestamp
 */
ALTER TABLE [functional].[automationSuggestion]
ADD CONSTRAINT [dfAutomationSuggestion_DateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];

/**
 * @index {ixAutomationSuggestion_Account} Multi-tenancy isolation index
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixAutomationSuggestion_Account]
ON [functional].[automationSuggestion]([idAccount]);

/**
 * @index {ixAutomationSuggestion_Account_User_Status} Optimizes queries for user's pending suggestions
 * @type Performance
 */
CREATE NONCLUSTERED INDEX [ixAutomationSuggestion_Account_User_Status]
ON [functional].[automationSuggestion]([idAccount], [idUser], [status])
INCLUDE ([suggestionType], [dateCreated]);

/**
 * @table {automationRule} Stores user-defined automation rules
 * @multitenancy true
 * @softDelete true
 * @alias autRul
 */
CREATE TABLE [functional].[automationRule] (
  [idRule] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idUser] INTEGER NOT NULL,
  [ruleName] NVARCHAR(100) NOT NULL,
  [trigger] NVARCHAR(MAX) NOT NULL,
  [actions] NVARCHAR(MAX) NOT NULL,
  [isActive] BIT NOT NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [deleted] BIT NOT NULL
);

/**
 * @primaryKey {pkAutomationRule}
 * @keyType Object
 */
ALTER TABLE [functional].[automationRule]
ADD CONSTRAINT [pkAutomationRule] PRIMARY KEY CLUSTERED ([idRule]);

/**
 * @foreignKey {fkAutomationRule_Account} Links rule to account for multi-tenancy
 * @target {subscription.account}
 * @tenancy true
 */
ALTER TABLE [functional].[automationRule]
ADD CONSTRAINT [fkAutomationRule_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);

/**
 * @foreignKey {fkAutomationRule_User} Links rule to the user who created it
 * @target {security.user}
 */
ALTER TABLE [functional].[automationRule]
ADD CONSTRAINT [fkAutomationRule_User] FOREIGN KEY ([idUser])
REFERENCES [security].[user]([idUser]);

/**
 * @default {dfAutomationRule_IsActive} Default active status for new rules
 */
ALTER TABLE [functional].[automationRule]
ADD CONSTRAINT [dfAutomationRule_IsActive] DEFAULT (1) FOR [isActive];

/**
 * @default {dfAutomationRule_DateCreated} Default creation timestamp
 */
ALTER TABLE [functional].[automationRule]
ADD CONSTRAINT [dfAutomationRule_DateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];

/**
 * @default {dfAutomationRule_DateModified} Default modification timestamp
 */
ALTER TABLE [functional].[automationRule]
ADD CONSTRAINT [dfAutomationRule_DateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];

/**
 * @default {dfAutomationRule_Deleted} Default soft delete flag
 */
ALTER TABLE [functional].[automationRule]
ADD CONSTRAINT [dfAutomationRule_Deleted] DEFAULT (0) FOR [deleted];

/**
 * @index {ixAutomationRule_Account} Multi-tenancy isolation index
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixAutomationRule_Account]
ON [functional].[automationRule]([idAccount])
WHERE [deleted] = 0;

/**
 * @index {ixAutomationRule_Account_User_Active} Optimizes queries for user's active rules
 * @type Performance
 */
CREATE NONCLUSTERED INDEX [ixAutomationRule_Account_User_Active]
ON [functional].[automationRule]([idAccount], [idUser], [isActive])
INCLUDE ([ruleName], [dateCreated])
WHERE [deleted] = 0;

/**
 * @table {suggestionFeedback} Stores user feedback on AI suggestions
 * @multitenancy true
 * @softDelete false
 * @alias sugFdb
 */
CREATE TABLE [functional].[suggestionFeedback] (
  [idFeedback] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idSuggestion] INTEGER NOT NULL,
  [wasHelpful] BIT NOT NULL,
  [correctionPayload] NVARCHAR(MAX) NULL,
  [dateCreated] DATETIME2 NOT NULL
);

/**
 * @primaryKey {pkSuggestionFeedback}
 * @keyType Object
 */
ALTER TABLE [functional].[suggestionFeedback]
ADD CONSTRAINT [pkSuggestionFeedback] PRIMARY KEY CLUSTERED ([idFeedback]);

/**
 * @foreignKey {fkSuggestionFeedback_Account} Links feedback to account for multi-tenancy
 * @target {subscription.account}
 * @tenancy true
 */
ALTER TABLE [functional].[suggestionFeedback]
ADD CONSTRAINT [fkSuggestionFeedback_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);

/**
 * @foreignKey {fkSuggestionFeedback_Suggestion} Links feedback to the original suggestion
 * @target {functional.automationSuggestion}
 */
ALTER TABLE [functional].[suggestionFeedback]
ADD CONSTRAINT [fkSuggestionFeedback_Suggestion] FOREIGN KEY ([idSuggestion])
REFERENCES [functional].[automationSuggestion]([idSuggestion]);

/**
 * @default {dfSuggestionFeedback_DateCreated} Default creation timestamp
 */
ALTER TABLE [functional].[suggestionFeedback]
ADD CONSTRAINT [dfSuggestionFeedback_DateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];

/**
 * @index {ixSuggestionFeedback_Account} Multi-tenancy isolation index
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixSuggestionFeedback_Account]
ON [functional].[suggestionFeedback]([idAccount]);

/**
 * @index {ixSuggestionFeedback_Account_Suggestion} Optimizes queries for suggestion feedback
 * @type Performance
 */
CREATE NONCLUSTERED INDEX [ixSuggestionFeedback_Account_Suggestion]
ON [functional].[suggestionFeedback]([idAccount], [idSuggestion])
INCLUDE ([wasHelpful], [dateCreated]);

GO
