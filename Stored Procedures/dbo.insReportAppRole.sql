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
CREATE PROCEDURE [dbo].[insReportAppRole]
	@ReportID AS int,
	@RoleID AS int,
	@UserID AS int
AS
BEGIN
	SET NOCOUNT ON;
	IF NOT EXISTS(Select ReportAppRoleID FROM ReportAppRole WHERE ReportID = @ReportID AND RoleID = @RoleID)
	BEGIN
		INSERT INTO ReportAppRole(ReportID, RoleID, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
		VALUES(@ReportID, @RoleID, @UserID, GETDATE(), @UserID, GETDATE())
	END
END
GO
