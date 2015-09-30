SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 10/09/2012
-- Description:	Rubric by Job Code
-- =============================================
CREATE PROCEDURE [dbo].[getRubricbyJobCode]
	@JobCode AS nchar(6) = null
AS
BEGIN
	SET NOCOUNT ON;		
	SELECT 
		ej.JobCode
		,ej.JobName
		,ej.RubricID
		,ej.UnionCode
		,rbh.RubricName
		,rbh.IsActive
	FROM 
		EmplJob ej
	JOIN RubricHdr rbh ON rbh.RubricID = ej.RubricID
	WHERE
		ej.JobCode =  @JobCode
END
GO
