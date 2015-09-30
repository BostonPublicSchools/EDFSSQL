SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 03/29/2012
-- Description:	List of available active evaluators for supervisor
-- =============================================
CREATE PROCEDURE [dbo].[getSubEval]
	@ncUserId AS nchar(6) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		eval.EvalID
		,e.EmplID
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
	
	
END
GO
