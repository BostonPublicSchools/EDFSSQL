SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Khanpara, Krunal	
-- Create date: 03/23/2012
-- Description:	it returns list of managers with the department names
-- =============================================
Create PROCEDURE [dbo].[searchManager]
	@inputString AS nvarchar(52) = NULL
AS
BEGIN
--declare @test as varchar(50) = '%013799%'
SET @inputString = '%' + @inputString + '%'
(select	d.deptID
		,d.deptName
		,d.mgrID
		,e.EmplID
		,e.NameFirst
		,e.NameLast
		,e.NameMiddle
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') AS ManagerName

from department d
left join Empl e on d.mgrID = e.EmplID

where e.EmplActive =1
	and e.NameLast + ' ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' ' + d.mgrID like @inputString

UNION

select	d.deptID
		,d.deptName
		,ex.mgrID
		,e.EmplID
		,e.NameFirst
		,e.NameLast
		,e.NameMiddle
		,e.NameLast + ', ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') AS ManagerName

from EmplExceptions ex
left join Empl e on ex.mgrID = e.EmplID
JOIN EmplEmplJob ej on ex.EmplJobID = ej.EmplJobID
JOIN Department d on d.DeptID = ej.DeptID
where e.EmplActive =1
	and e.NameLast + ' ' + e.NameFirst + ' ' + ISNULL(e.NameMiddle, '') + ' ' + ex.mgrID like @inputString)
Order By ManagerName	
	
	
END
GO
