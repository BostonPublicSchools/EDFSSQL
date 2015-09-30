SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 03/10/2014
-- Description:	List of all iPad users
-- =============================================
CREATE PROCEDURE [dbo].[GetAlliPadUsers]
	
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		em.EmplID
		,em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '') + ' (' + em.EmplID + ')' as UserName
		,i.LastSync
		,i.CreatedDt
		,em2.NameLast + ', ' + em2.NameFirst + ' ' + ISNULL(em2.NameMiddle, '') + ' (' + em2.EmplID + ')' as CreatedByName
		,CONVERT(varchar,i.LastAppDownloaddt,101) LastAppDownloaddt
		,i.LastAppDownloadVersion
	FROM
		IpadUserSyncLog i
	LEFT OUTER JOIN Empl em on em.EmplID = i.UserId
	LEFT OUTER JOIN Empl em2 on em2.EmplID = i.CreatedByID
	ORDER BY
		em.NameLast
		,em.NameFirst
		,em.NameMiddle

END


GO
