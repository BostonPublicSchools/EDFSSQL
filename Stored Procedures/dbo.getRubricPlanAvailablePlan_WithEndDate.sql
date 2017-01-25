SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa,Matina	
-- Create date: 09/23/2013
-- Description:	Gets Available RubricPlanAvilable associated with given RubricPlanTypeID and EndDate Too
				-- IsProvEmplClass is for Developing plan; like IsMultiYear for Sd Plan
				--IsJobChange signifies whether it is job change plan or not. When Jobchange it ignores eval and rating 
				-- Dependent on SP getRubricPlanEndDate
-- =============================================
CREATE PROCEDURE [dbo].[getRubricPlanAvailablePlan_WithEndDate]
    @RubricPlanTypeID INT = NULL
AS
    BEGIN
        SET NOCOUNT ON;
--declare @RubricPlanTypeID int =null
        DECLARE @sProvEmplClass NVARCHAR(10);
        SELECT  @sProvEmplClass = ( SUBSTRING(( SELECT  ','
                                                        + RTRIM(CAST(tbl.Code AS NVARCHAR))
                                                FROM    ( SELECT
                                                              cdCls.Code
                                                          FROM
                                                              dbo.CodeLookUp cdCls
                                                          WHERE
                                                              cdCls.CodeType = 'EmplClass'
                                                              AND cdCls.CodeActive = 1
                                                              AND cdCls.Code = 'U'
                                                          UNION
                                                          SELECT
                                                              cdCls.Code
                                                          FROM
                                                              dbo.CodeLookUp cdCls
                                                          WHERE
                                                              cdCls.CodeType = 'EmplClass'
                                                              AND cdCls.CodeActive = 1
                                                              AND cdCls.Code = 'V'
                                                          UNION
                                                          SELECT
                                                              cdCls.Code
                                                          FROM
                                                              dbo.CodeLookUp cdCls
                                                          WHERE
                                                              cdCls.CodeType = 'EmplClass'
                                                              AND cdCls.CodeActive = 1
                                                              AND cdCls.Code = 'W'
                                                          UNION
                                                          SELECT
                                                              cdCls.Code
                                                          FROM
                                                              dbo.CodeLookUp cdCls
                                                          WHERE
                                                              cdCls.CodeType = 'EmplClass'
                                                              AND cdCls.CodeActive = 1
                                                              AND cdCls.Code = 'X'
                                                        ) tbl
                                              FOR
                                                XML PATH('')
                                              ), 2, 99) );
