/**
 * @summary
 * Updates an existing automation rule.
 * 
 * @procedure spAutomationRuleUpdate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - PUT /api/v1/internal/automation-rule/:id
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
 * @param {NVARCHAR} ruleName
 *   - Required: No
 *   - Description: Updated rule name
 * 
 * @param {NVARCHAR} trigger
 *   - Required: No
 *   - Description: Updated trigger JSON
 * 
 * @param {NVARCHAR} actions
 *   - Required: No
 *   - Description: Updated actions JSON
 * 
 * @param {BIT} isActive
 *   - Required: No
 *   - Description: Updated active status
 * 
 * @testScenarios
 * - Valid update of rule name
 * - Valid update of trigger and actions
 * - Valid toggle of active status
 * - Error when rule doesn't exist
 * - Error when invalid JSON provided
 */
CREATE OR ALTER PROCEDURE [functional].[spAutomationRuleUpdate]
  @idAccount INTEGER,
  @idRule INTEGER,
  @ruleName NVARCHAR(100) = NULL,
  @trigger NVARCHAR(MAX) = NULL,
  @actions NVARCHAR(MAX) = NULL,
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
   * @validation Validate rule name length if provided
   * @throw {ruleNameInvalidLength}
   */
  IF (@ruleName IS NOT NULL AND (LEN(@ruleName) < 3 OR LEN(@ruleName) > 100))
  BEGIN
    ;THROW 51000, 'ruleNameInvalidLength', 1;
  END;

  /**
   * @validation Validate JSON structure for trigger if provided
   * @throw {invalidTriggerJson}
   */
  IF (@trigger IS NOT NULL AND ISJSON(@trigger) = 0)
  BEGIN
    ;THROW 51000, 'invalidTriggerJson', 1;
  END;

  /**
   * @validation Validate JSON structure for actions if provided
   * @throw {invalidActionsJson}
   */
  IF (@actions IS NOT NULL AND ISJSON(@actions) = 0)
  BEGIN
    ;THROW 51000, 'invalidActionsJson', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      /**
       * @rule {db-multi-tenancy-pattern} Update rule with account isolation
       */
      UPDATE [functional].[automationRule]
      SET
        [ruleName] = COALESCE(@ruleName, [ruleName]),
        [trigger] = COALESCE(@trigger, [trigger]),
        [actions] = COALESCE(@actions, [actions]),
        [isActive] = COALESCE(@isActive, [isActive]),
        [dateModified] = GETUTCDATE()
      WHERE [idRule] = @idRule
        AND [idAccount] = @idAccount
        AND [deleted] = 0;

      /**
       * @output {RuleUpdated, 1, 1}
       * @column {INT} idRule
       * - Description: The ID of the updated rule
       */
      SELECT @idRule AS [idRule];

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO
