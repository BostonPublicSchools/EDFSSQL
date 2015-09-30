SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 08/20/2012
-- Description:	update the employee admin status
-- =============================================
CREATE PROCEDURE [dbo].[updtEmplAdminStatus]
  @emplID as nchar(6),
  @isAdmin as bit, 
  @isContractor as bit,
  @hasReadOnly as bit,
  @primaryEvalID as nchar(6)
AS
BEGIN 
SET NOCOUNT ON;
	UPDATE Empl SET IsAdmin = @isAdmin,
	IsContractor = @isContractor ,
	HasReadOnlyAccess = @hasReadOnly,
	PrimaryEvalID = @primaryEvalID
	WHERE EmplID = @emplID
END
GO
