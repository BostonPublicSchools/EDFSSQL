SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 09/21/2012
-- Description: insert new unioncode into rptUnionCode
-- =============================================
CREATE PROCEDURE [dbo].[insertNewRptUnionCode]
	@JobCode AS nchar(6),
	@JobName AS nvarchar(50),
	@UnionCode AS nchar(3),
	@UserID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO RptUnionCode(JobCode, JobName, UnionCode, CreatedByDt, CreatedByID, LastUpdatedDt, LastUpdatedID)
	VALUES(@JobCode, @JobName, @UnionCode, GETDATE(), @UserID, GETDATE(), @UserID)
		
END
GO
