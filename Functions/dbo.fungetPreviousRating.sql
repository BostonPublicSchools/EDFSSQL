SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fungetPreviousRating] (@EvalStdRatingID AS int	)
Returns nvarchar(20)
BEGIN

	DECLARE @retValue nvarchar(20)		
	
set @retValue= (Select Codetext from CodeLookUp where
				CodeID = (select top 1 PreviousText  from Changelog
							where TableName='EvaluationStandardRating' and 
							LoggedEvent ='EvalStd rating change for EvalStdRatingID '+ cast(IdentityID as NCHAR(6)) and IdentityID= @EvalStdRatingID
							group by LoggedEvent ,PreviousText, IdentityID,logid
							order by LogID ))		
 
 return @retValue
 END
GO
