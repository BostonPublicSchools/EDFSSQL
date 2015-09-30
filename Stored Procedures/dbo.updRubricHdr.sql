SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara,Krunal
-- Create date: 06/20/2012
-- Description:	Update RubricHdr
-- =============================================
CREATE PROCEDURE [dbo].[updRubricHdr] 
	@RubricID AS int
	,@Is5StepProcess as bit = null 
	,@IsActive AS bit = null
	,@IsDeleted AS bit = null
	,@IsDESELic as bit
	,@UserID as nchar(6) = null

AS
BEGIN
	SET NOCOUNT ON;

    UPDATE RubricHdr
	SET
	 Is5StepProcess = @Is5StepProcess
	 ,IsDESELic = @IsDESELic
	 ,IsActive= @IsActive
	 ,IsDeleted = @IsDeleted
	 ,LastUpdatedByID = @UserID
	 ,LastUpdatedDt = GETDATE()
	WHERE
		RubricID= @RubricID
		
IF @IsDeleted = 1
	BEGIN
		DELETE FROM ObservationRubricDefault WHERE RubricID = @RubricID	
	END
END
GO
