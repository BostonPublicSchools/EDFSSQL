SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi	
-- Create date: 02/12/2013
-- Description:	Copy the new 
-- =============================================
Create PROCEDURE [dbo].[UpdNewFileEvidence]
	@EvidenceID int
	,@Description as nvarchar(250) = null
	,@Rationale as nvarchar(max) =null
	,@FileName as varchar(32) = null
	,@FileExt as varchar(5) = null
	,@FileSize int = null
	,@UserID as varchar(6) = null
	,@NewEvidenceID as int OUTPUT
	
AS
BEGIN
	SET NOCOUNT ON;
	select * from Evidence
	

END
GO
