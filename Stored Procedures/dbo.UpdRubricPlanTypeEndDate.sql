SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Update RubricPlanEndDate based on PlanEndDateID
--				This is used to inactive selected RubricPlan -PlanEndDate
-- =============================================
CREATE PROCEDURE [dbo].[UpdRubricPlanTypeEndDate]
	 @PlanEndDateID int 	
    ,@IsActive bit    
    ,@CreatedByID nchar(6)    
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE RubricPlanTypeEndDate 
	SET 		
		IsActive=@IsActive,
		LastUpdatedByID=@CreatedByID,
		LastUpdatedDate=GETDATE()	
	WHERE PlanEndDateID = @PlanEndDateID
	
	
END
GO
