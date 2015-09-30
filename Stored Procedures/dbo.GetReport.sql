SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 04/30/2012
-- Description:	Returns report information for Congnos
-- =============================================
CREATE PROCEDURE [dbo].[GetReport]
	@ReportName AS NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		ReportID
		,ReportName
		,ReportPath
		,ProcedureName
		,SelectedRptColumns
	FROM
		Report  (NOLOCK)
	WHERE
		ReportName = @ReportName
		
END
GO
