/**
 * @summary
 * Lists automation suggestions for a specific user, optionally filtered by status.
 * 
 * @procedure spAutomationSuggestionList
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/automation-suggestion
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier for multi-tenancy
 * 
 * @param {INT} idUser
 *   - Required: Yes
 *   - Description: User identifier to filter suggestions
 * 
 * @param {VARCHAR} status
 *   - Required: No
 *   - Description: Optional status filter (PENDING, ACCEPTED, REJECTED)
 * 
 * @testScenarios
 * - List all suggestions for a user
 * - List only pending suggestions
 * - List only accepted suggestions
 * - Empty result for user with no suggestions
 */
CREATE OR ALTER PROCEDURE [functional].[spAutomationSuggestionList]
  @idAccount INTEGER,
  @idUser INTEGER,
  @status VARCHAR(20) = NULL
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
   * @validation Validate status enumeration if provided
   * @throw {invalidStatus}
   */
  IF (@status IS NOT NULL AND @status NOT IN ('PENDING', 'ACCEPTED', 'REJECTED'))
  BEGIN
    ;THROW 51000, 'invalidStatus', 1;
  END;

  /**
   * @output {SuggestionList, n, n}
   * @column {INT} idSuggestion - Suggestion identifier
   * @column {VARCHAR} suggestionType - Type of suggestion
   * @column {NVARCHAR} sourceContent - Original content that triggered suggestion
   * @column {NVARCHAR} suggestedActionPayload - JSON payload with action details
   * @column {VARCHAR} status - Current status of suggestion
   * @column {DATETIME2} dateCreated - Creation timestamp
   * @column {DATETIME2} dateModified - Last modification timestamp
   */
  SELECT
    [autSug].[idSuggestion],
    [autSug].[suggestionType],
    [autSug].[sourceContent],
    [autSug].[suggestedActionPayload],
    [autSug].[status],
    [autSug].[dateCreated],
    [autSug].[dateModified]
  FROM [functional].[automationSuggestion] [autSug]
  WHERE [autSug].[idAccount] = @idAccount
    AND [autSug].[idUser] = @idUser
    AND (@status IS NULL OR [autSug].[status] = @status)
  ORDER BY
    [autSug].[dateCreated] DESC;
END;
GO
