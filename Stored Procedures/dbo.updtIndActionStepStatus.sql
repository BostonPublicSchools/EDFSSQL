SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 08/06/2012
-- Description:	update the status of individual 
--				action step status using ID		
-- =============================================

CREATE PROCEDURE [dbo].[updtIndActionStepStatus]
@ActionStepID int,
@ActionStepStatus varchar(20),
@LastUpdatedByID nchar(6)
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @ActionStepStatusID AS int
	SELECT @ActionStepStatusID = CODEID
	FROM CodeLookUp 
	WHERE CodeLookUp.CodeText = @ActionStepStatus and 
		  CodeLookUp.CodeType = 'AcnStatus'

	UPDATE GoalActionStep
	SET ActionStepStatusID = @ActionStepStatusID,
		LastUpdatedByID = @LastUpdatedByID,
		LastUpdatedDt = GETDATE()
	WHERE ActionStepID = @ActionStepID
		
END
GO
