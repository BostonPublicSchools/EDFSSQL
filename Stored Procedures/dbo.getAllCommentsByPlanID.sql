SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 11/07/2012
-- Description:	Get comments associated with a plan
-- =============================================
CREATE PROCEDURE [dbo].[getAllCommentsByPlanID]
	@PlanID	AS int = NULL
AS
BEGIN
	SET NOCOUNT ON;
		
	SELECT
		c.CommentID
		,c.PlanID
		,c.CommentDt
		,c.CommentTypeID
		,ct.CodeText AS CommentType
		,c.EmplID
		,e.NameLast + ', ' + e.NameFirst AS EmplName
		,c.CommentText
		,c.IsDeleted
		,c.CreatedByID AS CommentedEmplID
		,ec.NameLast + ', ' + ec.NameFirst AS CommentedEmplName
	FROM
		Comment AS c (NOLOCK)
	JOIN Empl AS e (NOLOCK) ON c.EmplID = e.EmplID
	JOIN CodeLookUp AS ct (NOLOCK) ON c.CommentTypeID = ct.CodeID
	JOIN Empl AS ec (NOLOCK) ON c.CreatedByID= ec.EmplID
	WHERE
		c.PlanID = @PlanID	
	ORDER BY 
		ct.CodeText ASC,c.CommentDt DESC
		
END
GO
