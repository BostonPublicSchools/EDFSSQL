SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 10/04/2012
-- Description:	Get all the indicator assessment 
-- by indicator id.
-- =============================================
CREATE PROCEDURE [dbo].[getAllIndicatorAsmntByID] @indicatorID AS INT
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT  ri.IndicatorID ,
                ris.IndicatorID AS asmntIndicatorID ,
                ri.IndicatorDesc ,
                ri.IndicatorText ,
                ris.CodeID ,
                cdl.CodeText ,
                ris.AssmtID ,
                ris.AssmtText
        FROM    dbo.RubricIndicator ri ( NOLOCK )
                LEFT OUTER JOIN dbo.RubricIndicatorAssmt ris ( NOLOCK ) ON ris.IndicatorID = ri.IndicatorID
                LEFT OUTER JOIN dbo.CodeLookUp cdl ( NOLOCK ) ON cdl.CodeID = ris.CodeID
        WHERE   ri.ParentIndicatorID = @indicatorID
                AND ri.IsActive = 1
                AND ri.IsDeleted = 0
        ORDER BY ri.IndicatorText ASC ,
                ris.CodeID DESC;
                    
    END;
GO
