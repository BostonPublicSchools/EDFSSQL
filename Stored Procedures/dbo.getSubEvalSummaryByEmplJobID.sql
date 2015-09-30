SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 02/08/2013
-- Description:	get all subeval by empljobID
-- =============================================
CREATE PROCEDURE [dbo].[getSubEvalSummaryByEmplJobID]
 @EmplJobID int,
 @MgrID as nchar(6),
 @IsNonLic as bit = 0
AS
BEGIN
	SET NOCOUNT ON;
	


--#1.get the emplId.		
		DECLARE @EmplID as nchar(6)
		SET @EmplID = (SELECT EmplID from EmplEmplJob where EmplJobID = @EmplJobID);
		
	
--#2.the list of managers of all the active emplJob for an employee		
		DECLARE @ListOfMangerID TABLE(managerID nvarchar(6));
		INSERT INTO @ListOfMangerID 
			SELECT (CASE WHEN (ex.MgrID IS NULL OR ex.MgrID = '000000') THEN ej.MgrID ELSE ex.MgrID END) 
			FROM EmplEmplJob ej 
			LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID = ej.EmplJobID 
			WHERE ej.EmplID = @EmplID  and  ej.IsActive = 1;

--#3.Get the primary for the emplId.
		DECLARE @PrimaryCount as int = 0;
		SET @PrimaryCount = (SELECT COUNT(IsPrimary) 
								from SubevalAssignedEmplEmplJob se 
								JOIN SubEval s on s.EvalID = se.SubEvalID and s.EvalActive = 1
								where se.EmplJobID in (SELECT EmplJobID from EmplEmplJob where EmplID = @EmplID and IsActive=1)
									  AND se.IsDeleted = 0 AND se.IsActive=1	
									  and se.IsPrimary =1 and s.MgrID in (select managerID from @ListOfMangerID))	;			
	

		
--#4.All the subevals which includes all the managers for the empl, all the subeval for the logged in mangers 		
with [allEval] as (
	--#11. select managers
SELECT 
		ej.EmplJobID,
	   (CASE WHEN (ex.MgrID IS NULL OR ex.MgrID = '000000') THEN ej.MgrID ELSE ex.MgrID END) as EmplID,
	    e.NameLast + ', ' +e.NameFirst +' '+ ISNULL(e.NameMiddle, '')+' ('+e.EmplID+')' AS EmplName,
	   (CASE WHEN (ex.MgrID IS NULL OR ex.MgrID = '000000') THEN ej.MgrID ELSE ex.MgrID END) as MgrID, 	
	   1 as IsActive , 
	   0 as IsDeleted,
	   1 as IsManagers,	   
	   (case when Exists(select * from SubevalAssignedEmplEmplJob sej 
						join subeval s on s.evalID = sej.subevalID and s.EvalActive = 1
						where s.emplID = e.EmplID and sej.EmplJobID = @EmplJobID and
						 sej.IsPrimary = 1 and sej.IsActive = 1 and sej.IsDeleted=0)then 1 else 0 end )as IsPrimary,
	   1 as Is5StepProcess,
	   1 as IsNon5StepProcess,	   
	   (CASE WHEN ej.EmplJobID = dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID) THEN 1 ELSE 0 END) as IsPrimaryJobManager,					    	   	   	   
	   @PrimaryCount as PrimaryCount
FROM EmplEmplJob ej
LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID = ej.EmplJobID 
JOIN Empl e on e.EmplID =(CASE WHEN (ex.MgrID IS NULL OR ex.MgrID = '000000') THEN ej.MgrID ELSE ex.MgrID END) and e.EmplActive = 1
WHERE ej.EmplID = @EmplID and ej.IsActive = 1 

EXCEPT 

