/**
 * @summary
 * Retrieves a specific automation suggestion by ID.
 * 
 * @procedure spAutomationSuggestionGet
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/automation-suggestion/:id
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier for multi-tenancy
 * 
 * @param {INT} idSuggestion
 *   - Required: Yes
 *   - Description: Suggestion identifier
 * 
 * @testScenarios
 * - Valid retrieval of existing suggestion
 * - Error when suggestion doesn't exist
 * - Error when suggestion belongs to different account
 */
CREATE OR ALTER PROCEDURE [functional].[spAutomationSuggestionGet]
  @idAccount INTEGER,
  @idSuggestion INTEGER
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

  IF (@idSuggestion IS NULL)
  BEGIN
    ;THROW 51000, 'idSuggestionRequired', 1;
  END;

  /**
   * @validation Validate suggestion exists and belongs to account
   * @throw {suggestionDoesntExist}
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[automationSuggestion] autSug
    WHERE autSug.[idSuggestion] = @idSuggestion
      AND autSug.[idAccount] = @idAccount
  )
  BEGIN
    ;THROW 51000, 'suggestionDoesntExist', 1;
  END;

  /**
   * @output {SuggestionDetail, 1, n}
   * @column {INT} idSuggestion - Suggestion identifier
   * @column {INT} idUser - User who received the suggestion
   * @column {VARCHAR} suggestionType - Type of suggestion
   * @column {NVARCHAR} sourceContent - Original content that triggered suggestion
   * @column {NVARCHAR} suggestedActionPayload - JSON payload with action details
   * @column {VARCHAR} status - Current status of suggestion
   * @column {DATETIME2} dateCreated - Creation timestamp
   * @column {DATETIME2} dateModified - Last modification timestamp
   */
  SELECT
    [autSug].[idSuggestion],
    [autSug].[idUser],
    [autSug].[suggestionType],
    [autSug].[sourceContent],
    [autSug].[suggestedActionPayload],
    [autSug].[status],
    [autSug].[dateCreated],
    [autSug].[dateModified]
  FROM [functional].[automationSuggestion] [autSug]
  WHERE [autSug].[idAccount] = @idAccount
    AND [autSug].[idSuggestion] = @idSuggestion;
END;
GO
