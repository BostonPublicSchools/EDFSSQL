SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	update the parameter table.		
-- =============================================
CREATE PROCEDURE [dbo].[UpdateParamName]
	@ParamID AS int,
	@ParamName AS nvarchar(50),
	@UserID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE ReportParameter SET ReportParameterName = @ParamName,
							   LastUpdatedByID = @UserID,
							   LastUpdatedDt = GETDATE()
    WHERE ReportParameterID = @ParamID
END
GO
