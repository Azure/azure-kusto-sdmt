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

/*  SQL destination

drop table core.MeasurementViaLakeSF

SELECT TOP (1000) * FROM [Core].[MeasurementViaLakeSF]

*/

    DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
            ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
            ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
            ,@SourceSystemName sysname      = 'SQLToLakeSingleFileToSQL'
            ,@ContainerName    sysname      = 'slicedimport/SQLtoSQLSF'

       
    EXEC [Helper].[GenerateSliceMetaData] 
             @LowWaterMark            = @LowWaterMark
            ,@HigWaterMark            = @HigWaterMark
            ,@Resolution              = @Resolution
            ,@SourceSystemName        = @SourceSystemName
            ,@SourceSchema            = 'Core'
            ,@SourceObject            = 'Measurement'
            ,@GetDataCommand          = 'SELECT [Ts], [SignalName], [MeasurementValue] FROM [Core].[Measurement]'
            ,@DateFilterAttributeName = '[Ts]'
            ,@DateFilterAttributeType = 'DATETIME2(3)'                    -- Datatype should match to source table
            ,@DestinationSchema       = 'Core'
            ,@DestinationObject       = 'MeasurementViaLakeSF'
            ,@ContainerName           = @ContainerName


SELECT *
FROM [Core].[SlicedImportObject]
WHERE SourceSystemName  = 'SQLToLakeSingleFileToSQL'


SELECT *
FROM [Mart].[SlicedImportObject]
WHERE SourceSystemName  = 'SQLToLakeSingleFileToSQL'