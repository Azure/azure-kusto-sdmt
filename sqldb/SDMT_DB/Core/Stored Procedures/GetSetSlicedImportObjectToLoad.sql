﻿CREATE PROCEDURE [Core].[GetSetSlicedImportObjectToLoad]
(   
    @SourceSystemName sysname
   ,@SourceSchema     sysname          = '%'
   ,@SourceObject     sysname          = '%'
   ,@SlicedImportObject_Id varchar(64) = '%'
   ,@Mode             VARCHAR(25)      = 'REGULAR'
   ,@OrderByFactor    INT              = 1
)
AS
BEGIN
  SELECT
	 [SlicedImportObject_Id]
    ,[SourceSystemName] 
	,[SourceSchema] 
	,[SourceObject] 
    ,[LowWaterMark]
    ,[HighWaterMark]
  FROM  [Core].[SlicedImportObject]
  WHERE [SourceSystemName] = @SourceSystemName
    AND ((@Mode = 'REGULAR'  AND [LastStart] IS NULL)
     OR  (@Mode = 'RESTART'  AND [LastStart] IS NOT NULL AND [LastSuccessEnd] IS NULL)
     OR  (@Mode = 'ALL'))
    AND COALESCE([SourceSchema],'') LIKE @SourceSchema
    AND COALESCE([SourceObject],'') LIKE @SourceObject 
    AND CONVERT(VARCHAR(64), [SlicedImportObject_Id]) LIKE @SlicedImportObject_Id 
    AND [Active] = 1
   ORDER BY TRY_CONVERT(INT, [LowWaterMark]) * @OrderByFactor  DESC
END