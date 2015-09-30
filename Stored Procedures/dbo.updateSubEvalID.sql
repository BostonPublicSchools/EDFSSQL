SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Ganesan, Devi	
-- Create date: 08/21/2012
-- Description: update the eval ID in the emplemplJob
-- =============================================

CREATE PROCEDURE [dbo].[updateSubEvalID]
	@EmplJobID int,
	@EmplEvalID int,
	@UserId char(6)
AS
BEGIN
SET NOCOUNT ON;
    UPDATE SubevalAssignedEmplEmplJob
    SET 
		SubEvalID = @EmplEvalID
		,IsDeleted = 0
		,IsActive = 1
		,LastUpdatedByID = @UserId
		,LastUpdatedDt = GETDATE()
	WHERE 
		EmplJobID = @EmplJobID
		
END

GO
