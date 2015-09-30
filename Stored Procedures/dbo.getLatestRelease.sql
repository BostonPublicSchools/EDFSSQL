SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 03/04/2014
-- Description:	Pulls most recent release date
-- =============================================
CREATE PROCEDURE [dbo].[getLatestRelease]
AS
BEGIN
	select top(1)
		ReleaseDate
	from
		Release
	where
		ReleaseType = 'Site'
	Order by
		ReleaseDate desc
END
GO
