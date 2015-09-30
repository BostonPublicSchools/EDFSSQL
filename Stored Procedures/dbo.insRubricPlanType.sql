SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Insert RubricPlanType in Table [RubricPlanType]
-- =============================================
CREATE PROCEDURE [dbo].[insRubricPlanType]		
	 @RubricID int 
    ,@PlanTypeID int
    ,@IsActive bit
    ,@CreatedByID nchar(6)
    ,@RubricPlanTypeID int =null OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

if not exists(select top 1 * from RubricPlanType where RubricID=@RubricID and PlanTypeID=@PlanTypeID)
begin
	INSERT INTO RubricPlanType (RubricID,PlanTypeID,IsActive,CreatedByID,CreatedDate)
		VALUES(@RubricID,@PlanTypeID,@IsActive,@CreatedByID,GETDATE())
	
	Set @RubricPlanTypeID = SCOPE_IDENTITY();
end
else
begin
	update RubricPlanType 
		set IsActive=1,
		LastUpdatedByID=@CreatedByID,
		LastUpdatedDate=GETDATE()
	OUTPUT INSERTED.RubricPlanTypeID
	WHERE RubricID=@RubricID and PlanTypeID=@PlanTypeID

	Set @RubricPlanTypeID= SCOPE_IDENTITY();
end

END


GO
