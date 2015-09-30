SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/26/2012
-- Description:	returns all the empljob, rubricID 
-- and union codes.
-- =============================================
CREATE PROCEDURE [dbo].[getAllEmplJobRubric]
	
AS
BEGIN
	SET NOCOUNT ON;		
	SELECT 
		ej.JobCode
		,ej.JobName
		,ej.RubricID
		,ej.UnionCode
		,rbh.RubricName
		,rbh.Is5StepProcess
		,rbh.IsActive
		,rbh.IsDESELic
	FROM EmplJob ej
	LEFT OUTER JOIN RubricHdr rbh ON rbh.RubricID = ej.RubricID
	ORDER BY ej.RubricID	
END
GO
