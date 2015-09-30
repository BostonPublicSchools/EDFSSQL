SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 04/24/20104
-- Description:	end non 5 step Process Plan
-- =============================================
CREATE PROCEDURE [dbo].[UpdNon5StepPlan]
	@PlanID as int,
	@PlanActive bit = 1,	
	@PlanEndDate datetime= null,
	@PlanEndReasonID int = null,
	@UserID nchar(6) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	IF(@PlanID != 0)
	BEGIN
	 UPDATE EmplPlan
		SET
			 PlanActEndDt = @PlanEndDate
			,PlanEndReasonID = @PlanEndReasonID 
			,PlanActive = @PlanActive						
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
		WHERE 
			PlanID = @PlanID
	END
	
END	
GO
