SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Insert new Planeddate 
--			  : Update existing Planenddate
-- =============================================
CREATE PROCEDURE [dbo].[insUpdRubricPlanTypeEndDate]	
	  @PlanEndDateID int 
	 ,@RubricPlanTypeID int     
    ,@EndTypeID int
    ,@PlanEndDateTypeID int
    ,@DefaultPlanEndDate nchar(5)
    ,@DefaultPlanEndDateMax nchar(5)
    ,@DefaultFormativeValue nchar(10)
    ,@IsActive bit    
    ,@CreatedByID nchar(6)
    ,@ReturnPlanEndDateID int =null OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

if(@PlanEndDateID = 0 )
Begin
	INSERT INTO RubricPlanTypeEndDate (RubricPlanTypeID,EndTypeID,PlanEndDateTypeID,DefaultPlanEndDate,DefaultFormativeValue,IsActive,CreatedByID,CreatedDate,DefaultPlanEndDateMax)
		VALUES(@RubricPlanTypeID,@EndTypeID,@PlanEndDateTypeID,@DefaultPlanEndDate,@DefaultFormativeValue,@IsActive,@CreatedByID,GETDATE(),@DefaultPlanEndDateMax)
	
	set @ReturnPlanEndDateID = SCOPE_IDENTITY();
End
else
begin
	UPDATE RubricPlanTypeEndDate 
	SET 
		EndTypeID=@EndTypeID,
		PlanEndDateTypeID =@PlanEndDateTypeID,
		DefaultPlanEndDate=@DefaultPlanEndDate,
		DefaultFormativeValue=@DefaultFormativeValue,
		DefaultPlanEndDateMax=@DefaultPlanEndDateMax,
		IsActive=@IsActive,
		LastUpdatedByID=@CreatedByID,
		LastUpdatedDate=GETDATE()
	OUTPUT INSERTED.PlanEndDateID
	WHERE PlanEndDateID = @PlanEndDateID
	
	set @ReturnPlanEndDateID= SCOPE_IDENTITY();
end

END


GO
