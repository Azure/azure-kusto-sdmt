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


DROP TABLE IF EXISTS [Core].[MeasurementPartitioned]
DROP PARTITION SCHEME demoPartitionPS 
DROP PARTITION FUNCTION demoPartitionPF
GO

CREATE PARTITION FUNCTION demoPartitionPF (DATETIME2(3))  
    AS RANGE RIGHT FOR VALUES ('2021-11-24', '2021-11-25', '2021-11-26', '2021-11-27','2021-11-28') ;  
GO  

CREATE PARTITION SCHEME demoPartitionPS  
    AS PARTITION demoPartitionPF  
    ALL TO ('PRIMARY') ;  
GO  

CREATE TABLE [Core].[MeasurementPartitioned]
(
   [Ts]                 DATETIME2(3) NOT NULL 
  ,[SignalName]         NVARCHAR(50) NOT NULL
  ,[MeasurementValue]   REAL         NOT NULL
)on demoPartitionPS ([Ts]) ;


CREATE INDEX MeasurementPartitioned_SignalNameTs ON [Core].[MeasurementPartitioned] ([SignalName], [Ts]);



*/

-- Minimal meta data, if all attributes from the source table can be transferred

DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
        ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
        ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
        ,@SourceSystemName sysname      = 'SQLToSQLPartitionedTable'
   
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
        ,@DestinationObject       = 'MeasurementPartitioned'



-- Clear all existing entries for this SourceSystem
DELETE FROM [Core].[PartitionInfo] WHERE [SourceSystemName] = @SourceSystemName
										 
INSERT INTO [Core].[PartitionInfo]		 
           ([SourceSystemName]
           ,[SourceSchema]
           ,[SourceObject]
           ,[TableIndex]
           ,[TableConstraints]
           ,[PartitionFunctionName])
SELECT @SourceSystemName
      ,'Core'
      ,'Measurement'
	  ,'CREATE INDEX @@SchemName@@_@@TableName@@_SignalNameTs ON [@@SchemName@@].[@@TableName@@] ([SignalName], [Ts]);'
	  ,'-- no special TableConstraints'
	  ,'demoPartitionPF'

GO

select * from [Core].[PartitionInfo]	


-- check meta data

SELECT *
FROM   [Mart].[SlicedImportObject]
WHERE  SourceSystemName  = 'SQLToSQLPartitionedTable'

-----------------------------------------------------
