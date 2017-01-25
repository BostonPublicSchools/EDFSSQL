SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[z_tmpGoalDate]
AS
    SELECT  tblAllGoal.LogID ,
            tblAllGoal.TableName ,
            tblAllGoal.LoggedEvent ,
            tblAllGoal.EventDt ,
            tblAllGoal.IdentityID ,
            tblAllGoal.PreviousText ,
            tblAllGoal.NewText ,
            tblAllGoal.src ,
            tblAllGoal.GoalID ,
            tblAllGoal.PlanID ,
            tblAllGoal.seq
    FROM    ( SELECT    l.LogID ,
                        l.TableName ,
                        l.LoggedEvent ,
                        l.EventDt ,
                        l.IdentityID ,
                        l.PreviousText ,
                        l.NewText ,
                        'a' src ,
                        g.GoalID ,
                        p.PlanID ,
                        RANK() OVER ( PARTITION BY l.LoggedEvent ORDER BY l.EventDt ) seq
              FROM      dbo.ChangelogArchive l
                        INNER JOIN dbo.PlanGoal g ON l.IdentityID = g.GoalID
                        INNER JOIN dbo.EmplPlan p ON p.PlanID = g.PlanID
              WHERE     l.LoggedEvent LIKE 'goal status%Goal%'
--and NewText='12'
                        AND l.TableName = 'PlanGoal'
--order by IdentityID
              UNION
              SELECT    l.LogID ,
                        l.TableName ,
                        l.LoggedEvent ,
                        l.EventDt ,
                        l.IdentityID ,
                        l.PreviousText ,
                        l.NewText ,
                        'b' src ,
                        g.GoalID ,
                        p.PlanID ,
                        RANK() OVER ( PARTITION BY l.LoggedEvent ORDER BY l.EventDt ) seq
              FROM      dbo.Changelog l
                        INNER JOIN dbo.PlanGoal g ON l.IdentityID = g.GoalID
                        INNER JOIN dbo.EmplPlan p ON p.PlanID = g.PlanID
              WHERE     l.LoggedEvent LIKE 'goal status%Goal%'
--and NewText='12'
                        AND l.TableName = 'PlanGoal'
--order by IdentityID
            ) tblAllGoal
    WHERE   tblAllGoal.NewText = '12'
            AND tblAllGoal.seq = 1;
--order by IdentityID
--From PlanGoalTable


GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[14] 4[3] 2[64] 3) )"
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
', 'SCHEMA', N'dbo', 'VIEW', N'z_tmpGoalDate', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'z_tmpGoalDate', NULL, NULL
GO
