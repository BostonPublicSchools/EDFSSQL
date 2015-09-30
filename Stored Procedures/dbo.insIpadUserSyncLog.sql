SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 03/11/2014
-- Description:	Insert Ipad User Log
-- =============================================
CREATE PROCEDURE [dbo].[insIpadUserSyncLog]
	@UserID AS nchar(6)
	,@LogID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	 
	--DECLARE  @TempLogID int
	--SET @TempLogID = -1
	--SELECT  @TempLogID = LogId from IpadUserSyncLog where UserID = @UserID
	Declare @dwnversion nvarchar(6), @dwnDate datetime
	Set @dwnDate= Coalesce( (Select top 1 ReleaseDate from Release Where ReleaseType='App' Order By ReleaseDate Desc),'' )
	Set @dwnversion= Coalesce( (Select top 1 ReleaseVersion from Release Where ReleaseType='App' Order By ReleaseDate Desc),'' )
		
	IF EXISTS(SELECT userID from IpadUserSyncLog where UserID = @UserID) --@TempLogID <> null 
	BEGIN
		Update IpadUserSyncLog 
		SET LastSync = GETDATE()
			,lastUpdatedDt = GETDATE()
			,LastUpdatedByID = @UserID
			,LastAppDownloaddt = @dwnDate
			,LastAppDownloadVersion=@dwnversion
		WHERE UserID  = @UserID		
		SELECT @LogID = logid from IpadUserSyncLog Where userID = @UserID 
	END
	ELSE
	BEGIN
		INSERT INTO IpadUserSyncLog
					(
						UserId
						,LastSync
						,CreatedById
						,LastUpdatedById
						,LastAppDownloaddt
						,LastAppDownloadVersion
					)
					VALUES (@UserID
							,GETDATE()
							,@UserID
							,@UserID
							,@dwnDate
							,@dwnversion
							)
		SELECT @LogID = SCOPE_IDENTITY();
		
	END
END





GO
