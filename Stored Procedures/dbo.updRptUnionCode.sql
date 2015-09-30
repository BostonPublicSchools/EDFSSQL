SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	Update the union code
-- =============================================
CREATE PROCEDURE [dbo].[updRptUnionCode]
	@JobCode as nchar(6),
	@UnionCode as nchar(3),
	@IsActive as bit
	
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE RptUnionCode SET IsActive = @IsActive
	WHERE UnionCode = @UnionCode AND JobCode = @JobCode
	
END
GO
