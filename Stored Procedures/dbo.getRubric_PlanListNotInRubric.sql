SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Gets all plans that can be associated with given RubricID
-- =============================================
CREATE PROCEDURE [dbo].[getRubric_PlanListNotInRubric]		
	@RubricID int =null
AS
BEGIN
	SET NOCOUNT ON;

 SELECT 
	 CodeID 
	,CodeText
FROM CodeLookUp cdPl
WHERE cdPl.CodeType = 'PlanType'
	AND CodeActive = 1
	AND cdPl.CodeID NOT IN (
		SELECT PlanTypeID
		FROM RubricPlanType
		WHERE RubricID = @RubricID
			AND IsActive =1 
		)

END



GO
