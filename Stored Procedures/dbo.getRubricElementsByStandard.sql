SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 08/29/2013
-- Description:	List of rubric elements by Standard
-- =============================================
CREATE PROCEDURE [dbo].[getRubricElementsByStandard]
     @StandardID  AS int = null
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
	    ri.IndicatorID
		,ri.StandardID
		,ri.ParentIndicatorID
		,ri.IndicatorText
		,ri.IndicatorDesc
		,ri.IsDeleted
		,ri.IsActive
		,ri.SortOrder
	FROM
		RubricIndicator AS ri 
		
	WHERE 
		 ri.ParentIndicatorID != 0 and ri.StandardID = @StandardID and ri.IsActive = 1 and IsDeleted = 0
		order By   ri.IndicatorText ,ri.SortOrder asc ,ri.ParentIndicatorID
END
GO
