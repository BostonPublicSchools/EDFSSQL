SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[getEmplCountByEvaluatorIDNew]
	@EvaluatorID AS nchar(6)
	,@UserRoleID as int
AS
BEGIN
	SET NOCOUNT ON;
	--declare @EvaluatorID as nchar(6)
	--declare @UserRoleID as int
	--set @EvaluatorID = '036008'
	--set @UserRoleID = 1
		
		SELECT distinct
			COUNT(e.EmplID) as EmplCount
		FROM Empl AS e (nolock)
		Join EmplEmplJob as ej (nolock) on e.EmplID = ej.EmplID
										AND ej.IsActive=1
		LEFT OUTER JOIN EmplExceptions as emplEx (nolock) on emplEx.EmplJobID = ej.EmplJobID
		JOIN RubricHdr as rh (nolock) on ej.RubricID = rh.RubricID
		
		WHERE 
			e.EmplActive =1
		AND  (   ((CASE 
					WHEN (emplEx.MgrID IS NOT NULL)
					THEN emplEx.MgrID
					ELSE ej.MgrID
				END = @EvaluatorID) AND @UserRoleID = 1  )
			OR
			(@EvaluatorID in (select 
					s.EmplID
				from 
					SubevalAssignedEmplEmplJob as ase (nolock) 
				join SubEval s (nolock) on ase.SubEvalID = s.EvalID 
				and s.EvalActive = 1
				where
					ase.EmplJobID = ej.EmplJobID					
				and ase.isActive = 1
				and ase.isDeleted = 0) and @UserRoleID = 2)
			OR
			(ej.EmplID = @EvaluatorID and @UserRoleID = 3)
		)			

END

GO
