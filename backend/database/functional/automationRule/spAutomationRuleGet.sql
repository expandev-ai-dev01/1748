/**
 * @summary
 * Retrieves a specific automation rule by ID.
 * 
 * @procedure spAutomationRuleGet
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/automation-rule/:id
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier for multi-tenancy
 * 
 * @param {INT} idRule
 *   - Required: Yes
 *   - Description: Rule identifier
 * 
 * @testScenarios
 * - Valid retrieval of existing rule
 * - Error when rule doesn't exist
 * - Error when rule belongs to different account
 * - Error when rule is soft deleted
 */
CREATE OR ALTER PROCEDURE [functional].[spAutomationRuleGet]
  @idAccount INTEGER,
  @idRule INTEGER
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

  IF (@idRule IS NULL)
  BEGIN
    ;THROW 51000, 'idRuleRequired', 1;
  END;

  /**
   * @validation Validate rule exists and belongs to account
   * @throw {ruleDoesntExist}
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[automationRule] autRul
    WHERE autRul.[idRule] = @idRule
      AND autRul.[idAccount] = @idAccount
      AND autRul.[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'ruleDoesntExist', 1;
  END;

  /**
   * @output {RuleDetail, 1, n}
   * @column {INT} idRule - Rule identifier
   * @column {INT} idUser - User who created the rule
   * @column {NVARCHAR} ruleName - Rule name
   * @column {NVARCHAR} trigger - JSON trigger definition
   * @column {NVARCHAR} actions - JSON actions array
   * @column {BIT} isActive - Active status
   * @column {DATETIME2} dateCreated - Creation timestamp
   * @column {DATETIME2} dateModified - Last modification timestamp
   */
  SELECT
    [autRul].[idRule],
    [autRul].[idUser],
    [autRul].[ruleName],
    [autRul].[trigger],
    [autRul].[actions],
    [autRul].[isActive],
    [autRul].[dateCreated],
    [autRul].[dateModified]
  FROM [functional].[automationRule] [autRul]
  WHERE [autRul].[idAccount] = @idAccount
    AND [autRul].[idRule] = @idRule
    AND [autRul].[deleted] = 0;
END;
GO
