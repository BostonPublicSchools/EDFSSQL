SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[getUnionCodes]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		eu.UnionCode
		,eu.UnionName
	FROM
		EmplUnion AS eu (NOLOCK)
	WHERE 
	eu.UnionCode not in (select distinct UnionCode from EmplUnionRubric	where isdeleted =0)
END

GO
