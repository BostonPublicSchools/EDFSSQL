SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/14/2012
-- Description:	Get  ObservationDetail by ID
-- =============================================
CREATE PROCEDURE [dbo].[getObservationDetailByID] @ObsvDID INT
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @ObsvDID1 INT;
        SET @ObsvDID1 = @ObsvDID;
	
        SELECT  od.ObsvDID ,
                od.ObsvID ,
                ord.IndicatorID ,
                od.ObsvDEvidence ,
                od.ObsvDFeedBack ,
                ri.IndicatorText ,
                rs.StandardText
        FROM    dbo.ObservationDetail od ( NOLOCK )
                LEFT JOIN dbo.ObservationDetailRubricIndicator ord ( NOLOCK ) ON od.ObsvDID = ord.ObsvDID
                LEFT JOIN dbo.RubricIndicator ri ( NOLOCK ) ON ri.IndicatorID = ord.IndicatorID
                LEFT JOIN dbo.RubricStandard rs ( NOLOCK ) ON rs.StandardID = ri.StandardID
        WHERE   od.ObsvDID = @ObsvDID1;	
    END;
GO
