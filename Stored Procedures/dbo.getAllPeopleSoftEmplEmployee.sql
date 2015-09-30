SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[getAllPeopleSoftEmplEmployee]
	@EmplID nchar(6)	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	Select  * from PeopleSoftEmployee 
	Where emplID=@EmplID
   
END
GO
