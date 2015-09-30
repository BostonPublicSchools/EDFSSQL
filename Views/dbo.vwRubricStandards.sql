SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/27/2012
-- Description:	view on rubric standards based on the 
-- rubrics associated with the job codes
-- =============================================
CREATE VIEW [dbo].[vwRubricStandards]
AS

-- Old View Statements
--SELECT rs.StandardID, rs.StandardText, rs.StandardDesc, rs.IsActive AS StandardIsActive, rs.IsDeleted AS StandardIsDeleted, rh.RubricID, rh.RubricName, eur.UnionCode, 
--                      ej.JobCode, ej.JobName
--FROM   dbo.RubricStandard AS rs LEFT OUTER JOIN
--       dbo.RubricHdr AS rh ON rs.RubricID = rh.RubricID LEFT OUTER JOIN
--       dbo.EmplUnionRubric AS eur ON eur.RubricID = rh.RubricID AND eur.IsDeleted = 0 LEFT OUTER JOIN
--       dbo.EmplJob AS ej ON ej.UnionCode = eur.UnionCode	

--New View

SELECT ej.JobCode,j.JobName, j.UnionCode, rs.StandardID, rs.StandardText, rs.StandardDesc, rs.IsActive AS StandardIsActive, 
		rs.IsDeleted AS StandardIsDeleted, ej.RubricID, rh.RubricName
FROM dbo.RubricStandard AS rs 
JOIN EmplPlan AS ep on ep.RubricID = rs.RubricID
JOIN dbo.EmplEmplJob AS ej ON ej.EmplJobID = ep.EmplJobID      
JOIN dbo.EmplJob AS j on j.JobCode = ej.JobCode
LEFT OUTER JOIN dbo.RubricHdr AS rh ON rh.RubricID = ej.RubricID 
GO
