SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Newa,Matina
-- Create date: 03/27/2013
-- Description:	View all to list active plans on inactive jobs 
-- =============================================
CREATE VIEW [dbo].[AllActivePlansInactiveJob]
AS
    SELECT  --ejc.IsEmailSent,
            e.EmplID ,
            e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '')
            + ' (' + e.EmplID + ')' AS EmplName ,
            e.EmplID + '@boston.k12.ma.us' AS EmplEmailAddr ,
            m.EmplID AS MgrID ,
            m.NameLast + ', ' + m.NameFirst + ' ' + ISNULL(m.NameMiddle, '')
            + ' (' + m.EmplID + ')' AS MgrName ,
            m.EmplID + '@boston.k12.ma.us' AS MgrEmailAddr
--		,e.EmplID + '@boston.k12.ma.us; ' + m.EmplID + '@boston.k12.ma.us' as  CombinedEmailAddr
            ,
            '114600@boston.k12.ma.us; x02414@boston.k12.ma.us' AS CombinedEmailAddr ,
            d.DeptID AS CurrentActiveDeptID ,
            d.DeptName + ' (' + d.DeptID + ')' AS CurrentActiveDept ,
            j.JobName + ' (' + j.JobCode + ')' AS CurrentActiveJob ,
            j2.JobName + ' (' + j2.JobCode + ')' AS PreviousJob ,
            ejc.NewEmplEmplJoBCreatedDt ,
            ejc.NewJobEnttryDate
    FROM    dbo.EmplJobChange AS ejc ( NOLOCK )
            JOIN dbo.Empl AS e ( NOLOCK ) ON ejc.EmplID = e.EmplID
            LEFT JOIN dbo.Empl AS m ( NOLOCK ) ON ejc.MgrID = m.EmplID
            LEFT JOIN dbo.Department AS d ( NOLOCK ) ON m.EmplID = d.MgrID
            JOIN dbo.EmplJob AS j ( NOLOCK ) ON ejc.NewJobCode = j.JobCode
            JOIN dbo.EmplJob AS j2 ( NOLOCK ) ON ejc.PreviousJobCode = j2.JobCode;

GO
