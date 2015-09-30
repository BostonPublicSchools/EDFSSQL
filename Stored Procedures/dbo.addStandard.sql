SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[addStandard] 
	 @StandardID	AS int = null
	,@StandardText AS nvarchar(50) = null
	,@StandardDesc AS nvarchar(max) = null
	,@StandardSortOrder AS int
	,@IsActive As bit = null
	,@RubricID as int = null
	,@UserID AS nchar(6) = null
AS
BEGIN 

	SET NOCOUNT ON;
		
	INSERT INTO RubricStandard (StandardText, StandardDesc, RubricID, CreatedByID, CreatedDt, LastUpdatedByID,LastUpdatedDt, isDeleted, isActive, SortOrder)
					VALUES (@StandardText, @StandardDesc, @RubricID, @UserID, GETDATE(), @UserID, GETDATE(), 0, @IsActive, @StandardSortOrder)    

END
GO
