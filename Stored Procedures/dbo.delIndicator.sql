SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[delIndicator]
	@IndicatorID	AS int = null
	,@UserID AS nchar(6) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE RubricIndicator
	SET
		IsDeleted = 1
		,IsActive = 0
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		IndicatorID = @IndicatorID
		

	--Inactivate the element in codelookup for the goaltag when its inactivated in rubric management screen
	IF((SELECT ParentIndicatorID FROM RubricIndicator WHERE IndicatorID = @IndicatorID) != 0)
	BEGIN 
		UPDATE CodeLookUp 
		SET CodeActive = 0,
			LastUpdatedByID = '000000',
			LastUpdatedDt = GETDATE()
		WHERE CodeType = 'GoalTag' and  Code ='elt'+CONVERT(nvarchar(10), @IndicatorID)
	END
			
END

GO
