SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[addIndicator] 
	 @ParentIndicatorID AS int = null
	,@StandardID AS int = null
	,@IndicatorText AS nvarchar(max) = null
	,@IndicatorDesc AS nvarchar(max) = null
	,@IsActive As bit = null
	,@UserID AS nchar(6) = null

AS
BEGIN

    IF @StandardID = -1
    BEGIN
    SELECT @StandardID = StandardID FROM RubricIndicator WHERE IndicatorID = @ParentIndicatorID 
    END    
	SET NOCOUNT ON;
		
	INSERT INTO RubricIndicator (StandardID, ParentIndicatorID, IndicatorText, IndicatorDesc,CreatedByID, CreatedDt, LastUpdatedByID,LastUpdatedDt, isDeleted, isActive)
	VALUES (@StandardID, @ParentIndicatorID, @IndicatorText, @IndicatorDesc, @UserID, GETDATE(), @UserID, GETDATE(), 0, @IsActive) 
	
	IF @ParentIndicatorID != 0
	---insert the codelookup for goalTags. when new element is created.
	BEGIN
		DECLARE @RubricID int
		DECLARE @newIndicatorID int
		SELECT @newIndicatorID = SCOPE_IDENTITY()
		SELECT @RubricID = RubricID FROM RubricStandard WHERE StandardID = @StandardID		
		
		INSERT INTO CodeLookUp(CodeType, Code, CodeText, CodeSortOrder, CodeActive, CodeSubText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IsManaged)
		SELECT 'GoalTag', 'elt'+Convert(nvarchar(20),re.IndicatorId), re.IndicatorText, 
							CASE WHEN (SELECT MAX(CodeSortOrder)+1 from CodeLookUp where CodeSubText = rh.RubricName+CONVERT(nvarchar(10), cdl.CodeID)) IS NULL THEN 0 ELSE (SELECT MAX(CodeSortOrder)+1 from CodeLookUp where CodeSubText = rh.RubricName+CONVERT(nvarchar(10), cdl.CodeID)) END,
							 1, (rh.RubricName+Convert(nvarchar(20),cdl.CodeID)) as CodeSubText, '000000', GETDATE(),'000000', GETDATE(),1  
		FROM RubricIndicator re
		JOIN RubricIndicator ri on ri.IndicatorID = re.ParentIndicatorID and ri.ParentIndicatorID = 0
		JOIN RubricStandard rs on rs.StandardID = ri.StandardID
		JOIN RubricHdr rh on rh.RubricID = rs.RubricID and rh.RubricID = @RubricID
		JOIN CodeLookUp cdl on cdl.CodeSubText = rh.RubricName and cdl.CodeText like '%Professional%'
		WHERE rh.Is5StepProcess = 0 and cdl.CodeType = 'goalType' and re.IndicatorID  = @newIndicatorID 
		ORDER BY RubricName, CodeID asc 

	END
					
END
--((SELECT MAX(CodeSortOrder) FROM CodeLookUp WHERE CodeType='GoalTag'and CodeSubText like'%'+rh.RubricName+'%' and CodeActive =1 group by CodeSubText)+1)
GO
