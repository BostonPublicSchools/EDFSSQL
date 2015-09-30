SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 06/03/2013
-- Description:	Update plan rubric
-- =============================================
CREATE PROCEDURE [dbo].[UpdatePlanRubricByPlanID]
	@PlanID AS nchar(6),
	@RubricID AS int, 
	@UserID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE EmplPlan 
	SET 
		RubricID = @RubricID,
		LastUpdatedByID = @UserID,
		LastUpdatedDt = GETDATE()
	WHERE PlanID = @PlanID
	
END
GO
