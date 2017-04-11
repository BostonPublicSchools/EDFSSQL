SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal
-- Create date: 07/26/2013
-- Description:	Get  ObservationDetailRubricIndicator by ObservationDetailID
-- =============================================
CREATE PROCEDURE [dbo].[getObservationDetailRubricIndicatorByObsvDID] @ObsvDID INT
AS
    BEGIN
        SET NOCOUNT ON;
	
        SELECT  odri.ObsvDetRubricID ,
                odri.ObsvDID ,
                odri.IndicatorID ,
                ri.IndicatorText ,
                rs.StandardID
        FROM    dbo.ObservationDetailRubricIndicator odri  ( NOLOCK )
                JOIN dbo.RubricIndicator ri ( NOLOCK ) ON ri.IndicatorID = odri.IndicatorID
                JOIN dbo.RubricStandard rs ( NOLOCK ) ON rs.StandardID = ri.StandardID
        WHERE   odri.ObsvDID = @ObsvDID
                AND odri.IsDeleted = 0;
	
    END;


GO
