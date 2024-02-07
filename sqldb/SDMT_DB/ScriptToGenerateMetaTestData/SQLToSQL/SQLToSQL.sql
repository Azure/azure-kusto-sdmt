/* SQL Source

CREATE SCHEMA [Core];

CREATE TABLE [Core].[Measurement]
(
   [Ts]                 DATETIME2(3) NOT NULL
  ,[SignalName]         NVARCHAR(50) NOT NULL
  ,[MeasurementValue]   REAL         NOT NULL
);
GO


INSERT INTO [Core].[Measurement] values ('2021-11-25 12:00:03', 'Temperature',	 23.5);
INSERT INTO [Core].[Measurement] values ('2021-11-25 12:00:04', 'Humidity',	     45.4);
INSERT INTO [Core].[Measurement] values ('2021-11-25 12:00:04', 'Temperature',	 22.5);
INSERT INTO [Core].[Measurement] values ('2021-11-26 12:00:07', 'Temperature',	 23.5);
INSERT INTO [Core].[Measurement] values ('2021-11-26 12:00:07', 'Humidity',	     44.8);
INSERT INTO [Core].[Measurement] values ('2021-11-26 12:00:09', 'Temperature',	 25.0);
INSERT INTO [Core].[Measurement] values ('2021-11-27 12:00:07', 'Humidity',	     44.8);
INSERT INTO [Core].[Measurement] values ('2021-11-27 12:00:09', 'Temperature',	 25.0);


SELECT * FROM [Core].[Measurement]
*/

/* SQL destination

drop table core.measurement

select TOP (1000) * FROM [Core].[Measurement]

*/

-- Minimal meta data, if all attributes from the source table can be transferred

DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
        ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
        ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
        ,@SourceSystemName sysname      = 'SQLToSQL'
   
EXEC [Helper].[GenerateSliceMetaData] 
         @LowWaterMark            = @LowWaterMark
        ,@HigWaterMark            = @HigWaterMark
        ,@Resolution              = @Resolution
        ,@SourceSystemName        = @SourceSystemName
        ,@SourceSchema            = 'Core'
        ,@SourceObject            = 'Measurement'
        ,@DateFilterAttributeName = '[Ts]'
        ,@DateFilterAttributeType = 'DATETIME2(3)' -- Datatype should match to source table
        ,@DestinationSchema       = 'Core'
        ,@DestinationObject       = 'Measurement'

GO


-- check meta data

SELECT *
FROM   [Mart].[SlicedImportObject]
WHERE  SourceSystemName  = 'SQLToSQL'

-----------------------------------------------------

-- If you specify the @GetDataCommand then it will be use to define the query used to get data

DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
        ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
        ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
        ,@SourceSystemName sysname      = 'SQLToSQL'
   
EXEC [Helper].[GenerateSliceMetaData] 
         @LowWaterMark            = @LowWaterMark
        ,@HigWaterMark            = @HigWaterMark
        ,@Resolution              = @Resolution
        ,@SourceSystemName        = @SourceSystemName
        ,@SourceSchema            = 'Core'
        ,@SourceObject            = 'Measurement'
        ,@GetDataCommand          = 'SELECT [Ts], [SignalName], [MeasurementValue] FROM [Core].[Measurement]'
        ,@DateFilterAttributeName = '[Ts]'
        ,@DateFilterAttributeType = 'DATETIME2(3)' -- Datatype should match to source table
        ,@DestinationSchema       = 'Core'
        ,@DestinationObject       = 'Measurement'

GO

-- check meta data

SELECT *
FROM   [Mart].[SlicedImportObject]
WHERE  SourceSystemName  = 'SQLToSQL'



-----------------------------------------------------


-- Show and explain Pipeline Start
DECLARE @RC int
DECLARE @SourceSystemName sysname           = 'SQLToSQL'
DECLARE @SourceSchema sysname               = '%'
DECLARE @SourceObject sysname               = '%'
DECLARE @SlicedImportObject_Id varchar(64)  = '%'
DECLARE @Mode varchar(25)                   = 'ALL'      -- 'ALL', 'REGULAR', 'RESTART'
DECLARE @OrderByFactor int                  = 1

-- TODO: Set parameter values here.

EXECUTE @RC = [Core].[GetSetSlicedImportObjectToLoad] 
   @SourceSystemName             
  ,@SourceSchema
  ,@SourceObject
  ,@SlicedImportObject_Id
  ,@Mode
  ,@OrderByFactor
GO
