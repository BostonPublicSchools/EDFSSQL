SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/17/2012
-- Description:	delete the rptUnion Code
-- =============================================
CREATE PROCEDURE [dbo].[delRptUnionCode]
	@JobCode as nchar(6),
	@UnionCode as nchar(3)
	
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM RptUnionCode 
	WHERE UnionCode = @UnionCode AND JobCode = @JobCode
	
END
GO
