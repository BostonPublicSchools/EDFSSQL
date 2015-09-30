SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 04/10/2012
-- Description:	List of all codes
-- =============================================
CREATE PROCEDURE [dbo].[getAllCodes]
	@CodeType nchar(10)=null
AS
BEGIN
	SET NOCOUNT ON;

if(@CodeType is null)
begin
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
		,(select COUNT(c2.codeType) from codeLookUp c2 where c2.CodeType = c.CodeType group by c2.codeType) as CodeCountByType
		,(select MAX(c2.CodeSortOrder) from codeLookUp c2 where c2.CodeType = c.CodeType group by c2.codeType) as MaxSortOrder
	FROM
		CodeLookUp AS c (NOLOCK)
	ORDER BY c.CodeType ASC, c.CodeSortOrder
end
else
begin
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
		,(select COUNT(c2.codeType) from codeLookUp c2 where c2.CodeType = c.CodeType group by c2.codeType) as CodeCountByType
		,(select MAX(c2.CodeSortOrder) from codeLookUp c2 where c2.CodeType = c.CodeType group by c2.codeType) as MaxSortOrder
	FROM
		CodeLookUp AS c (NOLOCK)
	WHERE C.CodeType=@CodeType
	ORDER BY c.CodeType ASC, c.CodeSortOrder
end
END
GO
