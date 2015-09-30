SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	insert the newly added report roles
--				to the reportrole table.
-- =============================================
CREATE PROCEDURE [dbo].[insertNewReport]
	 @ReportName AS nvarchar(50)
	 ,@ReportProcedureName as nvarchar(200) = null
	 ,@ReportSelectedColumns as nvarchar(Max) = null
	 ,@IsDeleted as bit
	,@UserID AS nchar(6)
	,@ReportID AS int = null OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO Report(ReportName, procedureName, selectedRptColumns, IsDeleted, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
	VALUES(@ReportName, @ReportProcedureName, @ReportSelectedColumns, @IsDeleted, @UserID, GETDATE(), @UserID, GETDATE())
	
	SET @ReportID = SCOPE_IDENTITY();
	
END
GO
