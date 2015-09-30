SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 09/08/2012
-- Description:	list of employee names and id for search
-- =============================================
CREATE PROCEDURE [dbo].[getEmplNames]
 @searchText AS nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		 em.NameFirst
		,em.NameLast
		,em.NameMiddle
		,em.EmplID
		,em.EmplActive
	FROM
		Empl AS em
	WHERE ISNULL(em.NameFirst,'') + ISNULL(em.NameMiddle,'') + ISNULL(em.NameLast,'') like '%'+@searchText+'%'
	ORDER BY em.NameFirst

END




GO
