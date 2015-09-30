SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	Get all the rpt union code 
-- =============================================
CREATE PROCEDURE [dbo].[getAllRptUnionCode]

AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		ruc.UnionCode,
		ruc.JobCode,
		ruc.JobName,
		ruc.IsActive,
		ruc.CreatedByID,
		ruc.CreatedByDt,
		ruc.LastUpdatedID,
		ruc.LastUpdatedDt,
		(ISNULL(e.NameFirst, '')+' '+ISNULL(e.NameMiddle, '')+' '+ISNULL(e.NameLast, '')) as CreatedByName
	FROM RptUnionCode ruc (NOLOCK)
	LEFT OUTER JOIN Empl e on e.EmplID = ruc.CreatedByID		
END
GO
