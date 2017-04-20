SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/14/2012
-- Description:	Get  ObservationHeader by ID
-- =============================================
CREATE PROCEDURE [dbo].[getObservationHeaderByID] @ObsvID INT
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @ObsvID1 INT;
        SET @ObsvID1 = @ObsvID;
	
        SELECT  oh.ObsvID ,
                oh.PlanID ,
                oh.ObsvTypeID ,
                cl.CodeText AS ObsvType ,
                CONVERT(VARCHAR, oh.ObsvDt, 101) AS obsvDt ,
                oh.ObsvRelease ,
                oh.ObsvReleaseDt ,
                oh.ObsvStartTime ,
                oh.ObsvEndTime ,
                oh.IsDeleted ,
                oh.IsEditEndDt ,
                oh.Comment ,
                oh.EmplComment ,
                oh.EmplIsEditEndDt ,
                oh.ObsvSubject ,
                oh.IsEmplViewed ,
                oh.EmplViewedDate
        FROM    dbo.ObservationHeader oh ( NOLOCK )
                LEFT JOIN dbo.CodeLookUp cl ( NOLOCK ) ON cl.CodeID = oh.ObsvTypeID
        WHERE   oh.ObsvID = @ObsvID1;	
    END;
GO
