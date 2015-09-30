SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =========================================================
-- Author:		Ganesan,Devi
-- Create date: 03/07/2012
-- Description:	update is eval lic checked
-- =========================================================
CREATE PROCEDURE [dbo].[UpdIsEvalLicChecked]
	@MgrID AS nchar(6),
	@EvalID AS nchar(6),
	@IsChecked As bit,
	@IsNonChecked As bit,
	@UserID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE SubEval
	SET Is5StepProcess = @IsChecked
	,IsNon5StepProcess = @IsNonChecked
	,LastUpdatedByID = @UserID
	,LastUpdatedDt = GETDATE()
	WHERE EmplID = @EvalID AND MgrID = @MgrID
END
GO
