SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 03/14/2012
-- Description:	it returns the list of sub eval and number of employees assigned him
-- =============================================
CREATE PROCEDURE [dbo].[GetSubEval_Principal]
	@ncUserId AS nchar(6) = NULL	
	,@RubricId as int = null
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
IF(@RubricId is null OR @RubricId = 0)
BEGIN	
;with [allSubEval] as(
SELECT 
		(CASE when rh.Is5StepProcess = 1 then ISNULL(COUNT(ej.EmplID), 0) else 0 end) as StepCount
		,(CASE when rh.Is5StepProcess= 0 then ISNULL(count(ej.EmplID), 0) else 0 end) as Non5StepCount
		,se.MgrID
		,se.EmplID as SubEvalID
		,se.Is5StepProcess as IsEval5StepProcess
		,se.IsNon5StepProcess as IsEvalNon5StepProcess
		,s.NameLast + ', ' + s.NameFirst + ' ' + ISNULL(s.NameMiddle, '') + ' (' + se.EmplID +')' AS SubEvalName
		,rh.Is5StepProcess		
	FROM Empl s	
	LEFT OUTER JOIN SubEval as se on s.EmplID = se.EmplID
					AND  se.MgrID = @ncUserId
					AND se.EvalActive = 1
	LEFT OUTER JOIN EmplEmplJob sej ON se.EmplID = sej.EmplID
							AND se.MgrID = sej.MgrID
							AND sej.IsActive = 1
	LEFT OUTER join SubevalAssignedEmplEmplJob ase on se.EvalID = ase.SubEvalID
														and ase.isActive = 1
													and ase.isDeleted = 0
													and ase.IsPrimary = 1
	JOIN EmplEmplJob as ej ON ase.EmplJobID = ej.EmplJobID
								AND ej.IsActive = 1	
	JOIN EmplJob as j (nolock) on ej.JobCode = j.JobCode						
	
	join RubricHdr as rh on	ej.RubricID = rh.RubricID 										
										 
	LEFT JOIN Empl e	ON  ej.EmplID = e.EmplID
							and e.EmplActive = 1
WHERE
	s.EmplActive = 1
group by 
	se.MgrID,
	se.EmplID,	
	s.NameLast + ', ' + s.NameFirst + ' ' + ISNULL(s.NameMiddle, '')	
	,rh.Is5StepProcess
	,se.Is5StepProcess
	,se.IsNon5StepProcess 	
	
UNION 
	SELECT 		
		(CASE when rh.Is5StepProcess= 1 then count(ej.EmplID) else 0 end) as StepCount
		,(CASE when rh.Is5StepProcess= 0 then count(ej.EmplID) else 0 end) as Non5StepCount		
		,@ncUserId
		,@ncUserId
		,1
		,1
		,(select s1.NameLast + ', ' + s1.NameFirst + ' ' + ISNULL(s1.NameMiddle, '') + ' (' + s1.EmplID +')' from Empl s1 where EmplID = @ncUserId) AS SubEvalName
		,rh.Is5StepProcess
		
	FROM 
		Empl e
	JOIN EmplEmplJob ej on e.EmplID = ej.EmplID						
						AND ej.IsActive = 1 						
						AND ej.EmplJobID not in (SELECT EmplJobID FROM SubevalAssignedEmplEmplJob where IsActive = 1 and IsDeleted = 0 and IsPrimary = 1)
						   /* if the record is delete or is not primary - then manager is primary*/
	JOIN EmplJob as j (nolock) on ej.JobCode = j.JobCode								
	join RubricHdr as rh on	ej.RubricID = rh.RubricID 		
	LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	WHERE
		CASE
			WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
			ELSE ej.MgrID
		END = @ncUserId
	Group by rh.Is5StepProcess
)
SELECT as1.StepCount, as1.Non5StepCount, (as1.StepCount+as1.Non5StepCount) as TotalCount, as1.MgrId, as1.SubEvalId, as1.IsEval5StepProcess,as1.IsEvalNon5StepProcess, as1.subEvalName
FROM  allSubEval as1
where
as1.MgrID = @ncUserId		
order by SubEvalName 
END

