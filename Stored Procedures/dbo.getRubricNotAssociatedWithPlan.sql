SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Gets all plans associated with given RubricID
-- =============================================
CREATE PROCEDURE [dbo].[getRubricNotAssociatedWithPlan]		
	@RubricID int =null
AS
BEGIN
	SET NOCOUNT ON;

SELECT 
	DISTINCT rh.RubricID ,rh.RubricName
FROM 
	RubricHdr rh
	LEFT JOIN RubricPlanType rpt ON rh.RubricID = rpt.RubricID
WHERE 
	rh.IsDeleted = 0
	AND rh.IsActive = 1
	AND rh.Is5StepProcess = 1--	AND AND rh.IsNonLic = 0	
	AND rpt.RubricID is null
END
GO
