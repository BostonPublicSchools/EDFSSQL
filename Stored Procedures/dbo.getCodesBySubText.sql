SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/13/2013
-- Description:	List of all codes by code subtext
-- =============================================
CREATE PROCEDURE [dbo].[getCodesBySubText]
	@CodeSubText as nvarchar(max)
	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		c.CodeType
		,c.CodeID
		,c.Code
		,c.CodeText
		,c.CodeSubText
		,c.CodeActive
		,c.CodeSortOrder
		,c.CreatedByID
		,c.CreatedByDt
		,c.LastUpdatedByID
		,c.LastUpdatedDt	
		,c.IsManaged	
	FROM
		CodeLookUp AS c (NOLOCK)
	WHERE dbo.udf_StripHTML(c.CodeSubText) =  dbo.udf_StripHTML(@CodeSubText) 	
	ORDER BY c.Code, c.CodeActive
END
GO
