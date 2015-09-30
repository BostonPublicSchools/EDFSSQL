SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 08/13/20130
-- Description: get the primary emplJobID by emplID
-- =============================================

CREATE Function [dbo].[funcGetPrimaryEmplJobByEmplID](@EmplID nvarchar(6))
Returns int
AS
BEGIN
	DECLARE @PrimaryEmplJobID int
	 SELECT top 1  @PrimaryEmplJobID = EmplJobID 
	 FROM EmplEmplJob
	 WHERE EmplID = @EmplID and IsActive = 1
	 ORDER BY FTE desc, EmplRcdNo asc
	 
	 RETURN @PrimaryEmplJobID
END
GO
