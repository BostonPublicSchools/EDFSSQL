SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 07/24/2012
-- Description:	Inserts a new self assessment
-- =============================================
CREATE PROCEDURE [dbo].[insSelfAsmt]
	@PlanID AS int= NULL
	,@StandardID AS int = NULL
	,@IndicatorID AS int = NULL
	,@SelfAsmtTypeID AS int = NULL
	,@SelfAsmtText AS nvarchar(max) = NULL
	,@UserID AS nchar(6) = null
	,@SelfAsmtID AS int = null OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO  PlanSelfAsmt (PlanID, StandardID, IndicatorID, SelfAsmtTypeID, SelfAsmtText, LastUpdatedByID, LastUpdatedDt, CreatedByID, CreatedByDt)
					VALUES (@PlanID, @StandardID, @IndicatorID, @SelfAsmtTypeID, @SelfAsmtText, @UserID, GETDATE(), @UserID, GETDATE())
	
	set @SelfAsmtID = SCOPE_IDENTITY();
					
END
GO
