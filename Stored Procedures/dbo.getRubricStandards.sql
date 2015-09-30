SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 05/04/2012
-- Description:	List of rubric standards
-- =============================================
CREATE PROCEDURE [dbo].[getRubricStandards]
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
		,ri.RubricName
		,rs.SortOrder	
	FROM
		RubricStandard AS rs (NOLOCK)
		LEFT JOIN  RubricHdr AS ri ON rs.RubricID = ri.RubricID
		order by rs.SortOrder
END




GO
