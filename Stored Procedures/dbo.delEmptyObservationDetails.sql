SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 12/12/2012
-- Description:	Delete Observation Detail when
-- the evidence and feedback is empty
-- =============================================
CREATE PROCEDURE [dbo].[delEmptyObservationDetails]
	@ObsvID int,
	@UserID AS nchar(6)
	
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE ObservationDetail  SET
		isDeleted = 1
		,LastUpdatedByID =@UserID
		,LastUpdatedDt = GETDATE()
	WHERE ObsvID = @ObsvID and (ObsvDEvidence = '' and ObsvDFeedBack = '')			
	
		
END
GO
