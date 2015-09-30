SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/17/2013
-- Description: 
-- =============================================


CREATE VIEW [dbo].[vwObservationByPlan] 
AS 
SELECT (od.ObsvID), oh.PlanID, rs.StandardID, rs.SortOrder FROM ObservationDetail od
JOIN ObservationHeader oh ON oh.ObsvID = od.ObsvID
LEFT OUTER JOIN RubricIndicator ri ON ri.IndicatorID = od.IndicatorID
LEFT OUTER JOIN RubricStandard rs ON rs.StandardID = ri.StandardID 
GROUP BY od.ObsvID, oh.PlanID, rs.StandardID, rs.SortOrder
GO
