SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/15/2012
-- Description:	insert new code
-- =============================================
CREATE PROCEDURE [dbo].[insertNewCodeLookUp]
 @Code as nchar(10),
 @CodeType as nchar(10),
 @CodeText as nvarchar(50),
 @CodeSubText as nvarchar(max),
 @CreatedByID as nchar(6),
 @LastUpdatedID as nchar(6),
 @IsCodeActive bit,
 @IsCodeManaged bit
AS
BEGIN
	SET NOCOUNT ON;
DECLARE @SortOrder as int
	SELECT @SortOrder = (COUNT(CodeID) + 1) FROM CodeLookUp WHERE CodeType = @CodeType
	
	if @IsCodeManaged=1
		Set @CodeSubText=dbo.udf_StripHTML(@CodeSubText) 
			
	INSERT INTO CodeLookUp(Code, CodeType, CodeText, CodeSubText, CodeSortOrder, CodeActive, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IsManaged)
				VALUES(@Code, @CodeType, @CodeText, @CodeSubText, @SortOrder, @IsCodeActive, @CreatedByID, GETDATE(), @LastUpdatedID, GETDATE(), @IsCodeManaged)
END




GO
