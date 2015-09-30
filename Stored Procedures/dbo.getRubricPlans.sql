SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Gets all plans associated with given RubricID
-- =============================================
CREATE PROCEDURE [dbo].[getRubricPlans]		
	@RubricID int =null
AS
BEGIN
	SET NOCOUNT ON;

SELECT 
	rpt.RubricPlanTypeID
	,rpt.RubricID
	,rh.RubricName
	, rpt.IsActive
	,rpt.PlanTypeID
	,cdpl.CodeText [PlanType]
	,rpt.EmplClassList
FROM 
	RubricPlanType rpt
	inner join CodeLookUp cdPl on rpt.PlanTypeID = cdPl.CodeID and cdPl.CodeType='PlanType' and CodeActive=1
	inner join RubricHdr rh on rh.RubricID=rpt.RubricID
	
WHERE rpt.RubricID = @RubricID
	--And rpt.IsActive=1 

END


GO
