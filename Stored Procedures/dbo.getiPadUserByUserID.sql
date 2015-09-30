SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =========================================================
-- Author:		Avery, Bryce
-- Create date: 03/11/2014		
-- Description:	Gets iPad use by release type
-- =========================================================
CREATE PROCEDURE [dbo].[getiPadUserByUserID]
	@EmplID as nchar(6) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		i.LogId
		,i.UserId
		,em.NameLast + ', ' + em.NameFirst + ' ' + ISNULL(em.NameMiddle, '') + ' (' + em.EmplID + ')' as UserName
		,i.CreatedByID
		,em2.NameLast + ', ' + em2.NameFirst + ' ' + ISNULL(em2.NameMiddle, '') + ' (' + em2.EmplID + ')' as CreatedByName
		,i.LastSync
	FROM
		IpadUserSyncLog i
	LEFT OUTER JOIN Empl em on em.EmplID = i.UserId
	LEFT OUTER JOIN Empl em2 on em2.EmplID = i.CreatedByID
	WHERE
		UserId = @EmplID
END
GO
