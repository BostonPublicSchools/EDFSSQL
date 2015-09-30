SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 05/04/2012
-- Description:	List of rubric indicators
-- =============================================
CREATE PROCEDURE [dbo].[getRubricIndicators]
     @StandardID  AS int = null
     ,@IndicatorID	AS int = null

AS

If (@IndicatorID is null and @StandardID is null)
	BEGIN
	SET NOCOUNT ON;
	SELECT 
		ri.IndicatorID
		,ri.StandardID
		,rs.StandardText
		,rs.RubricID
		,ri.ParentIndicatorID
		,ri.IndicatorText
		,ri.IndicatorDesc
		,ri.IsDeleted
		,ri.IsActive
		,ri.SortOrder
	FROM
		RubricIndicator AS ri (NOLOCK)	
		JOIN RubricStandard rs (NOLOCK) ON ri.StandardID = rs.StandardID and rs.IsActive = 1
		ORDER BY  ri.SortOrder	
	END
ELSE
    IF (@IndicatorID is null and @StandardID is not null)
		BEGIN

		SET NOCOUNT ON;
		SELECT 
			ri.IndicatorID
			,ri.StandardID
			,rs.StandardText
			,rs.RubricID
			,ri.ParentIndicatorID
			,ri.IndicatorText
			,ri.IndicatorDesc
			,ri.IsDeleted
			,ri.IsActive
			,ri.SortOrder
		FROM
			RubricIndicator AS ri (NOLOCK)
			JOIN RubricStandard rs (NOLOCK) ON ri.StandardID = rs.StandardID and rs.IsActive = 1
		WHERE
			(ri.ParentIndicatorID = 0 or ri.ParentIndicatorID = ri.IndicatorID)
		AND	ri.StandardID = @StandardID AND ri.IsDeleted = 0
		ORDER BY ri.SortOrder
		
		END	
	Else
		SET NOCOUNT ON;
		SELECT 
			ri.IndicatorID
			,ri.StandardID
			,rs.StandardText
			,rs.RubricID
			,ri.ParentIndicatorID
			,ri.IndicatorText
			,ri.IndicatorDesc
			,ri.IsDeleted
			,ri.IsActive
			,ri.SortOrder
		FROM
			RubricIndicator AS ri (NOLOCK)
			JOIN RubricStandard rs (NOLOCK) ON ri.StandardID = rs.StandardID and rs.IsActive = 1
		WHERE
			IndicatorID = @IndicatorID
		ORDER BY ri.SortOrder
		
		
GO
