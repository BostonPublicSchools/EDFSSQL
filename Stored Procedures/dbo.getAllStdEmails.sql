SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 10/12/2012
-- Description:	Get all std emails
-- =============================================
CREATE PROCEDURE [dbo].[getAllStdEmails]

AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT	
		se.EmailStdID,
		se.FuncCall,
		se.Message,
		se.Subject,
		se.CreatedByID,
		se.CreatedByDt,
		se.LastUpdatedByID,
		se.LastUpdatedDt
		,ISNULL(e.NameFirst, '')+ ' ' +ISNULL(e.NameMiddle,'')+ ' '+ISNULL(e.NameLast,'') as CreatedByName
	FROM StdEmail se (NOLOCK)
	LEFT OUTER JOIN Empl e(NOLOCK) ON e.EmplID = se.CreatedByID
END
GO
