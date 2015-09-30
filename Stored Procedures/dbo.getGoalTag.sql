SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/24/2012
-- Description:	List of available goal tags
-- =============================================
CREATE PROCEDURE [dbo].[getGoalTag]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		c.CodeID
		,c.Code
		,c.CodeText
		,c.CodeSortOrder
		,c.CodeSubText
	FROM
		CodeLookUp AS c (NOLOCK)
	WHERE
		c.CodeActive = 1
	AND c.CodeType = 'GoalTag'		
		
END
GO
