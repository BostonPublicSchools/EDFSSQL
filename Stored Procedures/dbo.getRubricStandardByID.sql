SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 08/07/2012
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[getRubricStandardByID]
@StandardID int
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
		RubricStandard AS rs 
		LEFT JOIN  RubricHdr AS ri ON rs.RubricID = ri.RubricID
	WHERE
		rs.StandardID = @StandardID		
	
END


GO
