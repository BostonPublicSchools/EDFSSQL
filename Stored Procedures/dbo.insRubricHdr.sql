SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 06/19/2012
-- Description:	Inserts a new RubricHdr
-- =============================================
CREATE PROCEDURE [dbo].[insRubricHdr]

	@RubricName AS nvarchar(32) = NULL
	,@IsActive as bit = null
	,@Is5StepProcess as bit = null
	,@IsDESELic as bit
	,@UserID AS nchar(6) = null
	,@RubricID AS int= NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	
	INSERT INTO RubricHdr(RubricName,IsActive,CreatedByID,CreatedByDt,LastUpdatedByID,LastUpdatedDt, Is5StepProcess, IsDESELic)
					VALUES (@RubricName,@IsActive,@UserID,GETDATE(),@UserID,GETDATE(), @Is5StepProcess, @IsDESELic)
	
	set @RubricID = SCOPE_IDENTITY();
					
END
GO
