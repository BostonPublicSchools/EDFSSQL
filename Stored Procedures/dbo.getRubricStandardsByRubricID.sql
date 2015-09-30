SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 09/08/2012
-- Description:	List of rubric standards
-- =============================================
Create PROCEDURE [dbo].[getRubricStandardsByRubricID]
 @RubricID AS int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		rs.StandardID
		,rs.StandardText
		,rs.StandardDesc
		,rs.IsDeleted
		,rs.IsActive
		,rs.RubricID
	FROM
		RubricStandard AS rs (NOLOCK)
	WHERE rs.RubricID = @RubricID
		order by rs.SortOrder
END




GO
