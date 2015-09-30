SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Insert/Update into RubricPlanAvailablePlan for New Job in Table [RubricPlanAvailablePlan]
-- =============================================
CREATE PROCEDURE [dbo].[insUpdRubricPlanAvailablePlanForNewJob]		
	 @AvailablePlanID int	
    ,@AvaliablePlanTypeID int
    ,@AvailableIsMultiYear bit 
    ,@IsProvEmplClass bit
    ,@NewJobRubricID int          
    ,@IsActive bit
    ,@CreatedByID nchar(6)
    ,@ReturnAvailablePlanID int =null OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	If @AvailablePlanID =0
	Begin
		INSERT INTO RubricPlanAvailablePlan(											
											AvaliablePlanTypeID,IsMultiYear,
											IsProvEmplClass,IsNewJob,NewJobRubricID,
											IsActive,CreatedByID,CreatedDate)
			VALUES(
				@AvaliablePlanTypeID,@AvailableIsMultiYear,
				@IsProvEmplClass,'true',@NewJobRubricID,
				@IsActive,@CreatedByID,GETDATE())
		
		Set @ReturnAvailablePlanID = SCOPE_IDENTITY();
	End
	Else
	Begin
		UPDATE RubricPlanAvailablePlan 
		SET 
			AvaliablePlanTypeID =@AvaliablePlanTypeID,
			IsMultiYear=@AvailableIsMultiYear,
			IsProvEmplClass= @IsProvEmplClass,
			NewJobRubricID = @NewJobRubricID,
			IsActive=@IsActive,			
			LastUpdatedByID=@CreatedByID,
			LastUpdateDate=GETDATE()
		OUTPUT INSERTED.AvailablePlanID
		WHERE AvailablePlanID = @AvailablePlanID
		
		Set @ReturnAvailablePlanID= SCOPE_IDENTITY();
	End	




END
GO
