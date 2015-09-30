SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Ganesan, Devi	
-- Create date: 01/22/2013
-- Description: update the eval ID in the emplemplJob
-- =============================================

CREATE PROCEDURE [dbo].[deleteSubEvalID]
	@EmplJobID int,
	@UserId char(6)
AS
BEGIN
SET NOCOUNT ON;
    UPDATE SubevalAssignedEmplEmplJob
    SET 
		IsDeleted = 1
		,IsActive = 0
		,LastUpdatedByID = @UserId
		,LastUpdatedDt = GETDATE()
	WHERE 
		EmplJobID = @EmplJobID
		
END

GO
