/**
 * @summary
 * Lists automation rules for a specific user, optionally filtered by active status.
 * 
 * @procedure spAutomationRuleList
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/automation-rule
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier for multi-tenancy
 * 
 * @param {INT} idUser
 *   - Required: Yes
 *   - Description: User identifier to filter rules
 * 
 * @param {BIT} isActive
 *   - Required: No
 *   - Description: Optional filter for active/inactive rules
 * 
 * @testScenarios
 * - List all rules for a user
 * - List only active rules
 * - List only inactive rules
 * - Empty result for user with no rules
 */
CREATE OR ALTER PROCEDURE [functional].[spAutomationRuleList]
  @idAccount INTEGER,
  @idUser INTEGER,
  @isActive BIT = NULL
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Validate required parameters
   * @throw {parameterRequired}
   */
  IF (@idAccount IS NULL)
  BEGIN
    ;THROW 51000, 'idAccountRequired', 1;
  END;

  IF (@idUser IS NULL)
  BEGIN
    ;THROW 51000, 'idUserRequired', 1;
  END;

  /**
   * @output {RuleList, n, n}
   * @column {INT} idRule - Rule identifier
   * @column {NVARCHAR} ruleName - Rule name
   * @column {NVARCHAR} trigger - JSON trigger definition
   * @column {NVARCHAR} actions - JSON actions array
   * @column {BIT} isActive - Active status
   * @column {DATETIME2} dateCreated - Creation timestamp
   * @column {DATETIME2} dateModified - Last modification timestamp
   */
  SELECT
    [autRul].[idRule],
    [autRul].[ruleName],
    [autRul].[trigger],
    [autRul].[actions],
    [autRul].[isActive],
    [autRul].[dateCreated],
    [autRul].[dateModified]
  FROM [functional].[automationRule] [autRul]
  WHERE [autRul].[idAccount] = @idAccount
    AND [autRul].[idUser] = @idUser
    AND [autRul].[deleted] = 0
    AND (@isActive IS NULL OR [autRul].[isActive] = @isActive)
  ORDER BY
    [autRul].[dateCreated] DESC;
END;
GO
