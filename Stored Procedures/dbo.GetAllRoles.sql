SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	Get all the roles
-- =============================================
CREATE PROCEDURE [dbo].[GetAllRoles]
	
AS
BEGIN
	SET NOCOUNT ON;
	SELECT RoleID, RoleDesc, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt
	FROM AppRole
END
GO