--remove the emplJob that has the same manager.
SELECT  ej.EmplJobID,
	   (CASE WHEN (ex.MgrID IS NULL OR ex.MgrID = '000000') THEN ej.MgrID ELSE ex.MgrID END) as EmplID,
	    e.NameLast + ', ' +e.NameFirst +' '+ ISNULL(e.NameMiddle, '')+' ('+e.EmplID+')' AS EmplName,
	   (CASE WHEN (ex.MgrID IS NULL OR ex.MgrID = '000000') THEN ej.MgrID ELSE ex.MgrID END) as MgrID, 	
	   1 as IsActive , 
	   0 as IsDeleted,
	   1 as IsManagers,	   
	   (case when Exists(select * from SubevalAssignedEmplEmplJob sej 
						join subeval s on s.evalID = sej.subevalID and s.EvalActive = 1
						where s.emplID = e.EmplID and sej.EmplJobID = @EmplJobID and sej.IsPrimary = 1 
						and sej.IsActive = 1 and sej.IsDeleted=0)then 1 else 0 end )as IsPrimary,
	   1 as Is5StepProcess,
	   1 as IsNon5StepProcess,	   
	   (CASE WHEN ej.EmplJobID = dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID) THEN 1 ELSE 0 END) as IsPrimaryJobManager,
	   @PrimaryCount as PrimaryCount
FROM EmplEmplJob ej
LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID = ej.EmplJobID 
JOIN Empl e on e.EmplID =(CASE WHEN (ex.MgrID IS NULL OR ex.MgrID = '000000') THEN ej.MgrID ELSE ex.MgrID END) and e.EmplActive = 1
WHERE ej.EmplID = @EmplID and ej.IsActive = 1  and ej.EmplJobID != @EmplJobID and (CASE WHEN (ex.MgrID IS NULL OR ex.MgrID = '000000') THEN ej.MgrID ELSE ex.MgrID END) = @MgrID

UNION
	--#12.select subevals for the loggedin managers
SELECT 		   	 
		   ase.EmplJobID,	
		   s.EmplID as EmplID,
		   e.NameLast + ', ' +e.NameFirst +' '+ ISNULL(e.NameMiddle, '')+' ('+e.EmplID+')' AS EmplName,
		   s.MgrID,		 
		   ase.IsActive, 
		   ase.IsDeleted,
		   0 as IsManagers,		   
		   ase.IsPrimary as IsPrimary,
		   s.Is5StepProcess,
		   s.IsNon5StepProcess,		   
		   0 as IsPrimaryJobManager,					    	   	   	   
		  @PrimaryCount as PrimaryCount	   					 
	FROM SubEval s
	LEFT OUTER JOIN SubevalAssignedEmplEmplJob ase on ase.SubEvalID = s.EvalID 
					and ase.EmplJobID = @EmplJobID AND ase.IsDeleted = 0 AND ase.IsActive=1						
	JOIN Empl e on e.EmplID = s.EmplID and e.EmplActive = 1
	WHERE s.MgrID = @MgrID and s.EvalActive = 1 and s.emplID not in (select managerId from @ListOfMangerID)

UNION

 --#13. select emplemplJob record for all the other managers and the subevals.
SELECT 		   	 
		   ase.EmplJobID,	
		   s.EmplID as EmplID,
		   e.NameLast + ', ' +e.NameFirst +' '+ ISNULL(e.NameMiddle, '')+' ('+e.EmplID+')' AS EmplName,
		   s.MgrID,		 
		   ase.IsActive,  
		   ase.IsDeleted,
		   0 as IsManagers, 		   
		   ase.IsPrimary as IsPrimary,
		   s.Is5StepProcess,
		   s.IsNon5StepProcess,		   
		   0 as IsPrimaryJobManager,
		   @PrimaryCount as PrimaryCount
	FROM SubEval s
	JOIN SubevalAssignedEmplEmplJob ase on ase.SubEvalID = s.EvalID 
					AND ase.IsDeleted = 0 AND ase.IsActive=1
	JOIN (SELECT ((CASE WHEN (ex.MgrID IS NULL OR ex.MgrID = '000000') THEN ej.MgrID ELSE ex.MgrID END))as ManagerID,
												  ej.EmplJobID
	    										FROM EmplEmplJob ej
												LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID = ej.EmplJobID 
												WHERE ej.EmplID = @EmplID and ej.IsActive = 1) as filEmplJob on filEmplJob.EmplJobID = ase.EmplJobID				
	JOIN Empl e on e.EmplID = s.EmplID	and e.EmplActive = 1
	WHERE s.EvalActive = 1 and filEmplJob.ManagerID != @MgrID and s.IsEvalManager = 0 and s.MgrID in (select ManagerID from @ListOfMangerID)
)		
		
select distinct * from allEval 
ORDER BY IsManagers desc, IsPrimaryJobManager desc, IsPrimary desc, IsActive desc, MgrId, EmplName		

	
END




GO
