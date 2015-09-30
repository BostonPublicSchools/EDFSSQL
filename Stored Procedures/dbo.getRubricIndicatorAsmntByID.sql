SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/10/2012
-- Description:	Returns indicator assessmnet for each 
-- code and indicator by ID
-- =============================================
Create PROCEDURE [dbo].[getRubricIndicatorAsmntByID]
	@IndicatorID AS int,
	@CodeID as int
	
AS
BEGIN
	SET NOCOUNT ON;

SELECT AssmtID, AssmtText, CodeID, IndicatorID, CreatedByID, CreatedDt, LastUpdatedByID, LastUpdatedDt 
FROM RubricIndicatorAssmt
WHERE IndicatorID = @IndicatorID AND CodeID = @CodeID
	
END

GO
