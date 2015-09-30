SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 05/24/2012
-- Description:	Delete Evaluation from Evaluation table
-- =============================================
Create PROCEDURE [dbo].[delEvaluation]
	@EvalID	AS int = null
	,@UserID AS nchar(6) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Evaluation
	SET
		IsDeleted = 1
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		EvalID= @EvalID
			
END
GO
