SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[CheckEmplActiveStatus]
	  @UserID AS nchar(6)
	  ,@rtnStatus AS bit OUTPUT		
AS
BEGIN
	SET NOCOUNT ON;	

	Select @rtnStatus= EmplActive from Empl
	where EmplID=@UserID	
	
END	
GO
