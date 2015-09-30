SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 10/12/2012
-- Description: insert the new std email by emailstdid
-- =============================================
CREATE PROCEDURE [dbo].[insStdEmail]	
	@FuncCall AS nchar(10),
	@EmailSubject AS nvarchar(80),
	@EmailBody AS nvarchar(MAX),
	@UserId AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO StdEmail(FuncCall, Subject, Message, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
				VALUES(@FuncCall, @EmailSubject, @EmailBody, @UserId, GETDATE(), @UserId, GETDATE())	
END
GO
