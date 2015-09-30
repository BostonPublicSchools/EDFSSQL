SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =========================================================
-- Author:		Ganesan, Devi	
-- Create date: 12/28/2012
-- Description:	get all empl notifications
-- Note: Notificationlog.PlanID =-9999 is used for Temporary Access in Empl table
-- =========================================================
CREATE PROCEDURE [dbo].[getAllEmplNotifications] 
	@EmplID as nchar(6)
	,@ExcludeInValidPlan as bit = 0
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT nl.NotificationLogID, 
			nl.PlanID, 
			nl.ToAddress,
			nl.FromAddress, 
			nl.EmailMessage,
			nl.CreatedByID, 
			nl.CreatedDt,
			nl.LastUpdatedByID, 
			nl.LastUpdatedDt
			,ISNULL(e.NameFirst, '')+ ' ' +ISNULL(e.NameMiddle,'')+ ' '+ISNULL(e.NameLast,'') as CreatedByName 
			,ej.EmplID		
			,ep.IsInvalid as IsPlanInValid	
	FROM NotificationsLog nl (NOLOCK)
	JOIN EmplPlan ep (NOLOCK) ON ep.PlanID = nl.PlanID AND nl.PlanID!=-9999 And ep.IsInvalid = (case when @ExcludeInValidPlan = 1 then 0 else ep.IsInvalid end)
	LEFT JOIN EmplEmplJob ej (NOLOCK) ON ej.EmplJobID = ep.EmplJobID
	left join SubevalAssignedEmplEmplJob as ase (nolock) on ej.EmplJobID = ase.EmplJobID
																	and ase.isActive = 1
																	and ase.isDeleted = 0
																	and ase.isPrimary = 1
	left join SubEval s (nolock) on ase.SubEvalID = s.EvalID
	LEFT JOIN EmplExceptions ex (NOLOCK) ON ex.EmplJobID = ep.EmplJobID
	LEFT JOIN Empl e (NOLOCK) ON e.EmplID = nl.CreatedByID
	WHERE ej.MgrID = @EmplID OR 
		 ex.MgrID = @EmplID  OR 
		 s.EmplID = @EmplID  OR
		 ej.EmplID = @EmplID OR
		 nl.ToAddress like '%'+@EmplID+'%'	
	
UNION
	SELECT  
			nll.NotificationLogID, 
			nll.PlanID, 
			nll.ToAddress,
			nll.FromAddress, 
			nll.EmailMessage,
			nll.CreatedByID, 
			nll.CreatedDt,
			nll.LastUpdatedByID, 
			nll.LastUpdatedDt
		   ,ISNULL(e.NameFirst, '')+ ' ' +ISNULL(e.NameMiddle,'')+ ' '+ISNULL(e.NameLast,'') as CreatedByName 
		   ,@EmplID
		   , 0 IsPlanInValid
	FROM NotificationsLog nll (NOLOCK)
	LEFT JOIN Empl e on nll.CreatedByID=e.EmplID 
	where nll.PlanID =-9999 and nll.ToAddress like '%'+@EmplID+'%'		
		
	ORDER BY nl.CreatedDt DESC
END
GO
