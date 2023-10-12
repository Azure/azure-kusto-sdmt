/* SQL Source

.create table Source_Measurement (Ts: datetime, SignalName: string, MeasurementValue: real) with (folder = "Source")


.ingest inline into table Source_Measurement <|
datetime('2021-11-25 12:00:03'), 'Temperature',	 23.5
datetime('2021-11-25 12:00:04'), 'Humidity',	 45.4
datetime('2021-11-25 12:00:04'), 'Temperature',	 22.5
datetime('2021-11-26 12:00:07'), 'Temperature',	 23.5
datetime('2021-11-26 12:00:07'), 'Humidity',	 44.8
datetime('2021-11-26 12:00:09'), 'Temperature',	 25.0
datetime('2021-11-27 12:00:07'), 'Humidity',	 44.8
datetime('2021-11-27 12:00:09'), 'Temperature',	 25.0


Source_Measurement

*/

/* ADX destination

.create table Core_Measurement (Ts: datetime, SignalName: string, MeasurementValue: real) with (folder = "Core")

*/

-- Minimal meta data, if all attributes from the source table can be transferred


DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
        ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
        ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
        ,@SourceSystemName sysname      = 'ADXToFabricADX_CopyActivity'
   
EXEC [Helper].[GenerateSliceMetaData] 
         @LowWaterMark            = @LowWaterMark
        ,@HigWaterMark            = @HigWaterMark
        ,@Resolution              = @Resolution
        ,@SourceSystemName        = @SourceSystemName
        ,@SourceSchema            = 'Core'
        ,@SourceObject            = 'Measurement'
        ,@GetDataADXCommand       = 'Source_Measurement | project Ts, SignalName, MeasurementValue'
        ,@DateFilterAttributeName = 'Ts'
        ,@DateFilterAttributeType = 'DATETIME2(3)' -- Datatype should match to source table
        ,@DestinationObject       = 'Core_Measurement'

GO

-- check meta data

SELECT *
FROM   [Mart].[SlicedImportObject]
WHERE  SourceSystemName  = 'ADXToFabricADX_CopyActivity'

