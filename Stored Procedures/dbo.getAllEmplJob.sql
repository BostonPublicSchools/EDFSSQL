SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/31/2012
-- Description:	List of all empl jobs
-- =============================================
CREATE PROCEDURE [dbo].[getAllEmplJob]
	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		JobCode,
		JobName,
		UnionCode,
		CreatedByID,
		CreatedByDt,
		LastUpdatedByID,
		LastUpdatedDt
	FROM
		EmplJob
END
GO
