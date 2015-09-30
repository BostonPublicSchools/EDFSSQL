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
	 @PlanID as int 
	,@ReturnValue as bit=null OUTPUT -- O FOR empty 
AS
BEGIN

DECLARE @sqlcmd NVARCHAR(MAX);
SET @sqlcmd = STUFF((
		SELECT ' UNION SELECT DISTINCT ' + column_name + ' FROM '+ TABLE_NAME  
			+ ' WHERE PLANID = '+CONVERT(nvarchar,@planid)
		FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
		WHERE column_name='planid' and TABLE_NAME !='EmplPlan'
		ORDER BY TABLE_NAME
		FOR XML PATH(''),TYPE
		).value('.','NVARCHAR(MAX)'),1,7,'');

--print @sqlcmd
EXECUTE sp_executesql @sqlcmd

 if (@@ROWCOUNT=0)
	set @ReturnValue=1 --true  
 else
 	set @ReturnValue=0 --false  
 
 select @ReturnValue
 
END
	


GO
