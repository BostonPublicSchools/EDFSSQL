SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/15/2012
-- Description:	update the empl exceptions			
-- =============================================
CREATE PROCEDURE [dbo].[updateEmplExceptionManager]
	@ExEmplID as nchar(6),
	@ExEmplJobID as int,
	@ExMgrID as nchar(6),	
	@UserID as nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @OldMgrID as nchar(6)
	SET @OldMgrID = (SELECT tOP 1 MgrId FROM SubEval s 
					 JOIN SubevalAssignedEmplEmplJob sej ON sej.SubEvalID = s.EvalID
					 WHERE sej.EmplJobID = @ExEmplJobID and sej.IsActive = 1 and sej.IsDeleted = 0)
	
	
	
	UPDATE EmplExceptions SET
	MgrID = @ExMgrID,
	LastUpdatedByID = @UserID,
	LastUpdatedDt = GETDATE()
	WHERE EmplJobID = @ExEmplJobID and EmplID = @ExEmplID	
	
	/**
	inactivate all the subeval assignedempl job associated
	with old manager if the manager is changed for the emplJob
	**/
	IF (@OldMgrID != @ExMgrID) 
	BEGIN 	
		UPDATE SubevalAssignedEmplEmplJob 
		SET IsActive = 0,
		    IsDeleted = 1,
		    LastUpdatedByID = @UserID,
		    LastUpdatedDt = GETDATE()
       WHERE EmplJobID = @ExEmplJobID		    
	END
	

	--update the plansubevalID with the new manager id if the subevalIS is old manager. 
	UPDATE ep
	SET ep.SubEvalID = dbo.funcGetPrimaryManagerByEmplID(@ExEmplID),
		ep.PlanManagerID = @ExMgrID,
	LastUpdatedByID = @UserID,
	LastUpdatedDt = GETDATE()
	FROM EmplPlan ep
	JOIN EmplEmplJob ej on ej.EmplJobID = ep.EmplJobID and ep.EmplJobID = @ExEmplJobID
	LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID = ej.EmplJobID and ej.IsActive = 1
	WHERE PlanActive = 1
	--ep.SubEvalID = (CASE WHEN ex.MgrID IS Null then ej.MgrID else ex.MgrID end) 
	
END





GO
