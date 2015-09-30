SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =========================================================  
-- Author:  Ganesan, Devi   
-- Create date: 12/28/2012  
-- Description: insert a new notifications log  
-- =========================================================  
CREATE PROCEDURE [dbo].[InsNotificationsLog]  
 @PlanID as int  
 ,@ToAddress as nchar(100)  
 ,@FromAddress as nchar(100)  
 ,@Message as nvarchar(max)  
 ,@UserID as nchar(6)  
AS  
BEGIN  
 SET NOCOUNT ON;  
 INSERT INTO NotificationsLog(PlanID, ToAddress, FromAddress, EmailMessage, CreatedByID, CreatedDt, LastUpdatedByID, LastUpdatedDt)  
 VALUES(@PlanID, @ToAddress, @FromAddress, @Message, @UserID, GETDATE(), @UserID, GETDATE())  
   
END  
GO
