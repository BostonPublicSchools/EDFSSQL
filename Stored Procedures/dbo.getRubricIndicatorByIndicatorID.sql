SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/10/2012
-- Description:	Returns Indicator details by indicator id
-- =============================================
CREATE PROCEDURE [dbo].[getRubricIndicatorByIndicatorID]
	@IndicatorID AS int
AS
BEGIN
	SET NOCOUNT ON;
	
SELECT	ri.IndicatorID
		,ri.IndicatorDesc
		,ri.IndicatorText
		,rs.StandardText
		,rs.StandardID
		,ri2.IndicatorID as ParentIndicatorID 
		,ri2.IndicatorText as ParentIndicatorText
FROM RubricIndicator ri
JOIN RubricStandard rs ON rs.StandardID =  ri.StandardID
left JOIN RubricIndicator ri2 ON ri2.IndicatorID = ri.ParentIndicatorID
WHERE ri.IndicatorID = @IndicatorID		
END


GO
