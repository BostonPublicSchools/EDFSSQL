SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/17/2012
-- Description:	Determine valid user and user's rights
-- =============================================
CREATE PROCEDURE [dbo].[getUser]
	@ncUserId AS nchar(6) = NULL
	,@EmplJobID as int = 0
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ActiveEmployeeCount as int = 0
			,@IsManger as int = 0
			,@IsEmplActive as bit 
			,@HasTempActiveAccess as bit =0 -- @@HasTempActiveAccess, True till 30 days
	
	Select 
		@IsEmplActive= EmplActive
		,@HasTempActiveAccess = (Case 
									When EmplActive=0 And (DATEDIFF(dd, GETDATE(),EmplActiveDt) > -1 
															and DATEDIFF(dd, GETDATE(),EmplActiveDt)< 31)
									Then 1 Else 0 End)
	From Empl where EmplID=@ncUserId
		
	if @IsEmplActive = 1
	BEGIN
		
		select
			 @ActiveEmployeeCount = COUNT(DISTINCT ej.EmplID)
		from 
			EmplEmplJob as ej
		Left outer join EmplExceptions ex on ex.EmplJobID = ej.EmplJobID			
		join SubevalAssignedEmplEmplJob as sej on ej.EmplJobID = sej.EmplJobID
												and sej.IsActive = 1
												and sej.IsDeleted = 0
		join SubEval as s on sej.SubEvalID = s.EvalID
							and s.EvalActive = 1
							and s.EmplID = @ncUserId
							and s.MgrID =(case when ex.MgrID is not null then ex.MgrID else ej.MgrID end)
							and s.MgrID in (select EmplID from Empl where EmplActive = 1)
		where
			ej.IsActive = 1

		select 
			@IsManger = COUNT(distinct MgrID)
		From
			Department
		where
			MgrID = @ncUserId
				
		if @EmplJobID = 0
		begin
		SELECT 
			e.EmplID
			,(CASE 
				WHEN (emplEx.MgrID IS NOT NULL)
				THEN emplEx.MgrID
				ELSE ej.MgrID
				END) as MgrID
			,CASE
				when s.EmplID IS NULL
				THEN CASE
							WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
							ELSE ej.MgrID
						END
				ELSE s.EmplID
			END SubEvalID			
			,e.NameFirst
			,e.NameMiddle
			,e.NameLast
			,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')'  as EmplName
			,dbo.funcGetPrimaryManagerByEmplID(ej.EmplID) as SubEvalID
			,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') 
				FROM Empl e1 WHERE e1.EmplID  = dbo.funcGetPrimaryManagerByEmplID(ej.EmplID)) AS SubEvalName
			,e.IsAdmin
			,e.HasReadOnlyAccess
			,ej.EmplJobID
			,e.EmplActive
			,j.JobCode
			,j.JobName
			,CASE 
					WHEN (SELECT TOP 1
								MgrID
							FROM
								Department
							WHERE
								MgrID = e.EmplID) IS NOT NULL  THEN 'Manager'
					WHEN (SELECT TOP 1
								MgrID
							FROM
								EmplExceptions
							WHERE
								MgrID = e.EmplID
							and EmplJobID in (select EmplJobID from EmplEmplJob where IsActive = 1)) IS NOT NULL  THEN 'Manager'
					WHEN (SELECT TOP 1
								EmplID
							FROM
								SubEval
							WHERE
								EmplID = e.EmplID and EvalActive =1) IS NOT NULL AND @ActiveEmployeeCount > 0 
								THEN 'Subevaluator'
					ELSE 'Educator'
				END  AS RoleDesc
			,case
				when @ActiveEmployeeCount > 0 then e.EmplID
				else null
				end AS IsEvaluator
			,ed.DeptID
			,ed.DeptName
			,ed.IsSchool
			,rh.Is5StepProcess
			,rh.RubricID
			,(Case when dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID) = ej.EmplJobID then 1 else 0 end) as IsPrimaryJob
		FROM
			Empl AS e	 (NOLOCK)
		JOIN EmplEmplJob AS ej	 (NOLOCK)	ON e.EmplID = ej.EmplID
											and ej.IsActive = 1
		join RubricHdr as rh (nolock) on ej.RubricID = rh.RubricID
		left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
														and ase.isActive = 1
														and ase.isDeleted = 0
														and ase.isPrimary = 1
		left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
										and s.EvalActive = 1	
		JOIN EmplJob AS j	 (NOLOCK)				ON ej.JobCode = j.JobCode
												--	AND ej.IsActive = 1
		JOIN Department AS ed (NOLOCK) ON ej.DeptID = ed.DeptID
		LEFT OUTER JOIN EmplExceptions As emplEx on emplEx.MgrID = e.EmplID OR emplEx.EmplJobID = ej.EmplJobID
		LEFT OUTER JOIN EmplExceptions AS emplEx1 on  emplEx1.EmplJobID = ej.EmplJobID
		WHERE
			e.EmplID =@ncUserId 
	--		AND ej.EmplRcdNo <=20	
		ORDER BY IsPrimaryJob desc, ej.IsActive desc, ej.FTE desc, ej.EmplRcdNo asc, ej.EmplJobID desc
		END
		
		Else
		Begin
			SELECT 
			e.EmplID
			--,ej.MgrID
			,(CASE 
				WHEN (emplEx1.MgrID IS NOT NULL)
				THEN emplEx1.MgrID
				ELSE ej.MgrID
				END) as MgrID	
			,dbo.funcGetPrimaryManagerByEmplID(ej.EmplID) as SubEvalID
			,e.NameFirst
			,e.NameMiddle
			,e.NameLast
			,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')'  as EmplName
			,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') 
				FROM Empl e1 WHERE e1.EmplID  = dbo.funcGetPrimaryManagerByEmplID(ej.EmplID)) AS SubEvalName
			,e.IsAdmin
			,ej.EmplJobID
			,e.EmplActive
			,j.JobCode
			,j.JobName
			,CASE 
					WHEN ej.MgrID= '000000' OR emplEx.MgrID IS NOT NULL THEN 'Manager'
					WHEN (SELECT TOP 1
								EmplID
							FROM
								SubEval
							WHERE
								EmplID = e.EmplID and EvalActive =1) IS NOT NULL AND @ActiveEmployeeCount > 0 
								THEN 'Subevaluator'
					ELSE 'Educator'
				END  AS RoleDesc
			,case
				when @ActiveEmployeeCount > 0 then e.EmplID
				else null
				end AS IsEvaluator
			,ed.DeptID
			,ed.DeptName
			,ed.IsSchool
			,rh.Is5StepProcess
			,rh.RubricID
			,(Case when dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID) = ej.EmplJobID then 1 else 0 end) as IsPrimaryJob
			FROM
				Empl AS e	 (NOLOCK)
			JOIN EmplEmplJob AS ej	 (NOLOCK)	ON e.EmplID = ej.EmplID
												AND ej.IsActive = 1
			join RubricHdr as rh (nolock) on ej.RubricID = rh.RubricID
			left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
															and ase.isActive = 1
															and ase.isDeleted = 0
															and ase.isPrimary = 1
			left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
											and s.EvalActive = 1	
			JOIN EmplJob AS j	 (NOLOCK)				ON ej.JobCode = j.JobCode
														--AND ej.IsActive = 1
			JOIN Department AS ed (NOLOCK) ON ej.DeptID = ed.DeptID
			LEFT OUTER JOIN EmplExceptions As emplEx on emplEx.MgrID = e.EmplID OR emplEx.EmplJobID = ej.EmplJobID
			LEFT OUTER JOIN EmplExceptions AS emplEx1 on  emplEx1.EmplJobID = ej.EmplJobID
			WHERE
				e.EmplID =@ncUserId 
				AND ej.EmplJobID = @EmplJobID
			ORDER BY IsPrimaryJob desc,  ej.IsActive desc, ej.FTE desc, ej.EmplRcdNo asc, ej.EmplJobID desc
		End
		
	END	
	ELSE IF @IsEmplActive = 0 and @HasTempActiveAccess = 1
	BEGIN		 
		------------		
		SELECT 
			e.EmplID
			,(CASE 
				WHEN (emplEx.MgrID IS NOT NULL)
				THEN emplEx.MgrID
				ELSE ej.MgrID
				END) as MgrID
			,CASE
				when s.EmplID IS NULL
				THEN CASE
							WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
							ELSE ej.MgrID
						END
				ELSE s.EmplID
			END SubEvalID			
			,e.NameFirst
			,e.NameMiddle
			,e.NameLast
			,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' (' + e.EmplID + ')'  as EmplName
			--,dbo.funcGetPrimaryManagerByEmplID(ej.EmplID) as SubEvalID
			--,(SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') 
			--	FROM Empl e1 WHERE e1.EmplID  = dbo.funcGetPrimaryManagerByEmplID(ej.EmplID)) AS SubEvalName
		 ,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN emplEx.MgrID
			ELSE ej.MgrID
			END) as MgrID,
			CASE
				when s.EmplID IS NULL
				THEN CASE
							WHEN (emplEx.MgrID IS NOT NULL) THEN EmplEx.MgrID
							ELSE ej.MgrID
						END
				ELSE s.EmplID
			END SubEvalID
		 ,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = emplEx.MgrID) 
			ELSE (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = ej.MgrID)
			END) as ManagerName,		   
		   (SELECT ISNULL(e1.NameFirst, '')+ ' ' +ISNULL(e1.NameMiddle,'')+ ' '+ISNULL(e1.NameLast,'') FROM Empl e1 WHERE e1.EmplID = s.EmplID) as SubEvalName
			,CONVERT(bit,0) IsAdmin
			,e.HasReadOnlyAccess
			,ej.EmplJobID
			,CONVERT(bit,1)  As EmplActive			
			,j.JobCode
			,j.JobName
			--,CASE 
			--		WHEN (SELECT TOP 1
			--					MgrID
			--				FROM
			--					Department
			--				WHERE
			--					MgrID = e.EmplID) IS NOT NULL  THEN 'Manager'
			--		WHEN (SELECT TOP 1
			--					MgrID
			--				FROM
			--					EmplExceptions
			--				WHERE
			--					MgrID = e.EmplID
			--				and EmplJobID in (select EmplJobID from EmplEmplJob where IsActive = 1)) IS NOT NULL  THEN 'Manager'
			--		WHEN (SELECT TOP 1
			--					EmplID
			--				FROM
			--					SubEval
			--				WHERE
			--					EmplID = e.EmplID and EvalActive =1) IS NOT NULL AND @ActiveEmployeeCount > 0 
			--					THEN 'Subevaluator'
			--		ELSE 'Educator'
			--	END  AS RoleDesc
			,'Educator' AS RoleDesc
			--,case
			--	when @ActiveEmployeeCount > 0 then e.EmplID
			--	else null
			--	end AS IsEvaluator
			,null AS IsEvaluator			
			,ed.DeptID
			,ed.DeptName
			,ed.IsSchool
			,rh.Is5StepProcess
			,rh.RubricID
			,(Case when dbo.funcGetPrimaryEmplJobByEmplID(ej.EmplID) = ej.EmplJobID then 1 else 0 end) as IsPrimaryJob
		FROM
			Empl AS e	 (NOLOCK)
		JOIN EmplEmplJob AS ej	 (NOLOCK)	ON e.EmplID = ej.EmplID
										--	and ej.IsActive = 1
		join RubricHdr as rh (nolock) on ej.RubricID = rh.RubricID
		left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
														and ase.isActive = 1
														and ase.isDeleted = 0
														and ase.isPrimary = 1
		left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
										and s.EvalActive = 1	
		JOIN EmplJob AS j	 (NOLOCK)				ON ej.JobCode = j.JobCode
												--	AND ej.IsActive = 1
		JOIN Department AS ed (NOLOCK) ON ej.DeptID = ed.DeptID
		LEFT OUTER JOIN EmplExceptions As emplEx on emplEx.MgrID = e.EmplID OR emplEx.EmplJobID = ej.EmplJobID
		LEFT OUTER JOIN EmplExceptions AS emplEx1 on  emplEx1.EmplJobID = ej.EmplJobID
		WHERE
			e.EmplID =@ncUserId 
	--		AND ej.EmplRcdNo <=20	
		ORDER BY IsPrimaryJob desc, ej.IsActive desc, ej.FTE desc, ej.EmplRcdNo asc, ej.EmplJobID desc
		------------
	END
END
GO
