SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 09/05/2012
-- Description: update the departments and other tables
-- =============================================
CREATE PROCEDURE [dbo].[updateDeptManager]
    @DeptID AS NCHAR(6) ,
    @DeptMgrId AS NCHAR(6) ,
    @DeptIsSchool AS BIT ,
    @DeptUpdatedById AS NCHAR(6) ,
    @OldManagerID AS NCHAR(6) ,
    @isManagerChanged AS BIT ,
    @DeptCategoryId AS INT ,
    @ImplSpecialistID AS NCHAR(6) = NULL ,
    @DeptRptEmplID AS NCHAR(6) = NULL
AS
    BEGIN 
        SET NOCOUNT ON;

        IF @isManagerChanged = 0
            BEGIN
                UPDATE  dbo.Department
                SET     IsSchool = @DeptIsSchool ,
                        LastUpdatedByID = @DeptUpdatedById ,
                        ImplSpecialistID = @ImplSpecialistID ,
                        DeptRptEmplID = ( CASE WHEN @DeptRptEmplID IS NOT NULL
                                               THEN @DeptRptEmplID
                                               ELSE DeptRptEmplID
                                          END ) ,
                        DeptCategoryID = ( CASE WHEN @DeptCategoryId != 0
                                                THEN @DeptCategoryId
                                                ELSE NULL
                                           END ) ,
                        LastUpdatedDt = GETDATE()
                WHERE   DeptID = @DeptID;
            END;

        ELSE
            BEGIN
	
	/**
	* if the selected new manager is subeval of the same department,
	* then inactivate all the subevalassigned empljob records.
	**/	
                IF ( EXISTS ( SELECT    EvalID 
                              FROM      dbo.SubEval
                              WHERE     EmplID = @DeptMgrId
                                        AND EvalActive = 1 ) )
                    BEGIN 
                        UPDATE  dbo.SubevalAssignedEmplEmplJob
                        SET     IsActive = 0 ,
                                LastUpdatedByID = @DeptUpdatedById ,
                                LastUpdatedDt = GETDATE()
                        WHERE   AssignedSubevaluatorID IN (
                                SELECT  AssignedSubevaluatorID
                                FROM    dbo.SubevalAssignedEmplEmplJob
                                WHERE   EmplJobID IN ( SELECT EmplJobID
                                                       FROM   dbo.EmplEmplJob
                                                       WHERE  DeptID = @DeptID )
                                        AND SubEvalID IN (
                                        SELECT  EvalID
                                        FROM    dbo.SubEval
                                        WHERE   EmplID = @DeptMgrId
                                                AND EvalActive = 1 ) );		
		
		
		/**
		inactivate the eval where the manager is the old manager and new manager is the eval
		**/													
                        UPDATE  dbo.SubEval
                        SET     EvalActive = 0 ,
                                LastUpdatedByID = @DeptUpdatedById ,
                                LastUpdatedDt = GETDATE()
                        WHERE   EmplID = @DeptMgrId
                                AND MgrID = @OldManagerID;
		
                    END;
	
	/**
	* If the manager is changed.
	**/
                UPDATE  dbo.Department
                SET     IsSchool = @DeptIsSchool ,
                        DeptID = @DeptID ,
                        MgrID = @DeptMgrId ,
                        ImplSpecialistID = @ImplSpecialistID ,
                        DeptRptEmplID = ( CASE WHEN @DeptIsSchool = 0
                                                    AND @DeptRptEmplID IS NOT NULL
                                               THEN @DeptRptEmplID
                                               ELSE DeptRptEmplID
                                          END ) ,
                        DeptCategoryID = ( CASE WHEN @DeptCategoryId != 0
                                                THEN @DeptCategoryId
                                                ELSE NULL
                                           END ) ,
                        LastUpdatedByID = @DeptUpdatedById ,
                        LastUpdatedDt = GETDATE()
                WHERE   DeptID = @DeptID;
	
	/** transfer all eval to the new manager and if one of the eval is the new manager, turn them into inactive
			which is handled in the previous step 
		**/
		
                IF ( ( SELECT   COUNT(DISTINCT DeptID)
                       FROM     dbo.EmplEmplJob
                       WHERE    EmplID = @OldManagerID
                                AND IsActive = 1
                     ) > 1 )
                    BEGIN
		---create a duplicate copy of all subeval for the new manager and update all the emplJob for changed dept with new subevalId
                        EXECUTE dbo.CopySubEvalNewMgr @DeptID, @OldManagerID,
                            @DeptMgrId, @DeptUpdatedById; 
                    END; 
			
                ELSE
                    BEGIN		
                        UPDATE  dbo.SubEval
                        SET     MgrID = @DeptMgrId ,
                                LastUpdatedByID = @DeptUpdatedById ,
                                LastUpdatedDt = GETDATE()
                        WHERE   EvalID IN (
                                SELECT  EvalID
                                FROM    dbo.SubEval
                                WHERE   EvalID IN (
                                        SELECT DISTINCT
                                                SubEvalID
                                        FROM    dbo.SubevalAssignedEmplEmplJob
                                        WHERE   EmplJobID IN (
                                                SELECT  ej.EmplJobID
                                                FROM    dbo.EmplEmplJob ej
                                                        LEFT OUTER JOIN dbo.EmplExceptions ex ON ex.EmplJobID = ej.EmplJobID
                                                WHERE   ej.DeptID = @DeptID
                                                        AND ( CASE
                                                              WHEN ex.MgrID IS NULL
                                                              THEN ej.MgrID
                                                              ELSE ex.MgrID
                                                              END ) = @OldManagerID ) ) )
                                AND MgrID = @OldManagerID
                                AND EvalActive = 1;	
                    END;	 
	
	/**
		Update the subeval in the plan to the new manager ID
		if the plan
	**/
	
                EXECUTE dbo.updEvalIDByDeptID @UpdDeptID = @DeptID,
                    @UpdDeptMgrId = @DeptMgrId,
                    @UpdDeptUpdatedById = @DeptUpdatedById,
                    @UpdOldManagerID = @OldManagerID,
                    @UpdDeptCategoryId = @DeptCategoryId;
	
	
	
	
	/** 
	update emplempljob record with new manager
	for the department.
	inactivate the new emplempljob record if an emplemplJob record 
	already exists for the new manager 
	with the same department, same jobcode and same active 
	**/	
                UPDATE  ej
                SET     --MgrID = @DeptMgrId,
                        ej.MgrID = ( CASE WHEN EmplID != @DeptMgrId
                                       THEN @DeptMgrId
                                       ELSE '000000'
                                  END ) ,
                        ej.LastUpdatedByID = @DeptUpdatedById ,
                        ej.LastUpdatedDt = GETDATE() ,
                        ej.IsActive = ( CASE WHEN EXISTS ( SELECT
                                                              ej1.EmplJobID
                                                        FROM  dbo.EmplEmplJob ej1
                                                              JOIN ( SELECT
                                                              JobCode ,
                                                              EmplID
                                                              FROM
                                                              dbo.EmplEmplJob
                                                              WHERE
                                                              MgrID = @DeptMgrId
                                                              ) AS filterJob ON filterJob.JobCode = ej1.JobCode
                                                              AND filterJob.EmplID = ej.EmplID
                                                        WHERE ej1.MgrID = @DeptMgrId
                                                              AND ej1.DeptID = @DeptID
                                                              AND ej1.IsActive = 1 )
                                          THEN 0
                                          ELSE 1
                                     END )
                FROM    dbo.EmplEmplJob ej
                WHERE   ( MgrID = @OldManagerID
                          OR MgrID = '000000'
                        )
                        AND IsActive = 1
                        AND DeptID = @DeptID;
            END;

        IF NOT EXISTS ( SELECT  ObsRubricID
                        FROM    dbo.ObservationRubricDefault
                        WHERE   EmplID = @DeptMgrId )
            BEGIN
                INSERT  INTO dbo.ObservationRubricDefault
                        ( EmplID ,
                          RubricID ,
                          IndicatorID ,
                          IsActive ,
                          IsDeleted ,
                          CreatedByID ,
                          CreatedByDt ,
                          LastUpdatedByID ,
                          LastUpdatedDt
                        )
                        SELECT  @DeptMgrId ,
                                rh.RubricID ,
                                ri.IndicatorID ,
                                1 ,
                                0 ,
                                '000000' ,
                                GETDATE() ,
                                '000000' ,
                                GETDATE()
                        FROM    dbo.RubricIndicator AS ri
                                JOIN dbo.RubricStandard AS rs ON ri.StandardID = rs.StandardID
                                                             AND ( rs.StandardText LIKE 'II.%'
                                                              OR rs.StandardText LIKE 'II:%'
                                                              )
                                                             AND rs.IsActive = 1
                                                             AND rs.IsDeleted = 0
                                JOIN dbo.RubricHdr AS rh ON rs.RubricID = rh.RubricID
                                                        AND rh.IsActive = 1
                                                        AND rh.IsDeleted = 0
                        WHERE   ri.ParentIndicatorID = 0
                        ORDER BY rh.RubricID ,
                                rs.StandardID ,
                                ri.IndicatorID;
            END;		

        IF ( SELECT COUNT(DeptID)
             FROM   dbo.Department
             WHERE  MgrID = @OldManagerID
           ) <= 1
            BEGIN
                DELETE  FROM dbo.ObservationRubricDefault
                WHERE   EmplID = @OldManagerID;
            END;

