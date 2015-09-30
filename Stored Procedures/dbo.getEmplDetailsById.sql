SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 08/20/2012
-- Description:	Get employee details by id
-- =============================================
CREATE PROCEDURE [dbo].[getEmplDetailsById]
  @emplID as nchar(6)
AS
BEGIN 
SET NOCOUNT ON;
 	SELECT e.EmplID,
		   e.NameFirst,
		   e.NameLast,
		   e.NameMiddle,
		   e.EmplActive,
		   e.IsAdmin,
		   e.Sex,
		   e.BirthDt, 
		   e.Race,
		   (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = e.PrimaryEvalID) AS PrimaryEvalName,
		   e.PrimaryEvalID,
		   e.IsContractor,
		   e.HasReadOnlyAccess,
		   ej.EmplJobID,
		   ej.JobCode,
		   s.EvalID,
		   (CASE 
			WHEN (ex.MgrID IS NOT NULL)
			THEN ex.MgrID
			ELSE ej.MgrID
			END) as MgrID,
			CASE
				when s.EmplID IS NULL
				THEN CASE
							WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
							ELSE ej.MgrID
						END
				ELSE s.EmplID
			END SubEvalID,
			ej.DeptID,	
		   ej.IsActive as JobActive,   
		   ej.EmplRcdNo,
		   ej.CreatedByDt as JobCreatedByDt,
		   (CASE 
			WHEN (ex.MgrID IS NOT NULL)
			THEN (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = ex.MgrID) 
			ELSE (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = ej.MgrID)
			END) as ManagerName,		   
		   (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = s.EmplID) as SubEvalName,
		   j.JobName ,
		   j.UnionCode,
		   d.DeptName,
		   d.IsSchool as IsSchool,
		   (CASE 
			WHEN (ex.MgrID IS NULL)
			THEN 0
			ELSE 1
			END) AS ExMngrExists			
		   ,ej.FTE
		   ,ej.RubricOverrideReason
		   ,r.RubricID
		   ,r.RubricName
		   ,r.Is5StepProcess
		   ,r.IsDESELic
		   ,ej.JobEntryDate
		   ,e.ExpectedReturnDate
		   ,e.OriginalHireDate
		   ,ej.EmplClass
		   ,ISNULL(ec.CodeText, '') + ' (' + ej.EmplClass + ')' as EmplClassDesc
		   ,(CASE WHEN dbo.funcGetPrimaryEmplJobByEmplID(@emplID) = ej.EmplJobID THEN 1 ELSE 0 END) as IsPrimaryJob
		   ,Cast( (CASE WHEN e.EmplActive=0 AND e.EmplActiveDt IS NULL THEN 0 
				  WHEN e.EmplActive=0 AND EmplActive IS NOT NULL 
					THEN
						(Case When DATEDIFF(dd, GETDATE(),e.EmplActiveDt) > -1 
							and DATEDIFF(dd, GETDATE(),e.EmplActiveDt)< 31 then 1 else 0 End)				  
				  ELSE 0 END ) As bit) HasTempActiveAccess	
		 , CONVERT(varchar, (case when e.EmplActiveDt is null then '' else convert(nvarchar,e.EmplActiveDt )end)) EmplActiveTillDate
	FROM Empl e
	LEFT OUTER JOIN EmplEmplJob ej (nolock) ON ej.EmplID = e.EmplID 
	left join RubricHdr r on ej.RubricID = r.RubricID
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
													and ase.isActive = 1
													and ase.isDeleted = 0
													and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
									and s.EvalActive = 1	
	LEFT OUTER JOIN EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = ej.EmplJobID
	LEFT OUTER JOIN EmplJob j (nolock) ON j.JobCode = ej.JobCode
	LEFT OUTER JOIN Department d (nolock) ON d.DeptID  = ej.DeptID
	LEFT OUTER JOIN EmplExceptions ex (nolock) on ex.EmplID = ej.EmplID and ex.EmplJobID = ej.EmplJobID
	LEFT JOIN CodeLookUp ec (nolock) on RTRIM(LTRIM(ej.EmplClass)) = ec.Code
									and ec.CodeType = 'EmplClass'
									and ec.CodeActive =  1
    WHERE e.EmplID = @emplID 
    ORDER BY ej.IsActive desc, ej.EmplRcdNo, ej.FTE
END
GO
