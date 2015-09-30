SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  Khanpara, Krunal  
-- Create date: 07/18/2013  
-- Description: Insert Observation Detail new functionality  
-- =============================================  
CREATE PROCEDURE [dbo].[updObservationDetailNew]  
  
 --@ObsvID as int  
 --,@IndicatorID as int  
 @ObsvDEvidence as nvarchar(max)  
 ,@obsvDFeedBack as nvarchar(max)  
 ,@IsDeleted as bit = 0  
 ,@UserID AS nchar(6)  
 ,@ObsvDID int   
AS  
BEGIN  
 SET NOCOUNT ON;  
   
 If @obsvDFeedBack = null  
  select @obsvDFeedBack = obsvDFeedback from ObservationDetail where ObsvDID = @ObsvDID  
   
 if @ObsvDEvidence = null   
  select @ObsvDEvidence = obsvDEvidence from ObservationDetail where ObsvDID = @ObsvDID  
    
 UPDATE ObservationDetail  
  SET ObsvDEvidence = @ObsvDEvidence  
   ,ObsvDFeedBack = @obsvDFeedBack  
   ,IsDeleted = @IsDeleted  
   ,LastUpdatedByID = @UserID  
   ,LastUpdatedDt = GETDATE()  
  WHERE ObsvDID = @ObsvDID  
   
   
 --INSERT INTO ObservationDetail  
 --   (  
 --    ObsvID  
 --    ,IndicatorID  
 --    ,ObsvDEvidence  
 --    ,ObsvDFeedBack  
 --    ,CreatedByDt  
 --    ,CreatedByID  
 --    ,LastUpdatedByID  
 --    ,LastUpdatedDt   
 --   )  
 --   VALUES (@ObsvID,-1,@ObsvDEvidence,@obsvDFeedBack,GETDATE(),@UserID,@UserID,GETDATE())  
 --SELECT @ObsvDID = SCOPE_IDENTITY();  
    
   
    
END  
--select  top 100 * from ObservationDetail  
GO
