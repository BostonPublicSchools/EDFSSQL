SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 11/20/2012
-- Description:	Delete the empl exception
-- =============================================
CREATE PROCEDURE [dbo].[DelEmplExceptionManager]
	@ExEmplID AS nchar(6),
	@ExEmplJobID AS int,
	@UserID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MgrID as nchar(6)
	SELECT @MgrID = MgrID FROM EmplExceptions
	WHERE EmplJobID = @ExEmplJobID AND EmplID = @ExEmplID
	
	DELETE FROM EmplExceptions
	WHERE EmplJobID = @ExEmplJobID AND EmplID = @ExEmplID
	
	IF(Exists(SELECT PlanId FROM EmplPlan WHERE  EmplJobID = @ExEmplJobID AND PlanActive = 1 AND SubEvalID = @MgrID))
	BEGIN
	  UPDATE EmplPlan 
	  SET SubEvalID = dbo.funcGetPrimaryManagerByEmplID(@ExEmplID),
	  PlanManagerID = dbo.funcGetPrimaryManagerByEmplID(@ExEmplID),
	  LastUpdatedByID = @UserID,
	  LastUpdatedDt = GETDATE()
	  WHERE  EmplJobID = @ExEmplJobID AND PlanActive = 1 AND SubEvalID = @MgrID
	END
END
GO
