SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 04/10/2012
-- Description:	List of codes by codetype
-- =============================================
CREATE PROCEDURE [dbo].[getCodes]
	 @CodeType AS nvarchar(10) = NULL
	,@IsDeleted bit
	
AS
BEGIN
	SET NOCOUNT ON;

IF @IsDeleted = 0
BEGIN
	SELECT
		c.CodeType
		,c.CodeID
		,c.Code
		,c.CodeText
		,(case when c.IsManaged=1 then dbo.udf_StripHTML(c.CodeSubText) else c.CodeSubText end) CodeSubText
		,c.CodeSortOrder
		,c.CodeActive
		,c.IsManaged
		,(select MAX(c2.CodeSortOrder) from codeLookUp c2 where c2.CodeType = c.CodeType group by c2.codeType) as MaxSortOrder
		,rh.RubricID		
	FROM
		CodeLookUp AS c (NOLOCK) 
		LEFT JOIN RubricHdr AS rh (NOLOCK) on rh.RubricName =  dbo.udf_StripHTML(c.CodeSubText)
	WHERE
		c.CodeActive = 1
	AND c.CodeType = @CodeType
END
ELSE
BEGIN
	SELECT
		c.CodeType
		,c.CodeID
		,c.Code
		,c.CodeText
		,dbo.udf_StripHTML(c.CodeSubText) CodeSubText
		,c.CodeSortOrder
		,c.CodeActive
		,c.IsManaged
		,(select MAX(c2.CodeSortOrder) from codeLookUp c2 where c2.CodeType = c.CodeType group by c2.codeType) as MaxSortOrder
		,rh.RubricID
	FROM
		CodeLookUp AS c (NOLOCK) 
		LEFT JOIN RubricHdr AS rh (NOLOCK) on rh.RubricName =  dbo.udf_StripHTML(c.CodeSubText)
		WHERE c.CodeType = @CodeType
END		
END
GO
