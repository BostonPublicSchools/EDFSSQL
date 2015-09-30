SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/18/2012
-- Description:	Update Observation Header
-- =============================================
CREATE PROCEDURE [dbo].[updObservationHeader]

	@ObsvID as int
	,@ObsvTypeID as int = null
	,@ObsvDt as varchar(100) = null
	,@ObsvStartTime as varchar(100) = null
	,@ObsvEndTime as varchar(100)= null
	,@IsDeleted as bit = null
	,@ObsvRelease as bit = null
	,@ObsvReleaseDt as varchar(150)= null
	,@IsEditEndDate as varchar(150)= NULL
	,@ObsvSubject as varchar(50) = null
	,@Comment as nvarchar(MAX) = null
	,@EmplComment as nvarchar(MAX) = null
	,@EmplIsEditEndDt varchar(150) = null
	,@UserID AS nchar(6) 
	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @EmplCommentDt as datetime ;
	set @EmplCommentDt = GETDATE();
	IF @ObsvTypeID = null or @ObsvTypeID = 0
		SELECT @ObsvTypeID = ObsvTypeID FROM ObservationHeader WHERE ObsvID = @ObsvID
	
	
	IF @ObsvDt = null
		SELECT @ObsvDt = obsvdt FROM ObservationHeader WHERE ObsvID = @ObsvID
	
	IF @ObsvStartTime = null
		SELECT @ObsvStartTime = obsvstarttime FROM ObservationHeader WHERE ObsvID = @ObsvID
	
	IF @ObsvEndTime = null
		SELECT @ObsvEndTime = ObsvEndTime FROM ObservationHeader WHERE ObsvID = @ObsvID
		
	IF @IsDeleted = null
		SELECT @IsDeleted = isdeleted FROM ObservationHeader WHERE ObsvID = @ObsvID
	
	IF @ObsvRelease = null
		SELECT @ObsvRelease = ObsvRelease  FROM ObservationHeader WHERE ObsvID = @ObsvID
	
	IF @ObsvReleaseDt = null
		SELECT @ObsvReleaseDt = obsvReleaseDt from ObservationHeader where ObsvID = @ObsvID
	
	IF @IsEditEndDate = NULL
	BEGIN
		SELECT @IsEditEndDate = IsEditEndDt from ObservationHeader where ObsvID = @ObsvID			
	END
	IF @ObsvSubject = null
	BEGIN
		SELECT @ObsvSubject = obsvSubject from ObservationHeader where ObsvID = @ObsvID
	END
	
	IF @EmplComment = null
	BEGIN
		SELECT @EmplComment = EmplComment from ObservationHeader where ObsvID = @ObsvID
		SELECT @EmplCommentDt = EmplCommentDt from ObservationHeader where ObsvID = @ObsvID
	END
	
	IF @Comment = null
		SELECT @Comment = Comment from ObservationHeader where ObsvID = @ObsvID
	
	IF @EmplIsEditEndDt = null
		SELECT @EmplIsEditEndDt =EmplIsEditEndDt  from ObservationHeader where ObsvID = @ObsvID	
		
		
		 if @IsEditEndDate <> null 
		 BEGIN
			UPDATE ObservationHeader SET
				ObsvDt = @ObsvDt
				,ObsvStartTime = @ObsvStartTime
				,ObsvEndTime = @ObsvEndTime
				,ObsvTypeID = @ObsvTypeID
				,ObsvRelease = @ObsvRelease
				,ObsvReleaseDt = @ObsvReleaseDt
				,ObsvSubject = @ObsvSubject
				,IsEditEndDt = @IsEditEndDate
				,Comment = @Comment
				,EmplComment = @EmplComment
				,emplcommentDt = @EmplCommentDt
				,EmplIsEditEndDt = @EmplIsEditEndDt
				,LastUpdatedByID = @UserID
				,LastUpdatedDt = GETDATE()
			WHERE ObsvID = @ObsvID
		END
		else
		BEGIN
		UPDATE ObservationHeader SET
				ObsvDt = @ObsvDt
				,ObsvStartTime = @ObsvStartTime
				,ObsvEndTime = @ObsvEndTime
				,ObsvTypeID = @ObsvTypeID
				,ObsvRelease = @ObsvRelease
				,ObsvSubject = @ObsvSubject
				,ObsvReleaseDt = @ObsvReleaseDt
				,Comment = @Comment
				,EmplComment = @EmplComment
				,emplcommentDt = @EmplCommentDt
				,EmplIsEditEndDt = @EmplIsEditEndDt
				,LastUpdatedByID = @UserID
				,LastUpdatedDt = GETDATE()
			WHERE ObsvID = @ObsvID
		END
	
	--INSERT INTO EmplPlan (EmplJobID, PlanYear, PlanTypeID, PlanStartDt, PlanEndDt, PlanActive, PlanEditLock, LastUpdatedByID, CreatedByID)
	--				VALUES (@EmplJobID, @PlanYear, @PlanTypeID, @PlanStartDt, @PlanEndDt, @PlanActive, @PlanEditLock, @UserID, @UserID) 
		
END
GO
