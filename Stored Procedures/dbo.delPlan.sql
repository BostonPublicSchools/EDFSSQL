SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Newa,Matina
-- Create date: Nov 14, 2013
-- Description:	Delete Plan- empty
-- exec delplan 20147,'033400','091852'
-- =============================================
CREATE PROCEDURE [dbo].[delPlan]
	 @PlanID as int
	 ,@EmplID nchar(6)
	 ,@CreatedByID nchar(6)
	 ,@ReturnValue as int=null OUTPUT -- O FOR empty 
AS
BEGIN

Set @ReturnValue=0

IF EXISTS(SELECT PLANID FROM EmplPlan WHERE PlanID=@PlanID)
Begin
	Delete FROM EmplPlan 
	--OUTPUT deleted.PlanID 
	Where PlanID=@PlanID

	Set @ReturnValue = SCOPE_IDENTITY() --same as planid
	--IF(@ReturnValue=@PlanID)
		INSERT INTO ChangeLog (TableName, IdentityID, EmplID, LoggedEvent, EventDt, PreviousText, NewText, CreatedByID, CreatedByDt, LastUpdatedByID, LastUpdatedDt, IdentityEmplID)
		Values('EmplPlan',@PlanID,@CreatedByID,'Plan deleted for PlanID '+ CAST(@PlanID as nvarchar),GETDATE(),'','',@CreatedByID,GETDATE(),@CreatedByID,GETDATE(),@EmplID)
	
End
select @ReturnValue
 
END


GO
