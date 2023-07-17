


CREATE VIEW [Mart].[SuspectSlicedImportObject]
AS

WITH [MaxDurationPlus30Pct]
AS
(
  SELECT [SourceSystemName]
        ,[SourceSchema]
		,[SourceObject]
		,MAX([DurationInSecond]) * 0.3 AS [DurationLimit] 
  FROM   [Mart].[SlicedImportObject]
  WHERE [DurationInSecond] IS NOT NULL
  GROUP BY [SourceSystemName], [SourceSchema], [SourceObject]
  HAVING MAX([DurationInSecond]) IS NOT NULL
)
SELECT 
       [SlicedImportObject].[SlicedImportObject_Id]
      ,[SlicedImportObject].[SourceSystemName]
      ,[SlicedImportObject].[SourceSchema]
      ,[SlicedImportObject].[SourceObject]
      ,[SlicedImportObject].[GetDataCommand]
      ,[SlicedImportObject].[FilterDataCommand]
      ,[SlicedImportObject].[LastStart]
      ,[SlicedImportObject].[LastSuccessEnd]
      ,[SlicedImportObject].[LastErrorEnd]
      ,[SlicedImportObject].[DurationInSecond]
	  ,'Suspect'        AS  [LoadStatus] 
FROM [Mart].[SlicedImportObject]         
  LEFT OUTER JOIN  [MaxDurationPlus30Pct]
    ON [SlicedImportObject].[SourceSystemName] = [MaxDurationPlus30Pct].[SourceSystemName]
   AND [SlicedImportObject].[SourceSchema]     = [MaxDurationPlus30Pct].[SourceSchema]
   AND [SlicedImportObject].[SourceObject]     = [MaxDurationPlus30Pct].[SourceObject]
WHERE [SlicedImportObject].[LoadStatus]       = 'Loading'
   AND [SlicedImportObject].[DurationInSecond] > [MaxDurationPlus30Pct].[DurationLimit]