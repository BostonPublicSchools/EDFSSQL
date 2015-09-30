SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan, Devi	
-- Create date: 08/21/2012
-- Description: update the eval ID in the emplemplJob
-- =============================================

CREATE PROCEDURE [dbo].[updateSubEval]
	@EmplJobID int,
	@EmplEmplId int,
	@EmplEvalID nchar(6)
AS
BEGIN
SET NOCOUNT ON;
    UPDATE EmplEmplJob SET SubEvalID = @EmplEvalID
	WHERE EmplID = @EmplEmplId AND EmplJobID = @EmplJobID
END
GO
