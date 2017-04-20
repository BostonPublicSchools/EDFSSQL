SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/14/2012
-- Description:	Get  ObservationDetail by ObservationID
-- =============================================
CREATE PROCEDURE [dbo].[getObservationDetailByObsvIDNew] @ObsvID INT
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @ObsvID1 INT;
	
        SET @ObsvID1 = @ObsvID;
	
        SELECT  od.ObsvDID ,
                od.ObsvID ,
                od.ObsvDEvidence ,
                od.ObsvDFeedBack
        FROM    dbo.ObservationDetail od
        WHERE   od.ObsvID = @ObsvID1
                AND od.IsDeleted = 0
        ORDER BY od.CreatedByDt ASC;
    END;


GO
