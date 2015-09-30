SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Update RubricPlanAvailablePlan based on AvailablePlanID
--				This is used to inactive selected RubricPlanAvailablePlan 
-- =============================================
CREATE PROCEDURE [dbo].[UpdRubricPlanAvailablePlan]
	 @AvailablePlanID int 	
    ,@IsActive bit    
    ,@CreatedByID nchar(6)    
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE RubricPlanAvailablePlan 
	SET 		
		IsActive=@IsActive,
		LastUpdatedByID=@CreatedByID,
		LastUpdateDate=GETDATE()	
	WHERE AvailablePlanID = @AvailablePlanID
	
	
END
GO
