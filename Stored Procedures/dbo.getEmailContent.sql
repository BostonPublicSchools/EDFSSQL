SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 03/13/2012
-- Description:	Returns the email subject and content based on FuncCall
-- =============================================
CREATE PROCEDURE [dbo].[getEmailContent]
	@funcCall nchar(10) = null
AS
BEGIN		
	SELECT	e.EmailStdID,
			e.FuncCall,
			e.Subject, 
			e.Message
	FROM dbo.StdEmail e
	WHERE FuncCall = @funcCall
END	

GO
