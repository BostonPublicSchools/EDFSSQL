SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/15/2012
-- Description:	update code by codeid and codetype
-- =============================================
CREATE PROCEDURE [dbo].[updateCodeLookUp]
 @CodeID as int,
 @Code as nchar(10),
 @CodeType as nchar(10),
 @CodeText as nvarchar(50),
 @CodeSubText as nvarchar(max),
 @LastUpdatedID as nchar(6),
 @CodeSortOrder as int,
 @IsCodeActive bit,
 @IsCodeManaged bit 
AS
BEGIN
	SET NOCOUNT ON;
	
	if @IsCodeManaged=1
		Set @CodeSubText=dbo.udf_StripHTML(@CodeSubText)
		
	UPDATE CodeLookUp
	SET Code = @Code, 
		CodeType = @CodeType, 
		CodeText = @CodeText, 
		CodeSubText = @CodeSubText, 
		CodeSortOrder = @CodeSortOrder, 
		CodeActive = @IsCodeActive, 
		LastUpdatedByID = @LastUpdatedID, 
		LastUpdatedDt =GETDATE(),
		IsManaged = @IsCodeManaged
	WHERE CodeID = @CodeID AND CodeType = @CodeType
				
END




GO
