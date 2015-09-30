SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/22/2013
-- Description:	Get sub evals by EmplID
-- =============================================
CREATE PROCEDURE [dbo].[getAdminSubEvalsByEmplID]
	@EmplID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
	select
		e.EmplID		
		,e.NameLast + ', ' + e.NameFirst +' '+ISNULL(e.NameMiddle,'')AS SubEvalName
	from
		SubEval s
	join Empl e on s.EmplID = e.EmplID
	where
		s.EvalActive = 1
	and s.EvalID in (select
							s.SubEvalID
						from
							SubevalAssignedEmplEmplJob s
						join EmplEmplJob j on s.EmplJobID = j.EmplJobID
											and j.IsActive = 1
											and j.EmplID = @EmplID
						where
							s.IsActive = 1
						and s.IsDeleted = 0)
	union
	select
		(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN emplEx.MgrID
			ELSE j.MgrID
			END) as EmplID
		,(CASE 
			WHEN (emplEx.MgrID IS NOT NULL)
			THEN (SELECT e1.NameLast + ', ' + e1.NameFirst +' '+ISNULL(e1.NameMiddle,'') FROM Empl e1 WHERE e1.EmplID = emplEx.MgrID) 
			ELSE (SELECT e1.NameLast + ', ' + e1.NameFirst +' '+ISNULL(e1.NameMiddle,'') FROM Empl e1 WHERE e1.EmplID = j.MgrID)
		 END) AS SubEvalName	
	from
		EmplEmplJob j 
	left join EmplExceptions as emplEx (NOLOCK) on emplEx.EmplJobID = j.EmplJobID
	join Empl e on e.EmplID = (CASE WHEN emplEx.MgrID IS NOT NULL THEN emplEx.MgrID ELSE j.MgrID END)
	where
		j.IsActive = 1
	and	j.EmplID = @EmplID
	
END
GO
