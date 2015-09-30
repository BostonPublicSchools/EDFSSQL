SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/18/2013
-- Description:	Insert Indicators and observation detail into InsObservationDetailRubricIndicator
-- =============================================
CREATE PROCEDURE [dbo].[updObservationDetailRubricIndicator]

	@ObsvDID as int
	,@IndicatorID as int
	,@UserID AS nchar(6)
	,@IsDeleted as bit
AS
BEGIN
	SET NOCOUNT ON;
	
	update ObservationDetailRubricIndicator 
		set IsDeleted = @IsDeleted
			,LastUpdatedDt = GETDATE()
			,LastUpdatedByID = @UserID
	WHERE ObsvDID = @ObsvDID and IndicatorID =@IndicatorID
	
	
		
END
GO
