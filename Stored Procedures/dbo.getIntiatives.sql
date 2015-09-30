SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Avery, Bryce
-- Create date: 02/07/2012
-- Description:	List of intiatives associated with a manager
-- =============================================
CREATE PROCEDURE [dbo].[getIntiatives]
	@EmplID AS varchar(6)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @IntiativeTagIDList AS nvarchar(max)
	
	SELECT
		i.InitiativeID
		,i.MgrID
		,me.NameLast + ', ' + me.NameFirst + ' ' + ISNULL(me.NameMiddle, '') AS MgrName
		,i.IntiativeTypeID
		,it.CodeText AS IntiativeType
		,SUBSTRING((SELECT
						',' + CAST(it.GoalTagID AS nvarchar)
					FROM
						InitiativeTag AS it
					Where 
						it.IntiativeID = i.InitiativeID
					For XML PATH ('')), 2, 9999)  AS InitiativeTagIDs
		,SUBSTRING((SELECT
						 ', ' + CAST(c.CodeText AS varchar)
					FROM
						InitiativeTag AS it
					JOIN CodeLookUp AS c ON it.GoalTagID = c.CodeID
					Where 
						it.IntiativeID = i.InitiativeID
					For XML PATH ('')), 2, 9999)  AS InitiativeTagTexts
        	,i.IntiativeText
        	,i.IntiativeStatusID
        	,ic.CodeText AS InitiativeStatus
        	,i.IsDeleted
        	,CASE
        		 WHEN ic.CodeText = 'Released' THEN 'Yes'
        		 ELSE 'No'
        	 END AS IsReleased
        ,ISNULL(i.SchYear,'') SchYear
	FROM
		Initiative AS i (NOLOCK)
	JOIN Empl as me (NOLOCK) ON i.MgrID = me.EmplID
	JOIN CodeLookUp as it (NOLOCK) ON i.IntiativeTypeID = it.CodeID
	JOIN CodeLookUp as ic (NOLOCK) ON i.IntiativeStatusID = ic.CodeID	
	WHERE
		i.IsDeleted = 0
	AND	i.MgrID = @EmplID
				
END
GO
