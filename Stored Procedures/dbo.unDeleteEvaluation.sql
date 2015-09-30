SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa, Matina
-- Create date: 03/14/2013
-- Description:	UnDelete Evaluation from Evaluation table
-- =============================================
CREATE PROCEDURE [dbo].[unDeleteEvaluation]
	@EvalID	AS int = null
	,@UserID AS nchar(6) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Evaluation
	SET
		IsDeleted = 0
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		EvalID= @EvalID
			
END
GO
