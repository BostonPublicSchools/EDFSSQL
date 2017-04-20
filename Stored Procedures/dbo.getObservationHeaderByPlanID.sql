SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 09/14/2012
-- Description:	Get  ObservationHeader by PlanID
-- =============================================
CREATE PROCEDURE [dbo].[getObservationHeaderByPlanID] @PlanID INT
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @PlanID1 INT;
        SET @PlanID1 = @PlanID;
        
		SELECT  oh.ObsvID ,
                oh.PlanID ,
                oh.ObsvTypeID ,
                cl.CodeText AS ObservationType ,
                oh.ObsvDt ,
                oh.ObsvRelease ,
                oh.ObsvReleaseDt ,
                oh.ObsvStartTime ,
                oh.ObsvEndTime ,
                oh.IsEditEndDt ,
                e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle,
                                                              '') + ' ('
                + e.EmplID + ')' AS CreatedBy ,
                oh.CreatedByID ,
                oh.Comment ,
                oh.EmplComment ,
                oh.EmplIsEditEndDt ,
                oh.ObsvSubject ,
                oh.IsEmplViewed ,
                oh.EmplViewedDate
        FROM    dbo.ObservationHeader oh ( NOLOCK )
                JOIN dbo.CodeLookUp cl ( NOLOCK ) ON cl.CodeID = oh.ObsvTypeID
                JOIN dbo.Empl e ( NOLOCK ) ON e.EmplID = oh.CreatedByID
        WHERE   oh.PlanID = @PlanID1
                AND oh.IsDeleted = 0
        ORDER BY oh.ObsvDt DESC ,
                oh.CreatedByDt DESC;
    END;
GO
