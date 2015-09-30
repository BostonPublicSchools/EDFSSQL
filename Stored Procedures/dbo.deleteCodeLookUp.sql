SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/15/2012
-- Description:	insert new code
-- =============================================
CREATE PROCEDURE [dbo].[deleteCodeLookUp]
	@CodeID as int,
	@CodeType as nchar(10)
AS
BEGIN
	SET NOCOUNT ON;
	
	DELETE FROM CodeLookUp WHERE CodeID =@CodeID AND CodeType = @CodeType
	
END




GO
