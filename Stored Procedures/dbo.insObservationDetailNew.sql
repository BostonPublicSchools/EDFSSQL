SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/18/2013
-- Description:	Insert Observation Detail new functionality
-- =============================================
CREATE PROCEDURE [dbo].[insObservationDetailNew]

	@ObsvID as int
	--,@IndicatorID as int
	,@ObsvDEvidence as nvarchar(max)
	,@obsvDFeedBack as nvarchar(max)
	,@UserID AS nchar(6)
	,@ObsvDID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO ObservationDetail
				(
					ObsvID
					,IndicatorID
					,ObsvDEvidence
					,ObsvDFeedBack
					,CreatedByDt
					,CreatedByID
					,LastUpdatedByID
					,LastUpdatedDt	
				)
				VALUES (@ObsvID,-1,@ObsvDEvidence,@obsvDFeedBack,GETDATE(),@UserID,@UserID,GETDATE())
	SELECT @ObsvDID = SCOPE_IDENTITY();
		
	
		
END
GO
