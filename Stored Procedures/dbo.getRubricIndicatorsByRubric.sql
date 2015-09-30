SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 06/20/2012
-- Description:	List of rubric indicators by RubricID
-- =============================================
CREATE PROCEDURE [dbo].[getRubricIndicatorsByRubric]
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
		,(select COUNT(IndicatorID) from RubricIndicator ri2 where ri2.StandardID = rs.StandardID and ParentIndicatorID = 0)
            as ChildrenCount
	FROM
		RubricIndicator AS ri (NOLOCK)
		LEFT JOIN RubricStandard rs (nolock) on  rs.StandardID = ri.StandardID
	WHERE 
		rs.RubricID = @RubricID and 
		ParentIndicatorID = 0 or ParentIndicatorID = IndicatorID
	order By rs.StandardID, ri.SortOrder, ri.IndicatorText
END
GO
