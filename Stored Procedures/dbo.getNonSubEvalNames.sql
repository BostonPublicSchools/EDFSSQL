SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Avery, Bryce
-- Create date: 09/14/2012
-- Description:	Get meeting by ID
-- =============================================
CREATE PROCEDURE [dbo].[getNonSubEvalNames]
	@searchText AS nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT
		 em.NameFirst
		,em.NameLast
		,em.NameMiddle
		,em.EmplID
	FROM
		Empl AS em
		WHERE ISNULL(em.NameFirst,'') + ISNULL(em.NameMiddle,'') + ISNULL(em.NameLast,'') like '%'+@searchText+'%'	
		AND em.EmplID NOT IN (SELECT EmplID from SubEval where EvalActive = 1) 
	ORDER BY em.NameFirst
END

GO
