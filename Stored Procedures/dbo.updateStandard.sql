SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[updateStandard] 
	 @StandardID	AS int = null
	,@StandardText AS nvarchar(50) = null
	,@StandardDesc AS nvarchar(max) = null
	,@StandardSortOrder AS int
	,@IsActive As bit = null
	,@RubricID AS int = null
	,@UserID AS nchar(6) = null

AS
BEGIN

	SET NOCOUNT ON;
 
    UPDATE RubricStandard
	SET
	 StandardText = @StandardText
	 ,StandardDesc = @StandardDesc
	 ,LastUpdatedByID = @UserID
	 ,isActive = @IsActive
	 ,SortOrder = @StandardSortOrder
	 ,RubricID = @RubricID
	 ,LastUpdatedDt = GETDATE()
	WHERE
		StandardID = @StandardID
END
GO
