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
CREATE PROCEDURE [dbo].[getAllIndicatorAsmntByID]
	@indicatorID as int
AS
BEGIN
	SET NOCOUNT ON;
SELECT ri.IndicatorID, ris.IndicatorID as asmntIndicatorID, ri.IndicatorDesc, ri.IndicatorText, ris.CodeID, cdl.CodeText,
	   ris.AssmtID, ris.AssmtText FROM RubricIndicator  ri
LEFT OUTER JOIN RubricIndicatorAssmt ris ON ris.IndicatorID = ri.IndicatorID
LEFT OUTER JOIN CodeLookUp cdl ON cdl.CodeID = ris.CodeID
WHERE ParentIndicatorID = @indicatorID AND ri.IsActive = 1 and IsDeleted=0
ORDER BY ri.IndicatorText asc,ris.CodeID desc --ri.IndicatorID, ris.CodeID

--SELECT
--        1           tag,
--        NULL        parent,
--        ri.IndicatorID  [Indicator!1!IndicatorID],
--        ri.IndicatorDesc   [Indicator!1!IndicatorDesc],
--        NULL        [Assessment!2!AssmtID],
--        NULL        [Assessment!2!AssmtText],
--        NULL        [Assessment!2!CodeID],
--        NULL        [Assessment!2!CodeText]
--FROM RubricIndicator  ri
--WHERE ParentIndicatorID = 69 AND ri.IsActive = 1
--UNION ALL 
--SELECT
--        2,
--        1,
--        ri2.IndicatorID,
--        NULL,
--        ris.AssmtID, 
--        ris.AssmtText,
--        ris.CodeID, 
--        cdl.CodeText
--FROM RubricIndicator  ri2
--LEFT OUTER JOIN RubricIndicatorAssmt ris ON ris.IndicatorID = ri2.IndicatorID
--LEFT OUTER JOIN CodeLookUp cdl ON cdl.CodeID = ris.CodeID
--WHERE ParentIndicatorID = 69 AND ri2.IsActive = 1
--ORDER BY ri.IndicatorID
--FOR XML EXPLICIT;
                    
END
GO
