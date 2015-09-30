SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	Get all the reports 
-- =============================================
CREATE PROCEDURE [dbo].[GetAllReports]

AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT		
		r.ReportID		
		,r.ReportName
		,r.ReportPath
		,r.CreatedByID
		,r.CreatedByDt
		,r.LastUpdatedByID
		,r.LastUpdatedDt
		,r.IsDeleted
		,r.procedureName
		,r.selectedRptColumns
		,ISNULL(e.NameFirst, '')+ ' ' +ISNULL(e.NameMiddle,'')+ ' '+ISNULL(e.NameLast,'') as CreatedName
	FROM
		Report AS r  (NOLOCK)
	    LEFT OUTER JOIN Empl e on e.EmplID = r.CreatedByID
END
GO
