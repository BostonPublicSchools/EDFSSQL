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
        SELECT TOP ( 1 )
                ReleaseDate
        FROM    dbo.Release
        WHERE   ReleaseType = 'Site'
        ORDER BY ReleaseDate DESC;
    END;
GO
