SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 08/02/2012
-- Description:	View for Evaluation Calendar
-- =============================================
CREATE VIEW [dbo].[EvaluationCalendar]
AS
	SELECT 
		ee.EmplID AS SubEvalID
		,ee.NameLast + ', ' + ee.NameFirst + ' ' + ISNULL(ee.NameMiddle, '') AS SubEvalName
		,COUNT(DISTINCT ej.EmplID + ej.JobCode) AS TotalEmplCount
		,COUNT(DISTINCT ej.EmplID + ej.JobCode) * (2 * 1) AS TotalLongObs
		,COUNT(DISTINCT ej.EmplID + ej.JobCode) * (2 * .5) AS TotalShortObs
		,COUNT(DISTINCT ej.EmplID + ej.JobCode) * (4 * .5) AS TotalStandardArtifact
		,COUNT(DISTINCT ej.EmplID + ej.JobCode) AS TotalFomativeRpt
		,COUNT(DISTINCT ej.EmplID + ej.JobCode) AS TotalSummativeRpt
		,COUNT(DISTINCT ej.EmplID + ej.JobCode) * .5 AS TotalFomativeMtg
		,COUNT(DISTINCT ej.EmplID + ej.JobCode) * .5 AS TotalSummativeMtg
		,(COUNT(DISTINCT ej.EmplID + ej.JobCode) * (2 * 1)) + (COUNT(DISTINCT ej.EmplID + ej.JobCode) * (2 * .5)) + (COUNT(DISTINCT ej.EmplID + ej.JobCode) * (4 * .5)) +
		(COUNT(DISTINCT ej.EmplID + ej.JobCode)) + (COUNT(DISTINCT ej.EmplID + ej.JobCode)) + (COUNT(DISTINCT ej.EmplID + ej.JobCode) * .5) +
		(COUNT(DISTINCT ej.EmplID + ej.JobCode) * .5) AS TotalHours
		,((COUNT(DISTINCT ej.EmplID + ej.JobCode) * (2 * 1)) + (COUNT(DISTINCT ej.EmplID + ej.JobCode) * (2 * .5)) + (COUNT(DISTINCT ej.EmplID + ej.JobCode) * (4 * .5)) +
		(COUNT(DISTINCT ej.EmplID + ej.JobCode)) + (COUNT(DISTINCT ej.EmplID + ej.JobCode)) + (COUNT(DISTINCT ej.EmplID + ej.JobCode) * .5) +
		(COUNT(DISTINCT ej.EmplID + ej.JobCode) * .5))/ 10 AS averagepermonth
	FROM
		EmplEmplJob AS ej (NOLOCK)
	JOIN Empl AS ee (NOLOCK) ON CASE ej.SubEvalID 
									WHEN '000000' THEN ej.MgrID
									ELSE ej.SubEvalID 
								END = ee.EmplID
							and EJ.IsActive = 1
	where
		ej.EmplRcdNo < 20
	and EE.EmplActive = 1
	GROUP BY
		ee.EmplID
		,ee.NameLast
		,ee.NameMiddle
		,ee.NameFirst
GO
