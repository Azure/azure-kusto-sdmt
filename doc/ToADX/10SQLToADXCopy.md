## SQL to ADX

As simple way to transfer data from a SQL database (any relational database that is supported as a copy activity source) to ADX is to use a copy activity.
<br>

### Scenario

The following scenario is used to explain the concept. The source database is a SQL database and the destination is an ADX database. The data is transferred in day slices. The data is partitioned by the column `Ts`.
The data is transferred from the source table `Core.Measurement` to the destination table `Measurement`. 

![Senario Overview](./../../doc/assets/sql-to-adx/SMDT_SQLtoADXScenario.png)

![Relationship between the artifacts](./../../doc/assets/sql-to-adx/SDMT_SQLtoADXOverview.png)


#### Objects in Source Database

The sample reqires a SQL database with the following objects.

    CREATE SCHEMA [Core];
    GO

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

#### Destination table in ADX

The sample reqires a ADX database with the following objects.

    .create table Core_Measurement (Ts: datetime, SignalName: string, MeasurementValue: real) with (folder = "Core")

<br>

#### Transfer
The transfer should happen in day slices (2021-11-25, 2021-11-26, 2021-11-27). Then you have to generate the slices with the following T-SQL command. <br>

    DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
            ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
            ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
            ,@SourceSystemName sysname      = 'SQLToADX_CopyActivity'
    
    EXEC [Helper].[GenerateSliceMetaData] 
            @LowWaterMark            = @LowWaterMark
            ,@HigWaterMark            = @HigWaterMark
            ,@Resolution              = @Resolution
            ,@SourceSystemName        = @SourceSystemName
            ,@SourceSchema            = 'Core'
            ,@SourceObject            = 'Measurement'
            ,@DateFilterAttributeName = '[Ts]'
            ,@DateFilterAttributeType = 'DATETIME2(3)' 
            ,@DestinationObject       = 'Core_Measurement'

    GO

This will automatically generate a SQL statement 'SELECT * FROM Core.Measurement', assuming that all attributes sould be transferred.

<br>



You can specify the SQL statement by providing a value for the parmeter `@GetDataCommand`. This allow you to restrict the columns that are transferred or to do any kind of required transformations on the source side.

    DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
            ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
            ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
            ,@SourceSystemName sysname      = 'SQLToADX_CopyActivity'
    
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
            ,@DestinationObject       = 'Measurement'

<br>


#### Pipeline

A pipeline pipeline to transfert the data from SQL to ADX using the copy activity will require the following aritifacts:
 * Lookup to get a list of the slices
 * ForEach activity to iterate over the list
   * Loookup activity to record the start for the slice and to get the required property values
   * An ADX command activity to clean up old data in the corresponding ADX slice (extent)
   * A copy activity to do the data transfer
   * Lookup activites to record the successful end or error, depending on the output of the copy activity


**Pipeline Overview**
![Relationship between meta data and pipeline](./../../doc/assets/sql-to-adx/SDMT_SQLtoADXPipelineOverview.png)

**Property Settings**
![Relationship between meta data and pipeline](./../../doc/assets/sql-to-adx/SDMT_SQLtoADXPipelineSettings.png)

**Property Values at runtime**
![Relationship between meta data and pipeline](./../../doc/assets/sql-to-adx/SDMT_SQLtoADXPipelineValues.png)


#### Implement it yourself

##### Create the pipeline

Make sure that you have the required datasets and linked servers defined in your Azure Data Factory or in your Azure Synapse Analytics workspace. See also  [Setup](./../../doc/01SetupSMDT.md). 

Create a new pipeline with the name 'SDMT-SQL-Copy-ADX-Minimal', switch to the json view and copy the code from the file [SDMT-SQL-Copy-ADX-Minimal.json](./SDMT-SQL-Copy-ADX-Minimal.json) into the pipeline.

If you would like to have control over the data transfer, you can use the pipeline [SDMT-SQL-Copy-ADX-ConditionalDelete.json](./SDMT-SQL-Copy-ADX-ConditionalDelete.json). This pipeline has a conditional activity and a corresponding parameter to define if the target data slice should be deleted before the slice is transmitted. The pipeline 'SDMT-SQL-Copy-ADX-Minimal' will always delete the target data slice before the data is transmitted.


##### Source and destination objects

Select the table that you would like to transfer from the source database and the destination database. The sample uses the following objects.

    SQL Source: [Core].[Measurement]
    ADX Destination: [Core_Measurement]

You find the code to create the sample objects in the file [SQLToADX.sql](./SQLToADX.sql).


##### Define Slice meta data

The slice meta data is used to control the data transfer. The sample uses the following values.

    LowWaterMark: 2021-11-25
    HighWaterMark: 2021-11-28
    Resolution: Day
    ...

You can either use is or adjust it to your specific needs.


##### Test it yourself

The system is now ready to be tested.


