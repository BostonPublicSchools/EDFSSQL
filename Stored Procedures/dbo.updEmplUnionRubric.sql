SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 06/19/2012
-- Description:	update EmplUnionRubric
-- =============================================
CREATE PROCEDURE [dbo].[updEmplUnionRubric]
	@EmplUnionRubricID int
	,@RubricID as int
	,@UnionCode as nchar(3) = null
	,@IsDeleted bit = null
	,@UserID as varchar(6) = null
	
AS
BEGIN
	SET NOCOUNT ON;
	
	
	
		
	UPDATE EmplUnionRubric
		SET IsDeleted = @IsDeleted
			,RubricID= @RubricID
			,UnionCode= @UnionCode
			,LastUpdatedByID = @UserID
			,LastUpdatedDt = GETDATE()
	WHERE EmplUnionRubricID = @EmplUnionRubricID
END


GO
