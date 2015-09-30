SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Newa,Matina
-- Create date: 05/06/2013
-- Description:	Get rubric with standard and Indicator
--              The reterived rubric are 1,2,3 and 4 only
--				exec getRubricStandardAndIndicator
-- =============================================
CREATE PROCEDURE [dbo].[getRubricStandardAndIndicator]
	
AS
BEGIN
	
	SET NOCOUNT ON;

    select rs.StandardID,rs.StandardText,0 IndicatorID,'' IndicatorText, rs.RubricID ,rh.RubricName
		from RubricStandard rs inner join RubricHdr rh on rs.RubricID=rh.RubricID
		where rs.IsDeleted=0 and rh.IsDeleted=0 --and StandardText like 'I%'
	UNION
	select rs.StandardID,rs.StandardText,ri.IndicatorID,ri.IndicatorText,rs.RubricID,rh.RubricName 
		from RubricIndicator ri inner join RubricStandard rs on ri.StandardID=rs.StandardID 
			inner join RubricHdr rh on rs.RubricID=rh.RubricID
		where ri.ParentIndicatorID=0 and rs.IsDeleted=0 --and rs.StandardText like 'I%'	
			and ri.IsDeleted=0 and rh.IsDeleted=0
		order by RubricID asc, StandardText,IndicatorText
END

GO
