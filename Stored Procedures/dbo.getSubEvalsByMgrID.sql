SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/18/2013
-- Description:	Get sub evals by MgrID
-- =============================================
CREATE PROCEDURE [dbo].[getSubEvalsByMgrID]
	@MgrID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
	select distinct
		s.EvalID
		,s.Is5StepProcess
		,s.IsNon5StepProcess
		,e.NameFirst + ' ' + ISNULL(e.NameMiddle,'') + ' ' + e.NameLast AS SubEvalName
		,e.EmplID
	from
		SubEval s
	join Empl e on s.EmplID = e.EmplID
	where
		s.EvalActive = 1
	and s.MgrID = @MgrID		
END
GO
