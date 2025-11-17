/**
 * @summary
 * Lists feedback records for suggestions, optionally filtered by helpfulness.
 * 
 * @procedure spSuggestionFeedbackList
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/suggestion-feedback
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier for multi-tenancy
 * 
 * @param {BIT} wasHelpful
 *   - Required: No
 *   - Description: Optional filter for helpful/not helpful feedback
 * 
 * @testScenarios
 * - List all feedback for account
 * - List only positive feedback
 * - List only negative feedback
 * - Empty result for account with no feedback
 */
CREATE OR ALTER PROCEDURE [functional].[spSuggestionFeedbackList]
  @idAccount INTEGER,
  @wasHelpful BIT = NULL
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

  /**
   * @output {FeedbackList, n, n}
   * @column {INT} idFeedback - Feedback identifier
   * @column {INT} idSuggestion - Related suggestion identifier
   * @column {VARCHAR} suggestionType - Type of the suggestion
   * @column {BIT} wasHelpful - Whether suggestion was helpful
   * @column {NVARCHAR} correctionPayload - User's correction if not helpful
   * @column {DATETIME2} dateCreated - Feedback creation timestamp
   */
  SELECT
    [sugFdb].[idFeedback],
    [sugFdb].[idSuggestion],
    [autSug].[suggestionType],
    [sugFdb].[wasHelpful],
    [sugFdb].[correctionPayload],
    [sugFdb].[dateCreated]
  FROM [functional].[suggestionFeedback] [sugFdb]
    JOIN [functional].[automationSuggestion] [autSug] ON ([autSug].[idAccount] = [sugFdb].[idAccount] AND [autSug].[idSuggestion] = [sugFdb].[idSuggestion])
  WHERE [sugFdb].[idAccount] = @idAccount
    AND (@wasHelpful IS NULL OR [sugFdb].[wasHelpful] = @wasHelpful)
  ORDER BY
    [sugFdb].[dateCreated] DESC;
END;
GO
