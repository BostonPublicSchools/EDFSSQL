SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Update RubricPlanType based on RubricPlanTypeID
--				This is used to active/inactive selected RubricPlanTypeID
-- =============================================
CREATE PROCEDURE [dbo].[UpdRubricPlanType]
	 @RubricPlanTypeID int 	
    ,@IsActive bit    
    ,@CreatedByID nchar(6)    
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE RubricPlanType 
	SET 		
		IsActive=@IsActive,
		LastUpdatedByID=@CreatedByID,
		LastUpdatedDate=GETDATE()	
	WHERE RubricPlanTypeID = @RubricPlanTypeID
	
	
END
GO
