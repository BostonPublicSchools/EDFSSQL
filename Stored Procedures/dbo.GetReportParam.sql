SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 04/30/2012
-- Description:	Returns report parameters information for Congnos
-- =============================================
CREATE PROCEDURE [dbo].[GetReportParam]
	@ReportName AS NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		r.ReportID
		,r.ReportName
		,p.ReportParameterID
		,p.ReportParameterName
	FROM
		Report AS r  (NOLOCK)
	JOIN ReportReportParameter AS rp (NOLOCK) ON r.ReportID = rp.ReportID
	JOIN ReportParameter AS p (NOLOCK) ON rp.ReportParameterID = p.ReportParameterID
	WHERE
		r.ReportName = @ReportName
		
END
GO
