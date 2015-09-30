SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 03/20/2012
-- Description:	Returns List of Goals by EmplID
-- =============================================
CREATE PROCEDURE [dbo].[getEmplGoals]
	@ncEmplID AS nchar(6) = NULL
AS
BEGIN
	SET NOCOUNT ON;


	SELECT 
		ej.EmplID
		,e.NameLast + ' , ' + e.NameFirst as EmplName
		,p.PlanActive
		,p.PlanEditLock
		,p.PlanID
	--	,g.GoalID
		,p.EmplJobID
		,CONVERT(varchar, p.PlanStartDt, 101) as PlanStartDt
		,CONVERT(varchar, p.PlanSchedEndDt, 101) as PlanEndDt
		,p.PlanSchedEndDt
		,p.GoalStatusDt
		,p.GoalStatusID
		,(select CodeText from CodeLookUp where CodeID = p.GoalStatusID) as GoalStatus
		,p.PlanTypeID
		,(select Codetext from CodeLookUp where CodeID = p.PlanTypeID) as PlanType
		,isnull((select top (1) CreatedByID  from PlanGoal where CreatedByID <> @ncEmplID and PlanID = p.PlanID),@ncEmplID) as CreatedBy  
		--,g.GoalLevelID
		--,g.GoalStatusID
		--,g.GoalTypeID
		--,g.GoalText
	FROM
		EmplEmplJob AS ej 
	LEFT JOIN EmplPlan AS p 	ON ej.EmplJobID = p.EmplJobID
	--LEFT join PlanGoal as g  ON g.PlanID = p.PlanID
	Left join Empl as e on e.EmplID = ej.EmplID
	WHERE
		ej.EmplID =@ncEmplID
		AND p.PlanActive = 1

		
END

GO
