SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/24/2012
-- Description:	get all the observations of all 
-- employees for a manager and his own observation
-- =============================================
CREATE PROCEDURE [dbo].[getObservationHeaderByEmplID]
    @EmplID AS NCHAR(6) ,
    @ExcludeInValidPlan AS BIT = 0
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @EmplID1 AS NCHAR(6);
        SET @EmplID1 = @EmplID;
        SELECT  Obs.ObsvID ,
                Obs.PlanID ,
                cdl.CodeText AS PlanType ,
                eplan.PlanTypeID ,
                eplan.PlanActive ,
                eplan.IsInvalid AS PlanIsInValid ,
                Obs.ObsvTypeID ,
                cd2.CodeText AS ObsvType ,
                Obs.ObsvRelease ,
                Obs.ObsvReleaseDt ,
                Obs.IsDeleted ,
                Obs.IsEditEndDt ,
                ISNULL(empl.NameFirst, '') + ' ' + ISNULL(empl.NameMiddle, '')
                + ' ' + ISNULL(empl.NameLast, '') + ' (' + empl.EmplID + ')' AS EmplName ,
                ejob.EmplID AS EmplID ,
                Obs.EmplIsEditEndDt ,
                Obs.ObsvDt ,
                Obs.ObsvEndTime ,
                Obs.ObsvStartTime ,
                Obs.ObsvSubject ,
                Obs.Comment ,
                Obs.EmplComment ,
                Obs.CreatedByID ,
                ISNULL(empl1.NameFirst, '') + ' ' + ISNULL(empl1.NameMiddle,
                                                           '') + ' '
                + ISNULL(empl1.NameLast, '') + ' (' + empl1.EmplID + ')' AS CreatedBy ,
                Obs.IsEmplViewed ,
                Obs.EmplViewedDate ,
                Obs.IsFromIpad
        FROM    dbo.ObservationHeader Obs ( NOLOCK )
                JOIN dbo.EmplPlan eplan ( NOLOCK ) ON eplan.IsInvalid = ( CASE
                                                              WHEN @ExcludeInValidPlan = 1
                                                              THEN 0
                                                              ELSE eplan.IsInvalid
                                                              END )
                                                      AND eplan.PlanID = Obs.PlanID
                LEFT OUTER JOIN dbo.EmplExceptions emplEx ( NOLOCK ) ON emplEx.EmplJobID = eplan.EmplJobID
                JOIN dbo.EmplEmplJob ejob ( NOLOCK ) ON ejob.EmplJobID = eplan.EmplJobID
                LEFT OUTER JOIN dbo.CodeLookUp cdl ( NOLOCK ) ON cdl.CodeType = 'PlanType'
                                                              AND cdl.CodeID = eplan.PlanTypeID
                LEFT OUTER JOIN dbo.CodeLookUp cd2 ( NOLOCK ) ON cd2.CodeType = 'ObsvType'
                                                              AND cd2.CodeID = Obs.ObsvTypeID
                LEFT OUTER JOIN dbo.Empl empl ( NOLOCK ) ON empl.EmplID = ejob.EmplID
                LEFT OUTER JOIN dbo.Empl empl1 ( NOLOCK ) ON empl1.EmplID = Obs.CreatedByID
        WHERE   ( CASE WHEN ( emplEx.MgrID IS NOT NULL ) THEN emplEx.MgrID
                       ELSE ejob.MgrID
                  END ) = @EmplID1
                OR ejob.EmplID = @EmplID1
        ORDER BY Obs.ObsvDt DESC;
    END;
GO
