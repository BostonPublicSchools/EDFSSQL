SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 02/274/2013
-- Description:	Updates employee's rubric ID
-- =============================================
CREATE PROCEDURE [dbo].[updEmplRubric]
	@EmplJobID	AS int = null
	,@UserID	AS nchar(6) = null
	,@RubricID as int = null
	,@RubricOverrideReason as nvarchar(100) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	update EmplEmplJob
	set
		RubricID = @RubricID
		,RubricOverrideReason = @RubricOverrideReason
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	where
		EmplJobID = @EmplJobID

END
	
GO
