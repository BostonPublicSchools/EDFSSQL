SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =========================================================
-- Author:		Avery, Bryce
-- Create date: 03/11/2014		
-- Description:	insert a new iPad user
-- =========================================================
CREATE PROCEDURE [dbo].[insertiPadUser]
	@EmplID as nchar(6) = null
	,@createdByID as nchar(6) = null
	,@LogId int = null OUTPUT 
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Check if isManager or Evaluator
	Declare @AllMgrAndEvals TABLE(
		NameFirst VARCHAR(50),
		NameLast VARCHAR(50),
		NameMiddle VARCHAR(50),
		EmplID VARCHAR(6),
		EmplActive BIT		
	)
	Insert into @AllMgrAndEvals
		exec getEmplNames_MgrAndEvalsOnly ''
		
	IF Not EXISTS(SELECT TOP 1 * FROM IpadUserSyncLog WHERE UserId=@EmplID ) AND
				  Exists(SELECT TOP 1 * from @AllMgrAndEvals where EmplID=@EmplID)	
	Begin
		INSERT INTO IpadUserSyncLog (UserId, CreatedDt, CreatedByID, LastUpdatedDt, LastUpdatedByID)
						VALUES (@EmplID, GETDATE(), @createdByID, GETDATE(), @createdByID)
		
		Set @LogId = SCOPE_IDENTITY();	
	End
	
END

GO
