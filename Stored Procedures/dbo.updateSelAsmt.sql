SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 07/30/2012
-- Description:	update self assessment 
-- =============================================
CREATE PROCEDURE [dbo].[updateSelAsmt]
	@SelfAsmtID AS int = NULL
	,@StandardID AS int = NULL
	,@IndicatorID AS int = NULL
	,@SelfAsmtTypeID AS int = NULL
	,@SelfAsmtText AS nvarchar(max) = NULL
	,@UserID AS nchar(6) = null
	,@IsDeleted AS bit = 0
AS

BEGIN
	SET NOCOUNT ON;

IF @IsDeleted = 0
BEGIN
	UPDATE PlanSelfAsmt
	SET
		StandardID = @StandardID
		,IndicatorID = @IndicatorID
		,SelfAsmtTypeID = @SelfAsmtTypeID
		,SelfAsmtText = @SelfAsmtText
		,IsDeleted = @IsDeleted
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		SelfAsmtID = @SelfAsmtID
END
ELSE
BEGIN
	UPDATE PlanSelfAsmt
	SET
		IsDeleted = @IsDeleted
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		SelfAsmtID = @SelfAsmtID
END

END
GO
