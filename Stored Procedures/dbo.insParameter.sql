SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	insert the new param	
-- =============================================
CREATE PROCEDURE [dbo].[insParameter]
	@ParamName AS nvarchar(50),
	@UserID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO ReportParameter(ReportParameterName, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt)
	VALUES(@ParamName, @UserID, GETDATE(), @UserID, GETDATE())
END
GO
