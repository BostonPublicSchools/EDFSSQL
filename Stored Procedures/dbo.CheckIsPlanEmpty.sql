SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Newa,Matina
-- Create date: Nov 14, 2013
-- Description:	check if the PlanId is not associated in other table( INFORMATION_SCHEMA.KEY_COLUMN_USAGE) 
-- exec CheckIsPlanEmpty 200400
-- =============================================
CREATE PROCEDURE [dbo].[CheckIsPlanEmpty]
    @PlanID AS INT ,
    @ReturnValue AS BIT = NULL OUTPUT -- O FOR empty 
AS
    BEGIN

        DECLARE @sqlcmd NVARCHAR(MAX);
        SET @sqlcmd = STUFF((SELECT ' UNION SELECT DISTINCT ' + COLUMN_NAME
                                    + ' FROM ' + TABLE_NAME
                                    + ' WHERE PLANID = '
                                    + CONVERT(NVARCHAR, @PlanID)
                             FROM   INFORMATION_SCHEMA.KEY_COLUMN_USAGE
                             WHERE  COLUMN_NAME = 'planid'
                                    AND TABLE_NAME != 'EmplPlan'
                             ORDER BY TABLE_NAME
            FOR             XML PATH('') ,
                                TYPE
		).value('.', 'NVARCHAR(MAX)'), 1, 7, '');

        EXECUTE sys.sp_executesql @sqlcmd;

        IF ( @@ROWCOUNT = 0 )
            SET @ReturnValue = 1; --true  
        ELSE
            SET @ReturnValue = 0; --false  
 
        SELECT  @ReturnValue;
 
    END;
	


GO
