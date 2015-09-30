SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[getActiveEmplPlanByEmplID]
@ncEmplID as nchar(6)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	ep.PlanID as PlanID
			,ep.PlanTypeID 
			,cl.CodeText as PlanType
			,CASE  
			WHEN ep.PlanStartDt is NULL THEN (cl.CodeText + ' ' + isnull(CONVERT(varchar, ep.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, ep.PlanSchedEndDt, 101),''))
			WHEN  ep.PlanStartDt is not NULL THEN cl.CodeText + ' ' + isnull(CONVERT(varchar, ep.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, ep.PlanSchedEndDt, 101),'')   --+ ' (' + CAST(DATEDIFF(day,  p.PlanStartDt, (CASE WHEN p.PlanActive = 0 and p.PlanEndDate IS NOT NULL and p.PlanEndDate != p.PlanEndDt THEN  p.PlanEndDate ELSE  p.PlanEndDt END)) as varchar(10))  + ' Days)' 
			else (cl.CodeText + ' ' + isnull(CONVERT(varchar, ep.PlanStartDt, 101),'') + ' - ' + isnull(CONVERT(varchar, ep.PlanSchedEndDt, 101),''))
			END AS PlanLabel
			,(SELECT ISNULL(e1.NameLast, '')+ ', ' +ISNULL(e1.NameFirst,'')+ ' '+ISNULL(e1.NameMiddle,'') FROM Empl e1 WHERE e1.EmplID = ep.SubEvalID) as SubEvalName
			
	FROM EmplPlan ep
	LEFT JOIN EmplEmplJob eej on ep.EmplJobID = eej.EmplJobID
	left join CodeLookUp cl on cl.CodeID = ep.PlanTypeID
	WHERE ep.PlanActive = 1 and eej.EmplID = @ncEmplID
		
END
GO
