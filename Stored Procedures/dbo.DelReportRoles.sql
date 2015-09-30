SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	Delete the report roles from 
--report app role table.		
-- =============================================
CREATE PROCEDURE [dbo].[DelReportRoles]
	@ReportID AS int,
	@RoleID AS int,
	@UserID AS int
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM ReportAppRole 
	WHERE ReportID = @ReportID AND RoleID = @RoleID
END
GO
