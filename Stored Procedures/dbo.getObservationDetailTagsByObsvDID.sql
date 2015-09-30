SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/14/2012
-- Description:	Get  ObservationDetail Tags by ObservationDetailID
-- =============================================
CREATE PROCEDURE [dbo].[getObservationDetailTagsByObsvDID]
@ObsvDID int
	
	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ObsvDID1 int
	
	
	SET @ObsvDID1 = @ObsvDID
	
	
	SELECT IndicatorID 
	from dbo.ObservationDetailRubricIndicator
	where isdeleted = 0 and ObsvDID = @ObsvDID1
END


GO
