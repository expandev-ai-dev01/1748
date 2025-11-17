/**
 * @summary
 * Soft deletes an automation rule.
 * 
 * @procedure spAutomationRuleDelete
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - DELETE /api/v1/internal/automation-rule/:id
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
 * - Valid soft delete of existing rule
 * - Error when rule doesn't exist
 * - Error when rule belongs to different account
 * - Error when rule is already deleted
 */
CREATE OR ALTER PROCEDURE [functional].[spAutomationRuleDelete]
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

  BEGIN TRY
    BEGIN TRAN;

      /**
       * @rule {db-soft-delete-pattern} Soft delete rule
       */
      UPDATE [functional].[automationRule]
      SET
        [deleted] = 1,
        [dateModified] = GETUTCDATE()
      WHERE [idRule] = @idRule
        AND [idAccount] = @idAccount
        AND [deleted] = 0;

      /**
       * @output {RuleDeleted, 1, 1}
       * @column {INT} idRule
       * - Description: The ID of the deleted rule
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
