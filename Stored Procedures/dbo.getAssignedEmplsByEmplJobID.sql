SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[getAssignedEmplsByEmplJobID]
 @EmplJobID int
 
AS
BEGIN
	SET NOCOUNT ON;
	
with [AssignedEmplsByEmplJobID] as
(		--subeval
		SELECT s.EmplID as AssignedEmplID
		FROM SubevalAssignedEmplEmplJob sej 
			 JOIN SubEval s on s.EvalID = sej.SubEvalID 
		WHERE sej.EmplJobID = @EmplJobID and s.EvalActive = 1 and sej.IsActive=1
		
		UNION 
		--manager 
		SELECT (CASE WHEN ex.MgrID is not null then ex.MgrID else ej.MgrID end) as AssignedEmplID
		FROM EmplEmplJob ej 
		LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID = ej.EmplJobID
		WHERE ej.EmplJobID = @EmplJobID
		
		UNION
		--empl
		SELECT ej.emplID as AssignedEmplID FROM EmplEmplJob ej WHERE ej.EmplJobID = @EmplJobID
		
		UNION 
		
		--get primary manager
		SELECT dbo.funcGetPrimaryManagerByEmplID(Convert(nvarchar(6), (SELECT ej.emplID FROM EmplEmplJob ej WHERE ej.EmplJobID = @EmplJobID))) as AssignedEmplID
)

SELECT distinct AssignedEmplID FROM [AssignedEmplsByEmplJobID]
END
GO
