/**
 * @summary
 * Creates a feedback record for an AI suggestion.
 * 
 * @procedure spSuggestionFeedbackCreate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/suggestion-feedback
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
 * @param {BIT} wasHelpful
 *   - Required: Yes
 *   - Description: Whether the suggestion was helpful
 * 
 * @param {NVARCHAR} correctionPayload
 *   - Required: No
 *   - Description: JSON payload with user's correction if suggestion was not helpful
 * 
 * @returns {INT} idFeedback - The ID of the newly created feedback
 * 
 * @testScenarios
 * - Valid creation of positive feedback
 * - Valid creation of negative feedback with correction
 * - Error when suggestion doesn't exist
 * - Error when duplicate feedback for same suggestion
 */
CREATE OR ALTER PROCEDURE [functional].[spSuggestionFeedbackCreate]
  @idAccount INTEGER,
  @idSuggestion INTEGER,
  @wasHelpful BIT,
  @correctionPayload NVARCHAR(MAX) = NULL
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

  IF (@wasHelpful IS NULL)
  BEGIN
    ;THROW 51000, 'wasHelpfulRequired', 1;
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
   * @validation Validate JSON structure for correction payload if provided
   * @throw {invalidCorrectionJson}
   */
  IF (@correctionPayload IS NOT NULL AND ISJSON(@correctionPayload) = 0)
  BEGIN
    ;THROW 51000, 'invalidCorrectionJson', 1;
  END;

  /**
   * @validation Prevent duplicate feedback for same suggestion
   * @throw {feedbackAlreadyExists}
   */
  IF EXISTS (
    SELECT 1
    FROM [functional].[suggestionFeedback] sugFdb
    WHERE sugFdb.[idSuggestion] = @idSuggestion
      AND sugFdb.[idAccount] = @idAccount
  )
  BEGIN
    ;THROW 51000, 'feedbackAlreadyExists', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      DECLARE @idFeedback INTEGER;

      /**
       * @rule {db-multi-tenancy-pattern} Insert feedback with account isolation
       */
      INSERT INTO [functional].[suggestionFeedback] (
        [idAccount],
        [idSuggestion],
        [wasHelpful],
        [correctionPayload],
        [dateCreated]
      )
      VALUES (
        @idAccount,
        @idSuggestion,
        @wasHelpful,
        @correctionPayload,
        GETUTCDATE()
      );

      SET @idFeedback = SCOPE_IDENTITY();

      /**
       * @output {FeedbackCreated, 1, 1}
       * @column {INT} idFeedback
       * - Description: The ID of the newly created feedback
       */
      SELECT @idFeedback AS [idFeedback];

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO
