SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Insert/Update into RubricPlanAvailablePlan in Table [RubricPlanAvailablePlan]
-- =============================================
CREATE PROCEDURE [dbo].[insUpdRubricPlanAvailablePlan]	
	 @AvailablePlanID int
	,@RubricPlanTypeID int	
    ,@RubricPlanIsMultiYear bit = Null
    ,@EvalTypeID  int =null
    ,@OverallRatingID int =null
    ,@AvaliablePlanTypeID int
    ,@AvailableIsMultiYear bit =null
    --,@EmplClassID = null
    ,@IsProvEmplClass bit = null     
    ,@IsJobChange bit =null
    ,@IsActive bit
    ,@CreatedByID nchar(6)
    ,@ReturnAvailablePlanID int =null OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

IF @IsJobChange is null or @IsJobChange = 0
BEGIN
	If @AvailablePlanID =0
	Begin
		INSERT INTO RubricPlanAvailablePlan(RubricPlanTypeID,RubricPlanIsMultiYear,
											EvalTypeID,OverallRatingID,
											AvaliablePlanTypeID,IsMultiYear,
											IsProvEmplClass,IsJobChange,IsActive,
											CreatedByID,CreatedDate)
			VALUES(@RubricPlanTypeID,@RubricPlanIsMultiYear,
				@EvalTypeID,@OverallRatingID,
				@AvaliablePlanTypeID,@AvailableIsMultiYear,
				@IsProvEmplClass,'false',@IsActive,
				@CreatedByID,GETDATE())
		
		Set @ReturnAvailablePlanID = SCOPE_IDENTITY();
	End
	Else
	Begin
		UPDATE RubricPlanAvailablePlan 
		SET 
			OverallRatingID = @OverallRatingID,
			AvaliablePlanTypeID =@AvaliablePlanTypeID,
			IsMultiYear=@AvailableIsMultiYear,
			IsActive=@IsActive,
			LastUpdatedByID=@CreatedByID,
			LastUpdateDate=GETDATE()
		OUTPUT INSERTED.AvailablePlanID
		WHERE AvailablePlanID = @AvailablePlanID
		
		Set @ReturnAvailablePlanID= SCOPE_IDENTITY();
	End	
END

ELSE -- IF @IsJobChange is not null
BEGIN
	If @AvailablePlanID =0
	Begin
		INSERT INTO RubricPlanAvailablePlan(RubricPlanTypeID,RubricPlanIsMultiYear,											
											AvaliablePlanTypeID,IsMultiYear,
											IsProvEmplClass,IsJobChange,IsActive,
											CreatedByID,CreatedDate)
			VALUES(@RubricPlanTypeID,@RubricPlanIsMultiYear,				
				@AvaliablePlanTypeID,@AvailableIsMultiYear,
				@IsProvEmplClass,@IsJobChange,@IsActive,
				@CreatedByID,GETDATE())
		
		Set @ReturnAvailablePlanID = SCOPE_IDENTITY();
	End
	Else
	Begin
		UPDATE RubricPlanAvailablePlan 
		SET 
			AvaliablePlanTypeID =@AvaliablePlanTypeID,
			IsMultiYear=@AvailableIsMultiYear,
			IsActive=@IsActive,
			LastUpdatedByID=@CreatedByID,
			LastUpdateDate=GETDATE()
		OUTPUT INSERTED.AvailablePlanID
		WHERE AvailablePlanID = @AvailablePlanID
		
		Set @ReturnAvailablePlanID= SCOPE_IDENTITY();
	End

END


END
GO
