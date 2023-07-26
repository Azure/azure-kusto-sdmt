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

/* ADX destination


.alter database Demo policy managed_identity ```
[
  {
    "ObjectId": "aa5530a9-146f-4461-a9e0-2c847a2581e6",
    "AllowedUsages": "NativeIngestion, ExternalTable"
  }
]```


.create-or-alter  external table Source_ExternalMeasurementSQLToLakeToADX (Ts: datetime, SignalName: string, MeasurementValue: decimal)
  kind=storage 
  partition by (FileDate:datetime )
  pathformat = (datetime_pattern("yyyy/MM/dd", FileDate))
    dataformat = parquet
    (
        h@'abfss://slicedimport@<storageAccount>.dfs.core.windows.net/SQLToLakeToADX/Core/Measurement;impersonate'
    )
    with (FileExtension=parquet, folder='Source')



.create-or-alter function  with (folder='Source', docstring='Get Measurement data from external table Source_ExternalDemoMeasurement and allows filtering on a specific day') Source_GetMeasurementFromMeasurementSQLToLakeToADX(Ts_Day: string)
{ 
  external_table('Source_ExternalMeasurementSQLToLakeToADX')
  | where FileDate == Ts_Day
  | project-away FileDate
}


.create table Measurement (Ts: datetime, SignalName: string, MeasurementValue: decimal) 


-> the following ADX Code will be generated
.set-or-append Measurement ({\"creationTime\": \"2021-11-27\"}, tags=...)  <| Source_GetMeasurementFromMeasurementSQLToLakeToADX(20211127)


*/

-- Metadata to fetch data from SQL Server, store it in the data lake slicedimport/multipleFileADX and then read it via external table and the function Source_GetMeasurementFromMultifileSource

    DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
            ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
            ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
     	    ,@SourceSystemName sysname      = 'SQLToLakeToADX_CopyActivityAndADXFunction'
     	    ,@ContainerName    sysname      = 'slicedimport'
            ,@MaxRowsPerFile   int          = 1


    EXEC [Helper].[GenerateSliceMetaData] 
             @LowWaterMark            = @LowWaterMark
            ,@HigWaterMark            = @HigWaterMark
            ,@Resolution              = @Resolution
            ,@SourceSystemName        = @SourceSystemName
     	    ,@SourceSchema            = 'Core'
     		,@SourceObject            = 'Measurement'
     		,@GetDataCommand          = 'SELECT [Ts], [SignalName], [MeasurementValue] FROM [Core].[Measurement]'
     		,@GetDataADXCommand       = 'Source_GetMeasurementFromSQL'
     		,@DateFilterAttributeName = '[Ts]'
     		,@DateFilterAttributeType = 'DATETIME2(3)' -- Datatype should match to source table
     		,@DestinationObject       = 'Measurement'
     		,@ContainerName           = @ContainerName
            ,@AlternativeRootFolder   = 'SQLToLakeToADX'
            ,@MaxRowsPerFile          = @MaxRowsPerFile




SELECT *
FROM   [Mart].[SlicedImportObject]
WHERE  SourceSystemName  = 'SQLToLakeToADX_CopyActivityAndADXFunction'