ELSE
BEGIN 
;with [allSubEval] as(
SELECT 
		(CASE when rh.Is5StepProcess = 1 then ISNULL(COUNT(ej.EmplID), 0) else 0 end) as StepCount
		,(CASE when rh.Is5StepProcess= 0 then ISNULL(count(ej.EmplID), 0) else 0 end) as Non5StepCount
		,se.MgrID
		,se.EmplID as SubEvalID
		,se.Is5StepProcess as IsEval5StepProcess
		,se.IsNon5StepProcess as IsEvalNon5StepProcess
		,s.NameLast + ', ' + s.NameFirst + ' ' + ISNULL(s.NameMiddle, '') + ' (' + se.EmplID +')' AS SubEvalName
		,rh.Is5StepProcess
	FROM Empl s	
	LEFT OUTER JOIN SubEval as se on s.EmplID = se.EmplID
					AND  se.MgrID = @ncUserId
					AND se.EvalActive = 1
	LEFT OUTER JOIN EmplEmplJob sej ON se.EmplID = sej.EmplID
							AND se.MgrID = sej.MgrID
							AND sej.IsActive = 1
	LEFT OUTER join SubevalAssignedEmplEmplJob ase on se.EvalID = ase.SubEvalID
														and ase.isActive = 1
													and ase.isDeleted = 0
													and ase.IsPrimary = 1
	JOIN EmplEmplJob as ej ON ase.EmplJobID = ej.EmplJobID
								AND ej.IsActive = 1	
	JOIN EmplJob as j (nolock) on ej.JobCode = j.JobCode						
	
	join RubricHdr as rh on	ej.RubricID = rh.RubricID									
										 
	LEFT JOIN Empl e	ON  ej.EmplID = e.EmplID
							and e.EmplActive = 1
WHERE
	s.EmplActive = 1 and rh.RubricID = @RubricId
group by 
	se.MgrID,
	se.EmplID,	
	s.NameLast + ', ' + s.NameFirst + ' ' + ISNULL(s.NameMiddle, '')	
	,rh.Is5StepProcess
	,se.Is5StepProcess
	,se.IsNon5StepProcess 	
	
UNION 
	SELECT 		
		(CASE when rh.Is5StepProcess= 1 then count(ej.EmplID) else 0 end) as StepCount
		,(CASE when rh.Is5StepProcess= 0 then count(ej.EmplID) else 0 end) as Non5StepCount		
		,@ncUserId
		,@ncUserId
		,1
		,1
		,(select s1.NameLast + ', ' + s1.NameFirst + ' ' + ISNULL(s1.NameMiddle, '') + ' (' + s1.EmplID +')' from Empl s1 where EmplID = @ncUserId) AS SubEvalName
		,rh.Is5StepProcess
		
	FROM 
		Empl e
	JOIN EmplEmplJob ej on e.EmplID = ej.EmplID						
						AND ej.IsActive = 1 						
						AND ej.EmplJobID not in (SELECT EmplJobID FROM SubevalAssignedEmplEmplJob where IsActive = 1 and IsDeleted = 0 and IsPrimary = 1)
						   /* if the record is delete or is not primary - then manager is primary*/
	JOIN EmplJob as j (nolock) on ej.JobCode = j.JobCode								
	join RubricHdr as rh on	ej.RubricID = rh.RubricID and rh.RubricID = @RubricId		
	LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	WHERE
		CASE
			WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
			ELSE ej.MgrID
		END = @ncUserId
		and rh.RubricID = @RubricId
	Group by rh.Is5StepProcess
)
SELECT as1.StepCount, as1.Non5StepCount,  (as1.StepCount+as1.Non5StepCount) as TotalCount, as1.MgrId, as1.SubEvalId, as1.IsEval5StepProcess,as1.IsEvalNon5StepProcess, as1.subEvalName 
FROM  allSubEval as1
END

end
GO
