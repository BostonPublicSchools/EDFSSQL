SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 02/06/2014
-- Description:	Update RubricPlanType based on RubricID
--				This is used to EmplClassList selected RubricID
-- =============================================
CREATE PROCEDURE [dbo].[UpdRubricPlanType_EmplClassList]
	 @RubricID int 	
    ,@EmplClassList nchar(15) = null
    ,@CreatedByID nchar(6)    
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE RubricPlanType 
	SET 		
		EmplClassList=@EmplClassList,
		LastUpdatedByID=@CreatedByID,
		LastUpdatedDate=GETDATE()	
	WHERE RubricID = @RubricID
	
	
END
GO
