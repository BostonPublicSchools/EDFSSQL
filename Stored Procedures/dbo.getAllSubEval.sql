SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 08/21/2012
-- Description:	get all sub eval
-- =============================================
CREATE PROCEDURE [dbo].[getAllSubEval]
AS
BEGIN 
SET NOCOUNT ON;
	SELECT s.EvalID, s.MgrID,s.EmplID, s.EvalActive, emp.NameFirst, emp.NameLast, emp.NameMiddle FROM subeval s
	JOIN Empl emp ON emp.EmplID = s.EmplID
END
GO
