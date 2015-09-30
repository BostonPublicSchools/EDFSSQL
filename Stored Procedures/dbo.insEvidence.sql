SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/10/2012
-- Description:	Insert Evidence 
-- =============================================
CREATE PROCEDURE [dbo].[insEvidence]

@FileName nvarchar(50)
	,@FileExt nchar(10)
	,@FileSize int
	,@UserID AS nchar(6)
	,@Description as nvarchar(250)
	,@Rationale as nvarchar(MAX)
	,@EvidenceID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO Evidence
				(
					
					[FileName]
					,FileExt
					,FileSize
					,IsDeleted
					,CreatedByID
					,CreatedByDt
					,LastUpdatedByID
					,LastUpdatedDt
					,[Description]
					,Rationale
					,LastCommentViewDt
				)
				VALUES (@FileName,@FileExt,@FileSize,0,@UserID,GETDATE(),@UserID,GETDATE(),@Description,@Rationale,GETDATE())
	SELECT @EvidenceID = SCOPE_IDENTITY();
	

END





GO
