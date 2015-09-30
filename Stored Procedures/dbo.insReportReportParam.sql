SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	insert the newly added record 
--	in reportreportparam table.	
-- =============================================
CREATE PROCEDURE [dbo].[insReportReportParam]
	@ReportID AS int,
	@ReportParameterID AS int,
	@UserID AS int
AS
BEGIN
	SET NOCOUNT ON;
	IF NOT EXISTS(Select ReportReportParameterID FROM ReportReportParameter WHERE ReportID = @ReportID AND ReportParameterID = @ReportParameterID)
	BEGIN
		INSERT INTO ReportReportParameter(ReportID, ReportParameterID, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
		VALUES(@ReportID, @ReportParameterID, @UserID, GETDATE(), @UserID, GETDATE())
	END
END
GO
