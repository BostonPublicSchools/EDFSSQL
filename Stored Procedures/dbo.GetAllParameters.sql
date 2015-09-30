SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	Get all the parameter from reportParameter
-- =============================================
CREATE PROCEDURE [dbo].[GetAllParameters]
	
AS
BEGIN
	SET NOCOUNT ON;
	SELECT ReportParameterID, ReportParameterName, LastUpdatedByID, 
		   LastUpdatedDt, CreatedByDt, CreatedByID
	FROM ReportParameter
END
GO
