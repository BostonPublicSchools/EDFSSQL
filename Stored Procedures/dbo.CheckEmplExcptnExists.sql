SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 08/15/2012
-- Description:	check if the record for empl and empljobid
--				already exists.				
-- =============================================
CREATE PROCEDURE [dbo].[CheckEmplExcptnExists]
	@ExEmplID as nchar(6),
	@ExEmplJobID as int,
	@ExMgrID as nchar(6),
	@IsExists as int= null OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @IsExists = 0
	IF EXISTS(SELECT ExceptionID FROM EmplExceptions WHERE 
				EmplID = @ExEmplID AND
				EmplJobID = @ExEmplJobID AND
				MgrID = @ExMgrID)	  
	BEGIN
	  SET @IsExists = 1
	END
END




GO
