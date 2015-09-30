SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =========================================================
-- Author:		Avery, Bryce
-- Create date: 03/11/2014		
-- Description:	Gets latest release by release type
-- =========================================================
CREATE PROCEDURE [dbo].[getLastestReleaseByReleaseType]
	@ReleaseType as nchar(32) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT TOP (1)
		releaseID
		,ReleaseDate
		,ReleaseType
		,ReleaseVersion
	FROM
		Release
	WHERE
		ReleaseType = @ReleaseType
	ORDER BY
		ReleaseDate Desc
END
GO