--print @sProvEmplClass	
        DECLARE @CurrentSchYear VARCHAR(9) ,
            @NextSchYear VARCHAR(9); 
        DECLARE @sYearOneDate VARCHAR(4) ,
            @sYearTwoDate VARCHAR(4) ,
            @sYearThirdDate VARCHAR(MAX) ,
            @sDurationDate VARCHAR(4);

        DECLARE @TblRubricEndDate TABLE
            (
              ed_PlanEndDateID INT ,
              ed_RubricPlanTypeID INT ,
              ed_RubricID INT ,
              ed_EndTypeID INT ,
              ed_EndTypeText VARCHAR(50) ,
              ed_PlanEndDateTypeID INT ,
              ed_PlanEndDateTypeText VARCHAR(50) ,
              ed_DefaultPlanEndDate VARCHAR(6) ,
              ed_IsActive BIT ,
              ed_RubricName VARCHAR(50) ,
              ed_PlanTypeID INT ,
              ed_PlanType VARCHAR(50) ,
              ed_DefaultFullPlanEndDate VARCHAR(10) ,
              ed_DefaultFormativeValue NCHAR(5) ,
              ed_DefaultFormativeDate VARCHAR(10) ,
              ed_DefaultPlanEndDateMax VARCHAR(6) ,
              ed_DefaultFullPlanEndDateMax VARCHAR(10)
            );
        INSERT  INTO @TblRubricEndDate
                EXEC dbo.getRubricPlanEndDate;

        SELECT  rpPl.AvailablePlanID ,
                rpt.RubricPlanTypeID ,
                rpt.RubricID ,
                rh.RubricName ,
                rpt.PlanTypeID RubricPlanID ,
                cdRpl.CodeText RubricPlanType ,
                ISNULL(rpPl.RubricPlanIsMultiYear, 0) RubricPlanIsMultiYear ,
                ISNULL(rpPl.EvalTypeID, '') EvalTypeID ,
                ISNULL(cdEval.CodeText, '') EvalType ,
                ISNULL(rpPl.OverallRatingID, '') OverallRatingID ,
                ISNULL(cdRt.CodeText, '') OverRallRating ,
                rpPl.IsActive ,
                rpPl.AvaliablePlanTypeID ,
                CdAvPl.CodeText AvailablePlanType ,
                ISNULL(rpPl.IsMultiYear, 0) AvailableIsMultiYear
	
	--,ISNULL(rpPl.EmplClassID,'') [EmplClassID]
	--,ISNULL(cdCls.CodeText,'') [EmplClass]
                ,
                ( CASE WHEN rpPl.IsProvEmplClass = 'true' THEN @sProvEmplClass
                       ELSE ''
                  END ) EmplClass ,
                ISNULL(rpPl.IsProvEmplClass, 0) IsProvEmplClass ,
                ISNULL(rpPl.IsJobChange, 'false') IsJobChange ,
                ( CASE WHEN rpPl.IsMultiYear = 1
                            AND CdAvPl.CodeText = 'Self-Directed'
                       THEN ( SELECT TOP 1
                                        dt.ed_DefaultFullPlanEndDate
                              FROM      @TblRubricEndDate dt 
						--inner join CodeLookUp cl on dt.ed_PlanEndDateTypeID=cl.CodeID and cl.CodeType='EndDtType'  and cl.CodeText='End of Year Two'
                              WHERE     dt.ed_RubricID = rpt.RubricID
                                        AND CdAvPl.CodeID = dt.ed_PlanTypeID
                                        AND dt.ed_IsActive = 1
                                        AND dt.ed_EndTypeText = 'Select Year'
                                        AND dt.ed_PlanEndDateTypeText = 'End of Year Two'
                            )
                       WHEN rpPl.IsMultiYear = 0
                            AND CdAvPl.CodeText = 'Self-Directed'
                       THEN ( SELECT TOP 1
                                        dt.ed_DefaultFullPlanEndDate
                              FROM      @TblRubricEndDate dt 
					--	inner join CodeLookUp cl on dt.PlanEndDateTypeID=cl.CodeID and cl.CodeType='EndDtType' and cl.CodeText='End of Year One'
                              WHERE     dt.ed_RubricID = rpt.RubricID
                                        AND CdAvPl.CodeID = dt.ed_PlanTypeID
                                        AND dt.ed_IsActive = 1
                                        AND dt.ed_EndTypeText = 'Select Year'
                                        AND dt.ed_PlanEndDateTypeText = 'End of Year One'
                            )
                       WHEN NOT CdAvPl.CodeText = 'Self-Directed'
                       THEN ( SELECT TOP 1
                                        dt.ed_DefaultFullPlanEndDate
                              FROM      @TblRubricEndDate dt 
						--inner join CodeLookUp cl on dt.PlanEndDateTypeID=cl.CodeID and cl.CodeType='EndDtType'  
--					where dt.IsActive=1 and dt.RubricPlanTypeID=rpt.RubricPlanTypeID and dt.EndTypeID =(select Top 1 CodeID from CodeLookUp cldt where CodeType='EndType') )
                              WHERE     dt.ed_RubricID = rpt.RubricID
                                        AND CdAvPl.CodeID = dt.ed_PlanTypeID
                                        AND dt.ed_IsActive = 1
                            )
                  END ) DefaultEndDate ,
                ( CASE WHEN CdAvPl.CodeText = 'Directed Growth'
                            OR CdAvPl.CodeText = 'Improvement'
                       THEN CONVERT(VARCHAR(10), ( SELECT TOP 1
                                                            dt.ed_DefaultFullPlanEndDateMax
                                                   FROM     @TblRubricEndDate dt
                                                   WHERE    dt.ed_RubricID = rpt.RubricID
                                                            AND CdAvPl.CodeID = dt.ed_PlanTypeID
                                                            AND dt.ed_IsActive = 1
                                                 ))
                       ELSE ''
                  END ) DefaultEndDateMax
        FROM    dbo.RubricPlanType rpt
                INNER JOIN dbo.RubricPlanAvailablePlan rpPl ON rpt.RubricPlanTypeID = rpPl.RubricPlanTypeID
                INNER JOIN dbo.RubricHdr rh ON rh.RubricID = rpt.RubricID
                INNER JOIN dbo.CodeLookUp cdRpl ON rpt.PlanTypeID = cdRpl.CodeID
                                               AND cdRpl.CodeType = 'PlanType'
                                               AND cdRpl.CodeActive = 1
                LEFT JOIN dbo.CodeLookUp cdEval ON rpPl.EvalTypeID = cdEval.CodeID
                                               AND cdEval.CodeType = 'EvalType'
                                               AND cdEval.CodeActive = 1
                LEFT JOIN dbo.CodeLookUp cdRt ON rpPl.OverallRatingID = cdRt.CodeID
                                             AND cdRt.CodeType = 'EvalRating'
                                             AND cdRt.CodeActive = 1
                                             AND cdRt.CodeSubText = rh.RubricName
                INNER JOIN dbo.CodeLookUp CdAvPl ON rpPl.AvaliablePlanTypeID = CdAvPl.CodeID
                                                AND CdAvPl.CodeType = 'PlanType'
                                                AND CdAvPl.CodeActive = 1
                LEFT JOIN dbo.CodeLookUp cdCls ON rpPl.EmplClassID = cdCls.CodeID
                                              AND cdCls.CodeType = 'EmplClass'
                                              AND cdCls.CodeActive = 1
        WHERE   rpt.IsActive = 1 --AND rpPl.IsActive=1
	--And (rpPl.isNewJob is null or rpPl.isNewJob = 0)
                AND rpPl.RubricPlanTypeID = ( CASE WHEN @RubricPlanTypeID IS NOT NULL
                                                   THEN @RubricPlanTypeID
                                                   ELSE rpPl.RubricPlanTypeID
                                              END )--@RubricPlanTypeID
        ORDER BY rpPl.RubricPlanTypeID;
    END;


GO
