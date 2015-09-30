SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	update the report name and path	
-- =============================================
CREATE PROCEDURE [dbo].[updtReport]
	@ReportID AS int,
	@ReportName AS nvarchar(50) = null,
	@ReportSelectedColumns as nvarchar(Max) = null,
	--@ReportPath AS nvarchar(250),
	@IsDeleted as bit,
	@UserID AS nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE Report SET ReportName = CASE WHEN @ReportName IS NULL THEN ReportName ELSE @ReportName END,
					  IsDeleted = @IsDeleted,
					  selectedRptColumns = @ReportSelectedColumns,
					  --ReportPath = @ReportPath,
					  LastUpdatedByID = @UserID,
					  LastUpdatedDt = GETDATE()
	WHERE ReportID = @ReportID
END
GO
