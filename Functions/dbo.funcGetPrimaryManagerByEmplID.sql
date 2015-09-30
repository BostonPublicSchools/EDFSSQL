SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		
-- Create date: 
-- Description: 
-- =============================================

CREATE Function [dbo].[funcGetPrimaryManagerByEmplID](@EmplID nvarchar(6))
Returns nvarchar(6) 
AS
BEGIN
	DECLARE @primaryEmpljobID int 
	DECLARE @primaryManagerID nvarchar(6) 

select @primaryEmpljobID = dbo.funcGetPrimaryEmplJobByEmplID(@EmplID)
--set @primaryManagerID=@primaryEmpljobID
 SELECT Top 1 @primaryManagerID= convert(nvarchar(6), primaryManagerID)	
FROM (
	SELECT (
			CASE 
				WHEN s.EmplID IS NOT NULL
					THEN s.EmplID
				ELSE convert(nvarchar(6), PrimaryEMplJobTable.managerID )
				END
			) AS primaryManagerID
		,ej.EmplID
	FROM dbo.EmplEmplJob AS ej
	LEFT JOIN dbo.SubevalAssignedEmplEmplJob AS sej ON sej.EmplJobID = ej.EmplJobID
		AND sej.IsPrimary = 1
		AND sej.IsActive = 1
		AND sej.IsDeleted = 0
	LEFT JOIN (
		SELECT (
				CASE 
					WHEN ex.EmplID IS NOT NULL
						THEN ex.MgrID --ex.EmplID
					ELSE ej1.MgrID
					END
				) AS managerID
			,ej1.EmplJobID
		FROM dbo.EmplEmplJob AS ej1
		LEFT JOIN dbo.EmplExceptions AS ex ON ex.EmplJobID = ej1.EmplJobID
		WHERE (
				ej1.EmplJobID =@primaryEmpljobID
				--ej1.EmplJobID = (
				--	SELECT TOP (1) EmplJobID
				--	FROM dbo.EmplEmplJob
				--	WHERE (EmplID = ej1.EmplID)
				--		AND (IsActive = 1)
				--	ORDER BY FTE DESC
				--		,EmplRcdNo
				--	)
				)
		) AS PrimaryEMplJobTable ON PrimaryEMplJobTable.EmplJobID = ej.EmplJobID
	LEFT JOIN dbo.SubEval AS s ON s.EvalID = sej.SubEvalID
		AND s.EvalActive = 1 
	WHERE (ej.IsActive = 1 and ej.EmplID=@EmplID)
	) AS tblEmplIDWithPriMgrID
WHERE (primaryManagerID IS NOT NULL)


	 RETURN @primaryManagerID 
END
GO
