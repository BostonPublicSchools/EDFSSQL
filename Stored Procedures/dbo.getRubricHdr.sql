SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 06/18/2012
-- Description:	List of rubric standards
-- =============================================
CREATE PROCEDURE [dbo].[getRubricHdr]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		rd.RubricID
		,rd.RubricName
		,rd.Is5StepProcess
		,rd.IsDESELic
		,rd.IsActive
		,rd.IsDeleted
	FROM
		RubricHdr AS rd (NOLOCK)
	WHERE 
		rd.IsDeleted = 0	
END




GO
