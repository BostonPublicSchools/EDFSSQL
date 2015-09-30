SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================
-- Author:		Ganesan,Devi
-- Create date: 10/23/2012
-- Description:	update the observation rubric default by rubric id
-- ================================================================
CREATE PROCEDURE [dbo].[UpdateObservationRubricDefaultByRubricID]
  @RubricID AS INT,
  @UserID AS nchar(6)
AS
BEGIN 
SET NOCOUNT ON;

INSERT INTO ObservationRubricDefault (EmplID, RubricID, IndicatorID, IsActive, IsDeleted, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
(SELECT 
	DISTINCT d.MgrID
	,rh.RubricID
	,ri.IndicatorID
	,1
	,0
	,@UserID
	,GETDATE()
	,@UserID
	,GETDATE()	
FROM
	RubricIndicator AS ri 
JOIN RubricStandard AS rs ON ri.StandardID = rs.StandardID
							AND (rs.StandardText like 'II.%' OR rs.StandardText like 'II:%')
							AND rs.IsActive = 1
							AND rs.IsDeleted = 0
JOIN RubricHdr AS rh ON rs.RubricID = rh.RubricID
						AND rh.IsActive = 1
						AND rh.IsDeleted = 0
CROSS JOIN Department d
WHERE 
	ri.ParentIndicatorID = 0
	AND	NOT d.MgrID = '000000'	AND rh.RubricID = @RubricID
	AND MgrID NOT IN (SELECT EmplID FROM ObservationRubricDefault WHERE RubricID = @RubricID))
ORDER BY 1,2,3


INSERT INTO ObservationRubricDefault (EmplID, RubricID, IndicatorID, IsActive, IsDeleted, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
(SELECT 
	DISTINCT d.EmplID
	,rh.RubricID
	,ri.IndicatorID
	,1
	,0
	,@UserID
	,GETDATE()
	,@UserID
	,GETDATE()	
FROM
	RubricIndicator AS ri 
JOIN RubricStandard AS rs ON ri.StandardID = rs.StandardID
							AND (rs.StandardText like 'II.%' OR rs.StandardText like 'II:%')
							AND rs.IsActive = 1
							AND rs.IsDeleted = 0
JOIN RubricHdr AS rh ON rs.RubricID = rh.RubricID
						AND rh.IsActive = 1
						AND rh.IsDeleted = 0
CROSS JOIN SubEval d
WHERE 
	ri.ParentIndicatorID = 0 AND rh.RubricID = @RubricID
	AND emplID NOT IN (SELECT EmplID FROM ObservationRubricDefault WHERE RubricID = @RubricID))
ORDER BY 1,2,3

END
GO
