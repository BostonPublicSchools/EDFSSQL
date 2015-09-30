SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	delete the param only if they are not
-- associated with any reports
-- =============================================
CREATE PROCEDURE [dbo].[delReportParam]
	@ParamID AS int,
	@RowDeleted As int = NULL OUTPUT	
AS
BEGIN
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT ReportReportParameterID FROM ReportReportParameter WHERE ReportParameterID = @ParamID)
	BEGIN
		DELETE FROM ReportParameter WHERE ReportParameterID = @ParamID
		SET @RowDeleted = 1
	END
	ELSE
	BEGIN
		SET @RowDeleted = 0
	END	
END
GO
