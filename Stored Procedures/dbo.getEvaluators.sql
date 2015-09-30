SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/17/2012
-- Description:	List of available evaluators(Active/non-active) for supervisor, it returns supervisor as evaluator
-- =============================================
CREATE PROCEDURE [dbo].[getEvaluators]
	@ncUserId AS nchar(6) = NULL
AS
BEGIN
	SET NOCOUNT ON;


	SELECT 
		e.EmplID
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') AS EmplName
		,e.EmplActive
		,eval.Is5StepProcess
		,eval.IsNon5StepProcess
	FROM
		Empl AS e  (NOLOCK)
	JOIN SubEval as eval  (NOLOCK) ON e.EmplID = eval.EmplID
												AND eval.EvalActive = 1
												AND eval.MgrID =@ncUserId
	WHERE
		e.EmplActive = 1 
	group by 
		e.EmplID,e.NameFirst,e.NameLast,e.NameMiddle,e.EmplActive, eval.Is5StepProcess, eval.IsNon5StepProcess
	
	UNION	
	SELECT
		 e.EmplID
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') AS EmplName
		,e.EmplActive
		,1
		,1
	from 
		Empl as e
	where 
		e.EmplID =@ncUserId
END
GO
