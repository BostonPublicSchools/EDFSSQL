SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/14/2012
-- Description:	Get  ObservationDetail Tags by ObservationDetailID
-- =============================================
CREATE PROCEDURE [dbo].[getObservationDetailTagsByObsvDID] @ObsvDID INT
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @ObsvDID1 INT;
	
	
        SET @ObsvDID1 = @ObsvDID;
	
	
        SELECT  IndicatorID
        FROM    dbo.ObservationDetailRubricIndicator ( NOLOCK )
        WHERE   IsDeleted = 0
                AND ObsvDID = @ObsvDID1;
    END;


GO
