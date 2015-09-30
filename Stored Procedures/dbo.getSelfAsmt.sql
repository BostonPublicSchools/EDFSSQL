SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 07/27/2012
-- Description:	Get list of self assessement
-- =============================================
Create PROCEDURE [dbo].[getSelfAsmt]
	@PlanID AS int

AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		s.PlanID
		,s.SelfAsmtID
		,s.SelfAsmtTypeID
		,c.CodeText AS SelfAsmtTypeText
		,s.StandardID
		,rs.StandardText
		,pri.IndicatorID AS IndicatorID
		,pri.IndicatorText AS IndicatorText
		,s.IndicatorID	AS ElementID
		,ri.IndicatorText AS ElementText
		,s.SelfAsmtText
		,s.IsDeleted
	FROM
		PlanSelfAsmt AS s (NOLOCK)
	JOIN CodeLookUp AS c (NOLOCK) ON s.SelfAsmtTypeID = c.CodeID
	JOIN RubricStandard  as rs (NOLOCK) ON s.StandardID = rs.StandardID
	JOIN RubricIndicator as ri (NOLOCK) ON s.IndicatorID = ri.IndicatorID
	JOIN RubricIndicator as pri (NOLOCK) ON pri.IndicatorID = ri.ParentIndicatorID
	WHERE
		s.PlanID = @PlanID
	AND s.IsDeleted = 0		
	
END
GO
