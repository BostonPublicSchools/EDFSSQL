SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	delete reports and all 
-- the associated params and roles.
-- =============================================
CREATE PROCEDURE [dbo].[delReports]
	@ReportID AS int	
AS
BEGIN
	SET NOCOUNT ON;
	
	DELETE FROM ReportAppRole WHERE ReportID = @ReportID
	
	DELETE FROM ReportReportParameter WHERE ReportID = @ReportID
	
	DELETE FROM Report WHERE ReportID = @ReportID
	
END
GO
