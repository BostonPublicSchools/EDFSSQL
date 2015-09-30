SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 10/12/2012
-- Description:	Get sub evals by emplID
-- =============================================
CREATE PROCEDURE [dbo].[UpdatePlanSubEvalByPlanID]
	@PlanID AS nchar(6),
	@PlanSubEvalID AS nchar(6), 
	@UserID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE EmplPlan 
	SET SubEvalID = @PlanSubEvalID,
		LastUpdatedByID = @UserID,
		LastUpdatedDt = GETDATE()
	WHERE PlanID = @PlanID
	
END
GO
