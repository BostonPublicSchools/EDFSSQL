SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/02/2012
-- Description:	List of rubric elements by parentRubricID
-- =============================================
CREATE PROCEDURE [dbo].[getRubricElementsByIndicator]
     @RubricID  AS int = null
 

AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
	    ri.IndicatorID
		,ri.StandardID
		,rs.StandardText
		,ri.ParentIndicatorID
		,(select IndicatorText  from RubricIndicator where IndicatorID = ri.ParentIndicatorID) as ParentIndicatorText
		,ri.IndicatorText
		,ri.IndicatorDesc
		,ri.IsDeleted
		,ri.IsActive
		,ri.SortOrder
	FROM
		RubricIndicator AS ri (NOLOCK)
		LEFT JOIN RubricStandard rs (nolock) on  rs.StandardID = ri.StandardID				
	WHERE 
		rs.RubricID = @RubricID and ri.ParentIndicatorID != 0
		order By ri.ParentIndicatorID, ri.SortOrder, ri.IndicatorText
END
GO
