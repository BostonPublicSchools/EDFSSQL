SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Newa, Matina
-- Create date: 03/24/2014
-- Description:	list of Managers and Evaluators and allow id for search
-- =============================================
CREATE PROCEDURE [dbo].[getEmplNames_MgrAndEvalsOnly]
    @searchText AS NVARCHAR(100)
AS
    BEGIN
        SET NOCOUNT ON;

        SELECT  tblMgrAndEvals.NameFirst ,
                tblMgrAndEvals.NameLast ,
                tblMgrAndEvals.NameMiddle ,
                tblMgrAndEvals.EmplID ,
                tblMgrAndEvals.EmplActive
        FROM    (	
	--Get Managers 
                  SELECT    em.NameFirst ,
                            em.NameLast ,
                            em.NameMiddle ,
                            em.EmplID ,
                            em.EmplActive
			--,d.DeptID
                  FROM      dbo.Empl AS em
                            JOIN dbo.Department d ON em.EmplID = d.MgrID
                  WHERE     em.EmplActive = 1
                  UNION 	
	-- Get Evaluators
                  SELECT    em.NameFirst ,
                            em.NameLast ,
                            em.NameMiddle ,
                            em.EmplID ,
                            em.EmplActive
                  FROM      dbo.Empl AS em
                            JOIN ( SELECT DISTINCT
                                            s.EmplID
                                   FROM     dbo.SubevalAssignedEmplEmplJob AS subass
                                            JOIN dbo.SubEval s ( NOLOCK ) ON subass.SubEvalID = s.EvalID
                                   WHERE    subass.IsActive = 1
                                            AND subass.IsDeleted = 0
                                 ) tbEvaluator ON em.EmplID = tbEvaluator.EmplID
                  WHERE     em.EmplActive = 1
                ) AS tblMgrAndEvals
        WHERE   ISNULL(tblMgrAndEvals.NameFirst, '')
                + ISNULL(tblMgrAndEvals.NameMiddle, '')
                + ISNULL(tblMgrAndEvals.NameLast, '') LIKE '%' + @searchText
                + '%';

    END;
	
GO
