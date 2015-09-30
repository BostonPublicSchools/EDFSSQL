SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	Get all the roles associated with an report
-- =============================================
CREATE PROCEDURE [dbo].[GetReportRolesByID]
	@ReportID as int
	
AS
BEGIN
	SET NOCOUNT ON;
	SELECT rpt.ReportAppRoleID, rpt.ReportID, rpt.RoleID, apr.RoleDesc as RoleName, 
			rpt.CreatedByID, rpt.CreatedByDt, rpt.LastUpdatedByID, rpt.LastUpdatedByID
	FROM ReportAppRole rpt
	LEFT OUTER JOIN AppRole apr on apr.RoleID = rpt.RoleID
	WHERE rpt.ReportID = @ReportID
END
GO
