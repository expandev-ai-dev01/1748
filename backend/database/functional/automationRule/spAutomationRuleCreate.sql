/**
 * @summary
 * Creates a new user-defined automation rule.
 * 
 * @procedure spAutomationRuleCreate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/automation-rule
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier for multi-tenancy
 * 
 * @param {INT} idUser
 *   - Required: Yes
 *   - Description: User identifier who creates the rule
 * 
 * @param {NVARCHAR} ruleName
 *   - Required: Yes
 *   - Description: Descriptive name for the rule (3-100 characters)
 * 
 * @param {NVARCHAR} trigger
 *   - Required: Yes
 *   - Description: JSON object defining the trigger and conditions
 * 
 * @param {NVARCHAR} actions
 *   - Required: Yes
 *   - Description: JSON array of actions to execute
 * 
 * @param {BIT} isActive
 *   - Required: No
 *   - Description: Whether the rule is active (default: true)
 * 
 * @returns {INT} idRule - The ID of the newly created rule
 * 
 * @testScenarios
 * - Valid creation with all required parameters
 * - Validation failure for invalid rule name length
 * - Validation failure for non-existent user
 * - Validation failure for invalid JSON structure
 */
CREATE OR ALTER PROCEDURE [functional].[spAutomationRuleCreate]
  @idAccount INTEGER,
  @idUser INTEGER,
  @ruleName NVARCHAR(100),
  @trigger NVARCHAR(MAX),
  @actions NVARCHAR(MAX),
  @isActive BIT = 1
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

  IF (@ruleName IS NULL OR @ruleName = '')
  BEGIN
    ;THROW 51000, 'ruleNameRequired', 1;
  END;

  IF (@trigger IS NULL OR @trigger = '')
  BEGIN
    ;THROW 51000, 'triggerRequired', 1;
  END;

  IF (@actions IS NULL OR @actions = '')
  BEGIN
    ;THROW 51000, 'actionsRequired', 1;
  END;

  /**
   * @validation Validate rule name length
   * @throw {ruleNameInvalidLength}
   */
  IF (LEN(@ruleName) < 3 OR LEN(@ruleName) > 100)
  BEGIN
    ;THROW 51000, 'ruleNameInvalidLength', 1;
  END;

  /**
   * @validation Validate user exists and belongs to account
   * @throw {userDoesntExist}
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [security].[user] usr
    WHERE usr.[idUser] = @idUser
      AND usr.[idAccount] = @idAccount
  )
  BEGIN
    ;THROW 51000, 'userDoesntExist', 1;
  END;

  /**
   * @validation Validate JSON structure for trigger
   * @throw {invalidTriggerJson}
   */
  IF (ISJSON(@trigger) = 0)
  BEGIN
    ;THROW 51000, 'invalidTriggerJson', 1;
  END;

  /**
   * @validation Validate JSON structure for actions
   * @throw {invalidActionsJson}
   */
  IF (ISJSON(@actions) = 0)
  BEGIN
    ;THROW 51000, 'invalidActionsJson', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      DECLARE @idRule INTEGER;

      /**
       * @rule {db-multi-tenancy-pattern} Insert rule with account isolation
       */
      INSERT INTO [functional].[automationRule] (
        [idAccount],
        [idUser],
        [ruleName],
        [trigger],
        [actions],
        [isActive],
        [dateCreated],
        [dateModified],
        [deleted]
      )
      VALUES (
        @idAccount,
        @idUser,
        @ruleName,
        @trigger,
        @actions,
        @isActive,
        GETUTCDATE(),
        GETUTCDATE(),
        0
      );

      SET @idRule = SCOPE_IDENTITY();

      /**
       * @output {RuleCreated, 1, 1}
       * @column {INT} idRule
       * - Description: The ID of the newly created rule
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
