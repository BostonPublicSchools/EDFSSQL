SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 01/18/2012
-- Description:	List of available plan types
-- =============================================
CREATE PROCEDURE [dbo].[getPlanTypes]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		c.CodeID
		,c.Code
		,c.CodeText
		,c.CodeSortOrder
	FROM
		CodeLookUp AS c (NOLOCK)
	WHERE
		c.CodeActive = 1
	AND c.CodeType = 'PlanType'		
		
END
GO
