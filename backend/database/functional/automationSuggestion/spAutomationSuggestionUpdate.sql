/**
 * @summary
 * Updates the status of an automation suggestion (accept or reject).
 * 
 * @procedure spAutomationSuggestionUpdate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - PUT /api/v1/internal/automation-suggestion/:id
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
 * @param {VARCHAR} status
 *   - Required: Yes
 *   - Description: New status (ACCEPTED or REJECTED)
 * 
 * @testScenarios
 * - Valid status update to ACCEPTED
 * - Valid status update to REJECTED
 * - Error when suggestion doesn't exist
 * - Error when invalid status provided
 * - Error when trying to update already processed suggestion
 */
CREATE OR ALTER PROCEDURE [functional].[spAutomationSuggestionUpdate]
  @idAccount INTEGER,
  @idSuggestion INTEGER,
  @status VARCHAR(20)
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

  IF (@status IS NULL OR @status = '')
  BEGIN
    ;THROW 51000, 'statusRequired', 1;
  END;

  /**
   * @validation Validate status enumeration
   * @throw {invalidStatus}
   */
  IF (@status NOT IN ('ACCEPTED', 'REJECTED'))
  BEGIN
    ;THROW 51000, 'invalidStatus', 1;
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
   * @validation Validate suggestion is still pending
   * @throw {suggestionAlreadyProcessed}
   */
  IF EXISTS (
    SELECT 1
    FROM [functional].[automationSuggestion] autSug
    WHERE autSug.[idSuggestion] = @idSuggestion
      AND autSug.[idAccount] = @idAccount
      AND autSug.[status] <> 'PENDING'
  )
  BEGIN
    ;THROW 51000, 'suggestionAlreadyProcessed', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      /**
       * @rule {db-multi-tenancy-pattern} Update suggestion with account isolation
       */
      UPDATE [functional].[automationSuggestion]
      SET
        [status] = @status,
        [dateModified] = GETUTCDATE()
      WHERE [idSuggestion] = @idSuggestion
        AND [idAccount] = @idAccount;

      /**
       * @output {SuggestionUpdated, 1, 1}
       * @column {INT} idSuggestion
       * - Description: The ID of the updated suggestion
       */
      SELECT @idSuggestion AS [idSuggestion];

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO
