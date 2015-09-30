SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/17/2012
-- Description:	Get rubric standards rating by JobCode
-- =============================================
CREATE PROCEDURE [dbo].[getRubricStandardsListByJobCode]
	@JobCode as nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
select	--esr.EvalStdRatingID
		--,esr.EvalID
		rs.StandardID
		,rs.StandardText
		,rs.JobCode
		,rs.StandardDesc
		,rs.RubricID
		,rs.RubricName
		
from vwRubricStandards rs
WHERE rs.JobCode = @JobCode	
AND rs.StandardIsActive = 1
AND rs.StandardIsDeleted = 0			
							
END	
GO
