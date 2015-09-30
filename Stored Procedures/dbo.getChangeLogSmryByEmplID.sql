SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devi, Ganesan	
-- Create date: 10/10/2013
-- Description:	get the change log details by emplID
-- =============================================
CREATE PROCEDURE [dbo].[getChangeLogSmryByEmplID]		
	@ncEmplID as nvarchar(6)
AS
BEGIN
	SET NOCOUNT ON;

with cteFilterChangeLog As
(
	SELECT cl.TableName [DBTableName], 
		   cl.LogID,
		   cl.EventDt,
		   cl.LoggedEvent,
		   cl.PreviousText,
		   cl.NewText,		
		   cl.CreatedByID,
		   em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '') + ' (' + em.EmplID + ')' as CreatedByName,
		   cl.CreatedByDt,
		   cl.LastUpdatedByID,
		   em1.NameLast + ', ' + em1.NameFirst + ' ' + ISNULL(em1.NameMiddle, '') + ' (' + em1.EmplID + ')' as LastUpdatedName,
		   cl.LastUpdatedDt,
		   cl.IdentityID ,		   
		   ( CASE 
				WHEN cl.TableName='Activity' THEN 'Admin Activity'
				WHEN cl.TableName='Empl' THEN 'Employee'
				WHEN cl.TableName='EmplEmplJob' THEN 'Employee Job'
				WHEN cl.TableName='EmplPlan' THEN 'Employee Plan'
				WHEN cl.TableName='Evidence' THEN 'Plan Evidence'
				WHEN cl.TableName='EmplPlanEvidence' THEN 'Plan Evidence'
				WHEN cl.TableName='EvaluationPrescription' THEN 'Evaluation Prescription'
				WHEN cl.TableName='EvaluationStandardRating' THEN 'Evaluation Standard'				
				WHEN cl.TableName='GoalActionStep' THEN 'Plan ActionSteps'
				WHEN cl.TableName='GoalEvaluationProgress' THEN 'Evaluation'
				WHEN cl.TableName='ObservationDetail' THEN 'Plan Observation'
				WHEN cl.TableName='ObservationHeader' THEN 'Plan Observation'
				WHEN cl.TableName='PlanGoal' THEN 'Plan Goal'
				WHEN cl.TableName='PlanSelfAsmt' THEN 'Plan SelfAssessment'
				Else cl.TableName				
				END   )[TableName]
		   
	FROM Changelog cl
	LEFT OUTER JOIN Empl em on em.EmplID = cl.CreatedByID
	LEFT OUTER JOIN Empl em1 on em1.EmplID = cl.LastUpdatedByID
	WHERE cl.EmplID = @ncEmplID or cl.IdentityEmplID = @ncEmplID
)

	SELECT 
		cl.TableName ,
		cl.LogID,
		cl.EventDt,
		cl.LoggedEvent,
		cl.PreviousText,
		cl.NewText,
		cl.CreatedByID,cl.CreatedByName,cl.CreatedByDt,cl.LastUpdatedByID,cl.LastUpdatedName,cl.LastUpdatedDt, cl.IdentityID
	FROM cteFilterChangeLog cl
	WHERE 
		not (ISNUMERIC(SUBSTRING(cl.NewText,0,4))=1  And PATINDEX('%[^0-9]%',SUBSTRING(cl.NewText,0,4) ) =0)	
UNION
	SELECT 
		cl.TableName,
		cl.LogID,
		cl.EventDt,
		cl.LoggedEvent,-- cl.PreviousText,cl.NewText,
		(case WHEN 
				cl.DBTableName in('EmplPlan','PlanSelfAsmt','PlanGoal','GoalActionStep','Evaluation','GoalEvaluationProgress','EvaluationStandardRating') AND
				LEN(dbo.udf_StripHTML(cl.PreviousText))<4 AND LEN(dbo.udf_StripHTML(cl.PreviousText))>0 And isnumeric(REPLACE(dbo.udf_StripHTML(cl.PreviousText),' ','' ) )=1 
			THEN CAST( (select codetext from CodeLookUp where CodeID= CAST((SUBSTRING(PreviousText,0,4)) AS int)  )  AS VARCHAR)
			WHEN 
				cl.DBTableName in('Emplempljob') AND 
				LEN(dbo.udf_StripHTML(cl.PreviousText))<4 AND LEN(dbo.udf_StripHTML(cl.PreviousText))>0 And isnumeric(REPLACE(dbo.udf_StripHTML(cl.PreviousText),' ','' ) )=1 
			THEN  CAST( (select RubricName from RubricHdr where RubricID= CAST((SUBSTRING(PreviousText,0,4)) AS int)  )  AS VARCHAR)
		else CAST( dbo.udf_StripHTML(cl.PreviousText)  AS varchar) end) AS PreviousText,
		
	   (case WHEN 
				cl.DBTableName in('EmplPlan','PlanSelfAsmt','PlanGoal','GoalActionStep','Evaluation','GoalEvaluationProgress','EvaluationStandardRating') AND
				LEN(dbo.udf_StripHTML(cl.NewText))<4 AND LEN(dbo.udf_StripHTML(cl.NewText))>0 And isnumeric(REPLACE(dbo.udf_StripHTML(cl.NewText),' ','' ) )=1 
			THEN CAST( (select codetext from CodeLookUp where CodeID= CAST((SUBSTRING(NewText,0,4)) AS int)  )  AS VARCHAR)
			WHEN 
				cl.DBTableName in('Emplempljob') AND 
				LEN(dbo.udf_StripHTML(cl.NewText))<4 AND LEN(dbo.udf_StripHTML(cl.NewText))>0 And isnumeric(REPLACE(dbo.udf_StripHTML(cl.NewText),' ','' ) )=1 
			THEN  CAST( (select RubricName from RubricHdr where RubricID= CAST((SUBSTRING(NewText,0,4)) AS int)  )  AS VARCHAR)
		else CAST( dbo.udf_StripHTML(cl.NewText)  AS varchar) end) AS NewText,
				
			cl.CreatedByID,cl.CreatedByName,cl.CreatedByDt,cl.LastUpdatedByID,cl.LastUpdatedName,cl.LastUpdatedDt, cl.IdentityID
	FROM cteFilterChangeLog cl
	WHERE 
		(ISNUMERIC(SUBSTRING(cl.NewText,0,4))=1  And PATINDEX('%[^0-9]%',SUBSTRING(cl.NewText,0,4) ) =0)
	ORDER BY CreatedByDt DESC, TableName Asc, IdentityID desc



END


GO
