SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 08/01/2012
-- Description:	update Evidence
-- =============================================
CREATE PROCEDURE [dbo].[updEvidence]
	@EvidenceID int
	,@Description as nvarchar(250) = null
	,@Rationale as nvarchar(max) =null
	,@FileName as varchar(50) = null
	,@FileExt as varchar(10) = null
	,@FileSize int = null
	,@UserID as varchar(6) = null
	
AS
BEGIN
	SET NOCOUNT ON;
	

	IF @FileName is null or @FileName = ''
	BEGIN
	SELECT @FileName = [FileName] from Evidence where EvidenceID = @EvidenceID
	END
	
	IF @FileExt is null or @FileExt = ''
	BEGIN
	SELECT @FileExt = FileExt from Evidence where EvidenceID = @EvidenceID
	END
	
	IF @FileSize is null or @FileSize = 0
	BEGIN
	SELECT @FileSize = FileSize from Evidence where EvidenceID = @EvidenceID
	END

	IF @Rationale is null or @Rationale = ''
	BEGIN 
		SELECT 
			@Rationale = Rationale
		FROM 
			Evidence
		WHERE 
			EvidenceID = @EvidenceID
	END
	IF @Description is null or @Description = ''
	BEGIN 
		SELECT 
			@Description = [Description]
		FROM 
			Evidence
		WHERE 
			EvidenceID = @EvidenceID
	END
	
	UPDATE Evidence
	SET [Description]=@Description
		,[FileName] = @FileName
		,FileExt = @FileExt
		,FileSize = @FileSize
		,Rationale = @Rationale
		,LastUpdatedByID = @UserID
		,LastUpdatedDt = GETDATE()
	WHERE
		EvidenceID = @EvidenceID
END
GO
