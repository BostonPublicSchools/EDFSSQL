SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce	
-- Create date: 07/27/2012
-- Description:	List of elements
-- =============================================
CREATE PROCEDURE [dbo].[getRubricSubIndicators]
     @IndicatorID	AS int = null

AS
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
			RubricIndicator AS ri (NOLOCK)
		WHERE
			ParentIndicatorID = @IndicatorID and IndicatorID != @IndicatorID		
		ORDER BY ri.SortOrder
GO
