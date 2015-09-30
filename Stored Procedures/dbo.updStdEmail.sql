SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 10/12/2012
-- Description: update the std email by emailstdid
-- =============================================
CREATE PROCEDURE [dbo].[updStdEmail]
	@EmailStdID AS INT,
	@FuncCall AS nchar(10),
	@EmailSubject AS nvarchar(80),
	@EmailBody AS nvarchar(MAX),
	@UserId AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE StdEmail 
	SET FuncCall = @FuncCall,
		Subject = @EmailSubject,
		Message = @EmailBody,
		LastUpdatedByID = @UserId,
		LastUpdatedDt = GETDATE()
	WHERE EmailStdID = @EmailStdID
END
GO
