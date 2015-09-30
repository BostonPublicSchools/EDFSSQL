SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Avery, Bryce
-- Create date: 08/01/2012
-- Description:	View for Evaluator all daily email history
-- =============================================
CREATE VIEW [dbo].[EvaluatorDailyEmailAll]
AS
	SELECT
		edel.MgrID
		,edel.MgrID + '@boston.k12.ma.us' as MgrEmailAddr
		,(SELECT e1.NameLast + ', ' + e1.NameFirst + ' ' + ISNULL(e1.NameMiddle, '') + ' (' + e1.EmplID + ')' 
			FROM Empl e1 WHERE e1.EmplID  = edel.MgrID) AS ManagerName
		,edel.SubEvalID
		,(SELECT e1.NameLast + ', ' + e1.NameFirst + ' ' + ISNULL(e1.NameMiddle, '') + ' (' + e1.EmplID + ')'
			FROM Empl e1 WHERE e1.EmplID  = edel.SubEvalID) AS SubEvalName
		,EmplID
		,(SELECT e1.NameLast + ', ' + e1.NameFirst + ' ' + ISNULL(e1.NameMiddle, '') + ' (' + e1.EmplID + ')'
			FROM Empl e1 WHERE e1.EmplID  = edel.EmplID) AS EmplName
		,edel.SubEvalID + '@boston.k12.ma.us' as SubEvalEmailaddr
		,cast(edel.CurrentStatus as varchar(3000)) as CurrentStatus
		,edel.CreatedByDt
	FROM
		EvaluatorDailyEmailLog edel

GO
