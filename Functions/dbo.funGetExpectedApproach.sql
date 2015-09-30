SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 01/17/2013
-- Description: 
-- =============================================

CREATE Function [dbo].[funGetExpectedApproach](@EvalTypeID Integer, @EvalEndDt DateTime )
Returns nvarchar(100)
AS
BEGIN
	DECLARE @Final nvarchar(100)
	SET @Final = 'Collect Evidence'
	IF(@EvalTypeID IS NOT NULL AND @EvalEndDt <= DATEADD(d, 14, GEtDATE()))
	BEGIN
		SET @Final =(SELECT CodeText FROM CodeLookUp WHERE CodeID=@EvalTypeID)
	END
	
	RETURN @FINAL
END
GO
