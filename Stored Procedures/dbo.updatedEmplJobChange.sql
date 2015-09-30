SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 03/27/2013
-- Description:	Update EmplJobChange and
--				NotificationsLog based on success of run of report on Cognos.
-- =============================================
CREATE PROCEDURE [dbo].[updatedEmplJobChange]
	@UserID as nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
    INSERT APPSSQL.EDFSStaging.dbo.NotificationsLog (PlanID, ToAddress, FromAddress, EmailMessage, CreatedByID, CreatedDt, LastUpdatedByID, LastUpdatedDt)
							SELECT
								MAX(p.PlanID), c.EmplID + '@boston.k12.ma.us', 'no-reply@boston.k12.ma.us', 'According to Peoplesoft data, you have recently entered a new position in Boston Public Schools. Your EDFS evaluation plan is transferring to your new job code and your new evaluator. If you and your evaluator believe your new job will require you to have different goals, he/she can contact eval@boston.k12.ma.us to make these changes.', '000000', GETDATE(), '000000', GETDATE()
							FROM
								EVALSQL.EVAL.dbo.EmplPlan p
							JOIN EVALSQL.EVAL.dbo.EmplEmplJob ej ON p.EmplJobID = ej.EmplJobID
							JOIN EVALSQL.EVAL.dbo.EmplJobChange c On ej.EmplID = c.EmplID
							WHERE
								c.IsEmailSent = 0
							GROUP BY
								c.EmplID

 --   INSERT APPSSQL.EDFSStaging.dbo.NotificationsLog (PlanID, ToAddress, FromAddress, EmailMessage, CreatedByID, CreatedDt, LastUpdatedByID, LastUpdatedDt)
	--						SELECT
	--							MAX(p.PlanID), c.MgrID + '@boston.k12.ma.us', 'no-reply@boston.k12.ma.us', 'EDFS Evaluator Daily Status - Job Change', '000000', GETDATE(), '000000', GETDATE()
	--						FROM
	--							EmplPlan p
	--						JOIN EmplEmplJob ej ON p.EmplJobID = ej.EmplJobID
	--						JOIN EmplJobChange c On ej.EmplID = c.EmplID
	--						WHERE
	--							c.IsEmailSent = 0
	--						GROUP BY
	--							c.MgrID							 
	
	--UPDATE APPSSQL.EDFSStaging.dbo.EmplJobChange
	--SET
	--IsEmailSent	= 1
	--,LastUpdatedByID = '000000'
	--,LastUpdatedDt = GETDATE()
	--WHERE
	--IsEmailSent = 0
END

GO
