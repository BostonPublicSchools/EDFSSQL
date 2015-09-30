SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/14/2012
-- Description:	Insert Observation Header
-- =============================================
CREATE PROCEDURE [dbo].[insObservationHeader]


@PlanID as int
	,@ObsvTypeID as int
	,@ObsvDt as varchar(100)
	,@ObsvStartTime as varchar(100)
	,@ObsvEndTime as varchar(100)
	,@ObsvSubject as varchar(50)
	,@UserID AS nchar(6)
	,@Comment as nvarchar(max)
	,@ObsvRelease as bit 
	,@IsFromIpad as bit
	,@ObsvReleaseDt as varchar(100) = null
	,@IsEditEndDate as varchar(100) = null
	,@EmplIsEditEndDt varchar(150) = null
	,@ObsvID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	
	IF @IsEditEndDate = null
	BEGIN
		set @IsEditEndDate = GETDATE();
	END
	INSERT INTO ObservationHeader
				(
					PlanID
					,ObsvTypeID
					,ObsvDt
					,ObsvStartTime
					,ObsvEndTime
					,CreatedByDt
					,CreatedByID
					,LastUpdatedByID
					,LastUpdatedDt	
					,Comment
					,ObsvRelease
					,ObsvReleaseDt
					,IsEditEndDt
					,ObsvSubject
					,EmplIsEditEndDt
					,IsFromIpad
				)
				VALUES (@PlanID,@ObsvTypeID,@ObsvDt,@ObsvStartTime,@ObsvEndTime,GETDATE(),@UserID,@UserID,GETDATE(),@Comment,@ObsvRelease,@ObsvReleaseDt,@IsEditEndDate,@ObsvSubject, @EmplIsEditEndDt,@IsFromIpad)
	SELECT @ObsvID = SCOPE_IDENTITY();
	

END
GO
