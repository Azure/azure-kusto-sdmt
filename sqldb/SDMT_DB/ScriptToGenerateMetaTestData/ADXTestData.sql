DELETE FROM [Core].[SlicedImportObject] WHERE [SourceSystemName] = 'AdventureWorksLT_ADX';



INSERT INTO [Core].[SlicedImportObject]
           ([SlicedImportObject_Id]
		   ,[SourceSystemName]
           ,[SourceSchema]
           ,[SourceObject]
           ,[GetDataCommand]
           ,[FilterDataCommand]
           ,[DestinationSchema]
           ,[DestinationObject]
           ,[ContainerName]
           ,[DestinationPath]
           ,[DestinationFileName]
		   ,[AdditionalContext]
           )
     VALUES
           ('37C8B38B-B913-4593-B1F2-68EDCB5DC600'
		   ,'AdventureWorksLT_ADX'
           ,'SalesLT'
           ,'SalesOrderHeader'
           ,'SELECT [SalesOrderID], [RevisionNumber], [OrderDate], [Status] FROM [SalesLT].[SalesOrderHeader]'
           ,'WHERE [SalesOrderID] < 71816'
           ,'na'
           ,'SalesOrderHeader'
           ,'na'
           ,'na'
           ,'na'
		   ,'{"creationTime": "2022.01.01"}'
           );


INSERT INTO [Core].[SlicedImportObject]
           ([SlicedImportObject_Id]
		   ,[SourceSystemName]
           ,[SourceSchema]
           ,[SourceObject]
           ,[GetDataCommand]
           ,[FilterDataCommand]
           ,[DestinationSchema]
           ,[DestinationObject]
           ,[ContainerName]
           ,[DestinationPath]
           ,[DestinationFileName]
		   ,[AdditionalContext]
           )
     VALUES
           ('2A1ACA0A-F6F4-4E66-8210-BDA581CD28B7'
		   ,'AdventureWorksLT_ADX'
           ,'SalesLT'
           ,'SalesOrderHeader'
           ,'SELECT [SalesOrderID], [RevisionNumber], [OrderDate], [Status] FROM [SalesLT].[SalesOrderHeader]'
           ,'WHERE [SalesOrderID] >= 71816'
           ,'na'
           ,'SalesOrderHeader'
           ,'na'
           ,'na'
           ,'na'
		   ,'{"creationTime": "2023.01.01"}'
           )
GO


EXEC [Core].[GetSetSlicedImportObjectToLoad] 'AdventureWorksLT_ADX'
EXEC [Core].[SetSlicedImportObjectStart] '37C8B38B-B913-4593-B1F2-68EDCB5DC600'
EXEC [Core].[GetSetSlicedImportObjectToLoad] 'AdventureWorksLT_ADX'
EXEC [Core].[SetSlicedImportObjectEnd] '37C8B38B-B913-4593-B1F2-68EDCB5DC600', 33

SELECT * FROM [Core].[SlicedImportObject]


EXEC [Core].[SetSlicedImportObjectStart] '2A1ACA0A-F6F4-4E66-8210-BDA581CD28B7'

EXEC [Core].[ResetSlicedImportObject] '', '2A1ACA0A-F6F4-4E66-8210-BDA581CD28B7'

EXEC [Core].[ResetSlicedImportObject] 'AdventureWorksLT_ADX', '2A1ACA0A-F6F4-4E66-8210-BDA581CD28B7'

EXEC [Core].[ResetSlicedImportObject] 'AdventureWorksLT_ADX'


IF OBJECT_ID('[AdventureWorksLT_SalesLT_Sliced].[SalesOrderHeader]') IS NOT NULL DELETE FROM [AdventureWorksLT_SalesLT_Sliced].[SalesOrderHeader] WHERE [SalesOrderID] >= 71815

IF OBJECT_ID('[AdventureWorksLT_SalesLT_Sliced].[SalesOrderHeader]') IS NOT NULL DELETE FROM [AdventureWorksLT_SalesLT_Sliced].[SalesOrderHeader] WHERE [SalesOrderID] >= 71815
IF OBJECT_ID('[AdventureWorksLT_SalesLT_Sliced].[SalesOrderHeader]') IS NOT NULL DELETE FROM [AdventureWorksLT_SalesLT_Sliced].[SalesOrderHeader] WHERE [SalesOrderID] >= 71815

SELECT OBJECT_ID('[AdventureWorksLT_SalesLT_Sliced].[SalesOrderHeader]')
