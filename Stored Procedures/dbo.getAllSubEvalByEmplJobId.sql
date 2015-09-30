SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan, Devi
-- Create date: 02/08/2013
-- Description:	get all subeval by empljobID
-- =============================================
Create PROCEDURE [dbo].[getAllSubEvalByEmplJobId]
 @EmplJobID int
 
AS
BEGIN
	SET NOCOUNT ON;
	
--#1.get the emplId.		
		DECLARE @EmplID as nchar(6)
		SET @EmplID = (SELECT EmplID from EmplEmplJob where EmplJobID = @EmplJobID);
		
--#2.Get the primary for the emplId.
		DECLARE @PrimaryEmplJobID AS int
		SET @PrimaryEmplJobID = (SELECT se.EmplJobID
								from SubevalAssignedEmplEmplJob se 
								JOIN SubEval s on s.EvalID = se.SubEvalID
								where se.EmplJobID in (SELECT EmplJobID from EmplEmplJob where EmplID = @EmplID and IsActive=1) AND se.IsDeleted = 0 AND se.IsActive=1	
									  and se.IsPrimary =1 and s.MgrID in (SELECT (CASE WHEN (ex.MgrID IS NULL OR ex.MgrID = '000000') THEN ej.MgrID ELSE ex.MgrID END) 
																			FROM EmplEmplJob ej 
																			LEFT OUTER JOIN EmplExceptions ex on ex.EmplJobID = ej.EmplJobID 
																			WHERE ej.EmplID = @EmplID  and  ej.IsActive = 1));			

	SELECT ej.EmplJobID,
		   ase.IsActive,
		   ase.IsDeleted,
		   ase.IsPrimary,
		   s.EmplID,
		   s.MgrID,
		   e.NameFirst +' ' + e.NameLast [EmplName],
		   @PrimaryEmplJobID as PrimaryEmplJobID	
	FROM EmplEmplJob ej 
	LEFT OUTER JOIN SubevalAssignedEmplEmplJob ase on ase.EmplJobID = ej.EmplJobID 
	LEFT OUTER JOIN SubEval s on ase.SubEvalID = s.EvalID
	LEFT JOIN Empl e on e.EmplID = s.EmplID
	WHERE ej.EmplJobID = @EmplJobID 
	AND ase.IsDeleted = 0 AND ase.IsActive=1
END




GO
