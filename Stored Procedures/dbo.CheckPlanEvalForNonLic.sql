SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 04/02/2013
-- Description:	Create new plan and eval if the plan doesnt 
-- exist for non lic users.
-- =============================================
CREATE PROCEDURE [dbo].[CheckPlanEvalForNonLic]
	@ncUserID as nchar(6),
	@UserRoleID as int
AS
BEGIN

DECLARE @PlanID as int, @EvalID as int
DECLARE @EmplJobID as int
DECLARE @PlanTypeID as int
SELECT @PlanTypeID =  CodeID FROM CodeLookUp WHERE CodeType='PlanType' and CodeText='Self-Directed'
DECLARE nonlic_cursor cursor for (SELECT 		
									   ep.PlanID   
									   ,eval.EvalID
									   ,ej.EmplJobID	   
									FROM Empl e (NOLOCK)
									LEFT OUTER JOIN EmplEmplJob AS ej	(NOLOCK) ON e.EmplID = ej.EmplID
																				AND ej.IsActive = 1
									LEFT OUTER JOIN EmplPlan AS ep(NOLOCK) ON ep.EmplJobID = ej.EmplJobID and ep.PlanActive = 1										
									LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
									LEFT OUTER JOIN RubricHdr as rh (nolock) on ej.RubricID = rh.RubricID
									LEFT OUTER JOIN (SELECT
														PlanID
														,MAX(EvalID) AS EvalID
													FROM 
														Evaluation (NOLOCK)				
													GROUP BY
														PlanID) AS  eval ON  ep.PlanID = eval.PlanID
									LEFT OUTER JOIN (SELECT
														EvalID
														,OverallRatingID
														,EvalDt
														,IsSigned
														,EditEndDt
														,EvalTypeID
														,EvalRubricID
														,EvaluatorsSignature
														,EvaluatorSignedDt
													FROM 
														Evaluation (NOLOCK)
													WHERE
														IsDeleted = 0) AS  ed ON  eval.EvalID = ed.EvalID
									LEFT OUTER JOIN CodeLookUp	AS eor (NOLOCK) ON ed.OverallRatingID = eor.CodeID
									LEFT OUTER JOIN CodeLookUp	AS et (NOLOCK) ON ed.EvalTypeID = et.CodeID					
									WHERE 
										e.EmplActive = 1
										AND (   ((CASE 
														WHEN (emplEx.MgrID IS NOT NULL)
														THEN emplEx.MgrID
														ELSE ej.MgrID
													END = @ncUserId) AND @UserRoleID = 1)
												OR
												(@ncUserId in (select 
														s.EmplID
													from 
														SubevalAssignedEmplEmplJob as ase (nolock) 
													join SubEval s (nolock) on ase.SubEvalID = s.EvalID
													where
														ase.EmplJobID = ej.EmplJobID
													and ase.isActive = 1
													and ase.isDeleted = 0) and @UserRoleID = 2)	
												OR
												(ej.EmplID = @ncUserId and @UserRoleID = 3)							
											)
										and rh.Is5StepProcess = 1 and (ep.PlanID is null or eval.EvalID is null)
										);

--OPEN nonlic_cursor
--FETCH NEXT FROM nonlic_cursor INTO @PlanID, @EvalID, @EmplJobID
--WHILE @@FETCH_STATUS = 0
--BEGIN
--	DECLARE @NewPlanId as int 
--	SET @NewPlanId = @PlanID
--    IF @PlanID IS null
--    BEGIN
		
--		INSERT INTO EmplPlan (EmplJobID, PlanYear, PlanTypeID, PlanStartDt, PlanEndDt, PlanActive,SubEvalID, PlanEditLock, LastUpdatedByID, LastUpdatedDt, CreatedByID, CreatedByDt)
--						VALUES (@EmplJobID, 1, @PlanTypeID, Convert(DateTime,'2013-07-01'), Convert(DateTime, '2014-06-01'), 1,@ncUserID ,0, @ncUserID, GETDATE(), @ncUserID, GETDATE()) 
		
--		SET @NewPlanId = SCOPE_IDENTITY();
--    END
--    IF @EvalID IS NULL
--    BEGIN
--		DECLARE @EvalRubricID as int
--		SET @EvalRubricID = (SELECT eej.RubricID from EmplEmplJob eej left join EmplPlan ep on ep.EmplJobID = eej.EmplJobID where ep.PlanID = @NewPlanId)
		
--		DECLARE @EvalTypeID as int
--		SELECT @EvalTypeID =  CodeID FROM CodeLookUp WHERE CodeType='EvalType' and CodeText='Summative Evaluation'
		
--		INSERT INTO Evaluation(PlanID,EvalTypeID,EvalDt, EditEndDt, IsSigned,CreatedByID,LastUpdatedByID,LastUpdatedDt,CreatedDt,EvalRubricID)
--				VALUES (@NewPlanId,@EvalTypeID,GETDATE(),NULL, 0,@ncUserID,@ncUserID,GETDATE(),GETDATE(), @EvalRubricID)					
--    END
    
--FETCH next FROM nonlic_cursor INTO @PlanID, @EvalID, @EmplJobID
--END
--CLOSE nonlic_cursor;
--DEALLOCATE nonlic_cursor; 		
END	
GO
