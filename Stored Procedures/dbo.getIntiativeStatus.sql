SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 02/07/2012
-- Description:	List of available intiative statuses
-- =============================================
CREATE PROCEDURE [dbo].[getIntiativeStatus]
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
	AND c.CodeType = 'IntStatus'		
		
END
GO
