SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ganesan,Devi
-- Create date: 06/24/2013
-- Description: 
-- =============================================
CREATE Function [dbo].[funGetStandardCode](@CodeEvalType  as varchar(200),@CodeRubric  as varchar(200),@CodeRating as varchar(200))
Returns nvarchar(10)
AS
BEGIN

DECLARE @RubricType nvarchar(10)
SELECT @RubricType= CASE 
					WHEN @CodeRubric='ADMIN' OR @CodeRubric='SUPER' 
						THEN 'ADMIN'
					ELSE 
						'NONADMIN'
					END
DECLARE @CodeEval nvarchar(10)					
SELECT @CodeEval= CASE 
					WHEN @CodeEvalType='Formative Evaluation'
						THEN
							'Formative'
					WHEN @CodeEvalType='Summative Evaluation' 
						THEN 'Summative'

					END
										
DECLARE @FINAL nvarchar(10)
SELECT @FINAL = CASE 
			 WHEN @CodeRating IS NULL OR @CodeRating = ''
				THEN '00'
			 WHEN @CodeRating = 'Unsatisfactory' And @CodeEval = 'Formative' And @RubricType='NONADMIN'
				THEN '05'
			 WHEN @CodeRating = 'Unsatisfactory' And @CodeEval = 'Summative' And @RubricType='NONADMIN'
				THEN '06'
			 WHEN @CodeRating = 'Unsatisfactory' And @CodeEval='Formative' And @RubricType='ADMIN'
				THEN '07'
			 WHEN @CodeRating = 'Unsatisfactory' And @CodeEval='Summative' And @RubricType='ADMIN'
				THEN '08'
				
			 WHEN @CodeRating = 'Needs Improvement' And @CodeEval='Formative' And @RubricType='NONADMIN'
				THEN '09'
			 WHEN @CodeRating = 'Needs Improvement' And @CodeEval='Summative' And @RubricType='NONADMIN'
				THEN '10'
			 WHEN @CodeRating = 'Needs Improvement' And @CodeEval='Formative' And @RubricType='ADMIN'
				THEN '11'
			 WHEN @CodeRating = 'Needs Improvement' And @CodeEval='Summative' And @RubricType='ADMIN'
				THEN '12'
																
			 WHEN @CodeRating = 'Proficient' And @CodeEval='Formative' And @RubricType='NONADMIN'
				THEN '13'
			 WHEN @CodeRating = 'Proficient' And @CodeEval='Summative' And @RubricType='NONADMIN'
				THEN '14'
			 WHEN @CodeRating = 'Proficient' And @CodeEval='Formative' And @RubricType='ADMIN'
				THEN '15'				
			 WHEN @CodeRating = 'Proficient' And @CodeEval='Summative' And @RubricType='ADMIN'
				THEN '16'
				
			 WHEN @CodeRating = 'Exemplary' And @CodeEval='Formative' And @RubricType='NONADMIN'
				THEN '17'
			 WHEN @CodeRating = 'Exemplary' And @CodeEval='Summative' And @RubricType='NONADMIN'
				THEN '18'
			 WHEN @CodeRating = 'Exemplary' And @CodeEval='Formative' And @RubricType='ADMIN'
				THEN '19'
			 WHEN @CodeRating = 'Exemplary' And @CodeEval='Summative' And @RubricType='ADMIN'
				THEN '20'												
				
			 WHEN @CodeRating NOT IN ('Unsatisfactory','Needs Improvement','Proficient','Exemplary')
				THEN '99'			 													 
			 ELSE
				'00'
			END	
RETURN @FINAL
END

GO
