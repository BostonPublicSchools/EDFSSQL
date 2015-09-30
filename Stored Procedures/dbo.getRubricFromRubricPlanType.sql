SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Gets all the distinct Rubric associated with any Plan
-- =============================================
CREATE PROCEDURE [dbo].[getRubricFromRubricPlanType]				
AS
BEGIN
	SET NOCOUNT ON;

Select RubricID, RubricName,IsActive from
(
SELECT 
	DISTINCT rh.RubricID ,rh.RubricName, rpt.IsActive, 
	RANK() over (partition by rh.RubricID order by rpt.IsActive desc) as 'RankOrder' --isActiveAny RubricPlan Association
FROM 
	RubricHdr rh
	INNER JOIN RubricPlanType rpt ON rh.RubricID = rpt.RubricID
WHERE 
	rh.IsDeleted = 0
	AND rh.IsActive = 1
	AND rh.Is5StepProcess = 1
	--AND rpt.IsActive = 1
) tblRubrics
WHERE tblRubrics.RankOrder=1
	
End	
GO
