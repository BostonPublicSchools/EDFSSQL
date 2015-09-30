SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Newa, Matina
-- Create date: 05/18/2014
-- Description:	Set Plan as valid Plan,
-- =============================================
CREATE PROCEDURE [dbo].[updPlanToValidPlan]
	@PlanID int
	,@IsInvalid bit	
	,@EmplID nchar(6)
	,@UserID nchar(6)
	
AS
BEGIN
	SET NOCOUNT ON;
	
	Update EmplPlan 
	Set 		 
		IsInvalid = 0
		,InvalidNote=null		
		,LastUpdatedByID=@UserID
		,LastUpdatedDt = GETDATE()
	Where PlanID =@PlanID
	

END		



GO
