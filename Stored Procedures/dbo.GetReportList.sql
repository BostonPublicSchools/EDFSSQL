SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 04/30/2012
-- Description:	Returns a list of reports by role
-- =============================================
CREATE PROCEDURE [dbo].[GetReportList]
	@RoleDesc AS NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		r.ReportID
		,r.ReportName
		,r.ReportPath
	FROM
		Report AS r  (NOLOCK)
	JOIN ReportAppRole AS ra (NOLOCK) ON r.ReportID = ra.ReportID
	JOIN AppRole AS a (NOLOCK) ON ra.RoleID = a.RoleID
	WHERE
		a.RoleDesc = @RoleDesc
		
END
GO
