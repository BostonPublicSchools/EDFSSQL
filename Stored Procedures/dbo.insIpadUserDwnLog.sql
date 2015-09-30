SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[insIpadUserDwnLog]
	@UserID AS nchar(6)
	,@LogID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
 
	Declare @dwnversion nvarchar(6), @dwnDate datetime
	Set @dwnDate= Coalesce( (Select top 1 ReleaseDate from Release Where ReleaseType='App' Order By ReleaseDate Desc),'' )
	Set @dwnversion= Coalesce( (Select top 1 ReleaseVersion from Release Where ReleaseType='App' Order By ReleaseDate Desc),'' )
		
	IF EXISTS(SELECT userID from IpadUserSyncLog where UserID = @UserID) --@TempLogID <> null 
	BEGIN
		Update IpadUserSyncLog 
		SET --LastSync = GETDATE()
			 lastUpdatedDt = GETDATE()
			,LastUpdatedByID = @UserID
			,LastAppDownloaddt = @dwnDate
			,LastAppDownloadVersion=@dwnversion
		WHERE UserID  = @UserID		
		
		SELECT @LogID = logid from IpadUserSyncLog Where userID = @UserID 
		
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID
							, LoggedEvent, EventDt, PreviousText
							, NewText, CreatedByID, CreatedByDt
							, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
						SELECT 
								'IpadUserSyncLog', LogId, LastUpdatedByID
								, 'iPad app download link clicked on EDFS ', LastUpdatedDt, ' ' 
								, LastAppDownloadVersion , LastUpdatedByID, GETDATE()
								, LastUpdatedByID, GETDATE(), LastUpdatedByID
						From IpadUserSyncLog Where userID = @UserID		
		
		
		
		
	END
END





GO
