SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	Delete the report param from 
--				report report param table.		
-- =============================================
CREATE PROCEDURE [dbo].[DelReportReportParam]
	@ReportID AS int,
	@ReportParameterID AS int,
	@UserID AS int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM ReportReportParameter 
	WHERE ReportID = @ReportID AND ReportParameterID = @ReportParameterID
END
GO
