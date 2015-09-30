SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_EmplIDWithPriMgrID]
AS
SELECT     primaryManagerID, EmplID
FROM         (SELECT     (CASE WHEN s.EmplID IS NOT NULL THEN s.EmplID ELSE PrimaryEMplJobTable.managerID END) AS primaryManagerID, ej.EmplID
                       FROM          dbo.EmplEmplJob AS ej LEFT OUTER JOIN
                                              dbo.SubevalAssignedEmplEmplJob AS sej ON sej.EmplJobID = ej.EmplJobID AND sej.IsPrimary = 1 AND sej.IsActive = 1 AND 
                                              sej.IsDeleted = 0 LEFT OUTER JOIN
                                                  (SELECT     (CASE WHEN ex.EmplID IS NOT NULL THEN ex.EmplID ELSE ej1.MgrID END) AS managerID, ej1.EmplJobID
                                                    FROM          dbo.EmplEmplJob AS ej1 LEFT OUTER JOIN
                                                                           dbo.EmplExceptions AS ex ON ex.EmplJobID = ej1.EmplJobID
                                                    WHERE      (ej1.EmplJobID =
                                                                               (SELECT     TOP (1) EmplJobID
                                                                                 FROM          dbo.EmplEmplJob
                                                                                 WHERE      (EmplID = ej1.EmplID) AND (IsActive = 1)
                                                                                 ORDER BY FTE DESC, EmplRcdNo))) AS PrimaryEMplJobTable ON PrimaryEMplJobTable.EmplJobID = ej.EmplJobID LEFT OUTER JOIN
                                              dbo.SubEval AS s ON s.EvalID = sej.SubEvalID AND s.EvalActive = 1
                       WHERE      (ej.IsActive = 1)) AS tblEmplIDWithPriMgrID
WHERE     (primaryManagerID IS NOT NULL)
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[23] 4[10] 2[48] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblEmplIDWithPriMgrID"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 95
               Right = 216
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vw_EmplIDWithPriMgrID', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vw_EmplIDWithPriMgrID', NULL, NULL
GO
