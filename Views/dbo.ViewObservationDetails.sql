SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 06/19/2013
-- Description: 
-- =============================================


CREATE VIEW [dbo].[ViewObservationDetails]
AS
    SELECT  ObsvDID ,
            ObsvID ,
            IndicatorID ,
            ObsvDEvidence ,
            ObsvDFeedBack ,
            CreatedByID ,
            CreatedByDt ,
            LastUpdatedByID ,
            LastUpdatedDt ,
            IsDeleted
    FROM    dbo.ObservationDetail;


GO