--delete if any override exists for the manager when the DeptReport is added.
        IF ( @DeptRptEmplID IS NOT NULL )
            BEGIN	
                IF ( EXISTS ( SELECT    ExceptionID
                              FROM      dbo.EmplExceptions
                              WHERE     EmplJobID IN (
                                        SELECT  EmplJobID
                                        FROM    dbo.EmplEmplJob
                                        WHERE   EmplID = @DeptMgrId
                                                AND DeptID = @DeptID
                                                AND IsActive = 1 ) ) )
                    BEGIN
                        DELETE  FROM dbo.EmplExceptions
                        WHERE   EmplJobID IN ( SELECT   EmplJobID
                                               FROM     dbo.EmplEmplJob
                                               WHERE    EmplID = @DeptMgrId
                                                        AND DeptID = @DeptID
                                                        AND IsActive = 1 );
                    END;
	
	--update the manager to report mgrID
                UPDATE  dbo.EmplEmplJob
                SET     MgrID = @DeptRptEmplID
                WHERE   EmplID = @DeptMgrId
                        AND DeptID = @DeptID
                        AND IsActive = 1; 
	
	--reset the primary subevalID
                UPDATE  dbo.EmplPlan
                SET     SubEvalID = dbo.funcGetPrimaryManagerByEmplID(@DeptMgrId)
                WHERE   EmplJobID IN ( SELECT   EmplJobID
                                       FROM     dbo.EmplEmplJob
                                       WHERE    EmplID = @DeptMgrId
                                                AND DeptID = @DeptID
                                                AND IsActive = 1 )
                        AND PlanActive = 1;
            END;
    END;
GO
