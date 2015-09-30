SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 06/18/2012
-- Description:	List of rubric standards
-- =============================================
CREATE PROCEDURE [dbo].[getEmplUnionRubric]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT
		eur.EmplUnionRubricID
		,eur.RubricID
		,un.UnionCode
		,rh.RubricName
		,rh.IsActive	
	FROM
		EmplUnionRubric AS eur (NOLOCK)
	LEFT JOIN RubricHdr rh on eur.RubricID = rh.RubricID
	RIGHT JOIN EmplUnion un on eur.UnionCode = un.UnionCode
		WHERE 
		eur.IsDeleted = 0 OR eur.IsDeleted IS NULL
		ORDER BY rh.IsActive asc, eur.RubricID
END




GO
