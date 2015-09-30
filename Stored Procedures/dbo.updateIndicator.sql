SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[updateIndicator] 
	@ParentIndicatorID AS int = null
	,@StandardID AS int = null
	,@IndicatorText AS nvarchar(max) = null
	,@IndicatorDesc AS nvarchar(max) = null
	,@IsActive As bit = null
	,@UserID AS nchar(6) = null
	,@IndicatorID	AS int = null
	,@IndicatorSortOrder as int
AS
BEGIN
	SET NOCOUNT ON;

    UPDATE RubricIndicator
	SET
	 StandardID = @StandardID
	 ,ParentIndicatorID = @ParentIndicatorID
	 ,IndicatorText = @IndicatorText
	 ,IndicatorDesc = @IndicatorDesc
	 ,LastUpdatedByID = @UserID
	 ,isActive = @IsActive
	 ,LastUpdatedDt = GETDATE()
	 ,SortOrder = @IndicatorSortOrder
	WHERE
		IndicatorID = @IndicatorID
		
	--update the text in codeLookUp when there is any change.
	IF @ParentIndicatorID != 0  
	BEGIN 
		UPDATE CodeLookUp
		SET CodeText = @IndicatorText,
			CodeActive = @IsActive,
			LastUpdatedByID = '000000',
			LastUpdatedDt = GETDATE()
		WHERE CodeType = 'GoalTag' and  Code ='elt'+CONVERT(nvarchar(10), @IndicatorID)
			
	END		
END
GO
