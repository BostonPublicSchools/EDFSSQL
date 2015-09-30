SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/14/2012
-- Description:	Insert Observation Detail
-- =============================================
CREATE PROCEDURE [dbo].[insObservationDetail]

	@ObsvID as int
	,@IndicatorID as int
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
				VALUES (@ObsvID,@IndicatorID,@ObsvDEvidence,@obsvDFeedBack,GETDATE(),@UserID,@UserID,GETDATE())
	SELECT @ObsvDID = SCOPE_IDENTITY();
		
	
		
END
GO
