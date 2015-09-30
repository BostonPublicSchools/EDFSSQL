SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/18/2012
-- Description:	Update Observation Detail
-- =============================================
CREATE PROCEDURE [dbo].[updObservationDetail]

	
	@ObsvDID int 
	,@IndicatorID int
	,@ObsvDEvidence as nvarchar(max)=null
	,@obsvDFeedBack as nvarchar(max)=null
	,@UserID AS nchar(6)
	
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @obsvDFeedBack = null
		SELECT @obsvDFeedBack = obsvdfeedback FROM ObservationDetail WHERE ObsvDID = @ObsvDID
		
	IF @ObsvDEvidence = null
		SELECT @ObsvDEvidence = obsvdevidence FROM ObservationDetail WHERE ObsvDID = @ObsvDID
	
	UPDATE ObservationDetail  SET
				ObsvDEvidence = @ObsvDEvidence
				,IndicatorID = @IndicatorID
				,ObsvDFeedBack = @obsvDFeedBack
				,LastUpdatedByID =@UserID
				,LastUpdatedDt = GETDATE()
	WHERE ObsvDID = @ObsvDID			
	
		
END
GO
