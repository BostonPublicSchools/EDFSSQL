SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/01/2012
-- Description:	update Evidence
-- =============================================
Create PROCEDURE [dbo].[updateNewEvidence]
	@OldEvidenceID int
	,@Description as nvarchar(250) = null
	,@Rationale as nvarchar(max) =null
	,@FileName as varchar(50) = null
	,@FileExt as varchar(5) = null
	,@FileSize int = null
	,@UserID as varchar(6) = null
	,@NewEvidenceID int OUTPUT
	
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO Evidence(FileName, FileExt, FileSize, IsDeleted, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, Description, Rationale, IsEvidenceViewed, EvidenceViewedDt, EvidenceViewedBy)--,EvalComment, EvalCommentDt, EmplComment, EmplCommentDt		
	SELECT @FileName, @FileExt, @FileSize, 0, @UserID, GETDATE(), @UserID, GETDATE(), @Description, @Rationale, 0, NULL, NULL--, EvalComment, EvalCommentDt, EmplComment, EmplCommentDt
	FROM Evidence ev
	WHERE ev.EvidenceID = @OldEvidenceID
	
	SELECT @NewEvidenceID = SCOPE_IDENTITY();
	
	UPDATE EmplPlanEvidence 
	SET EvidenceID = @NewEvidenceID
	WHERE EvidenceID = @OldEvidenceID
	
	UPDATE Evidence
	SET IsDeleted = 1,
	LastUpdatedByID = @UserID,
	LastUpdatedDt = GETDATE()
	WHERE EvidenceID = @OldEvidenceID
	
END
GO
