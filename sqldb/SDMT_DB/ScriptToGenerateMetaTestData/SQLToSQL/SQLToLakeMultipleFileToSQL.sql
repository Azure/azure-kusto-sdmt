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

drop table core.MeasurementViaLakeMF

SELECT TOP (1000) * FROM [Core].[MeasurementViaLakeMF]


*/
    DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
            ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
            ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
            ,@SourceSystemName sysname      = 'SQLToLakeMultipleFileToSQL'
            ,@ContainerName    sysname      = 'slicedimport/SQLtoSQLMF'
            ,@MaxRowsPerFile   int          = 1 --1000000 -- example 1M rows per file, should be adjusted to the size of the data (depends on the number of columns and the size of the columns)

       
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
            ,@DestinationObject       = 'MeasurementViaLakeMF'
            ,@ContainerName           = @ContainerName
            ,@MaxRowsPerFile          = @MaxRowsPerFile


SELECT *
FROM [Core].[SlicedImportObject]
WHERE SourceSystemName  = 'SQLToLakeMultipleFileToSQL'


SELECT *
FROM [Mart].[SlicedImportObject]
WHERE SourceSystemName  = 'SQLToLakeMultipleFileToSQL'