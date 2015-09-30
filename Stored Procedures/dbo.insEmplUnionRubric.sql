SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 06/19/2012
-- Description:	Inserts a new EmplUnionRubric 
-- =============================================
CREATE PROCEDURE [dbo].[insEmplUnionRubric]
	@RubricID AS int= NULL
	,@UnionCode AS nchar(3) = NULL
	,@UserID AS nchar(6) = null
	,@EmplUnionRubricID AS int = null OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	
	INSERT INTO EmplUnionRubric(RubricID,UnionCode,CreatedByID,CreatedByDt,LastUpdatedByID,LastUpdatedDt)
					VALUES (@RubricID,@UnionCode,@UserID,GETDATE(),@UserID,GETDATE())
	
	set @EmplUnionRubricID = SCOPE_IDENTITY();
					
END
GO
