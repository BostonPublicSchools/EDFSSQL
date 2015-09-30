SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Newa,Matina>
-- Create date: <03/18/2013>
-- Description:	<Gets all the Notification by Emplid>
-- =============================================
CREATE PROCEDURE [dbo].[getNotificationsByEmpl]
	@EmplID as nchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT  
			nl.NotificationLogID, 
			nl.PlanID, 
			nl.ToAddress,
			nl.FromAddress, 
			nl.EmailMessage,
			nl.CreatedByID, 
			nl.CreatedDt,
			nl.LastUpdatedByID, 
			nl.LastUpdatedDt
		   ,ISNULL(e.NameFirst, '')+ ' ' +ISNULL(e.NameMiddle,'')+ ' '+ISNULL(e.NameLast,'') as CreatedByName 
		   ,epp.IsInvalid as IsPlanInValid	
	FROM NotificationsLog nl (NOLOCK)
	INNER JOIN (
		select ep.EmplJobID,ep.PlanID, epj.EmplID,ep.IsInvalid from EmplPlan ep inner join  EmplEmplJob epj on ep.EmplJobID=epj.EmplJobID 		
		where epj.EmplID=@EmplID
	)  epp 	ON nl.PlanID = epp.PlanID
	
	LEFT JOIN Empl e on nl.CreatedByID=e.EmplID 
	Where nl.PlanID>=0
	union	
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
		   , 0 IsPlanInValid
	FROM NotificationsLog nll (NOLOCK)
	LEFT JOIN Empl e on nll.CreatedByID=e.EmplID 
	where (nll.PlanID =-9999 or nll.PlanID=0)  and nll.ToAddress like '%'+@EmplID+'%'		
	ORDER BY NotificationLogID desc 
 	
END

GO
