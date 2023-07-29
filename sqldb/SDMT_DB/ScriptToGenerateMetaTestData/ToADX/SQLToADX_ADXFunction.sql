/* SQL Source


Synpase Pipeline (and ADX) must have a login in the Azure SQL Database


Database: e.g. AdventureWorksLT

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


.create table Core_Measurement (Ts: datetime, SignalName: string, MeasurementValue: real) with (folder = 'Core')



.create-or-alter function with (docstring = "Get Measurement data from a SQL Server Database",folder = "Source") Source_GetMeasurementFromSQL(Ts_Day:string) { 
let tbl =  
     evaluate 
       sql_request('Server=tcp:<serverName>.database.windows.net,1433;Authentication="Active Directory Integrated";Initial Catalog=AdventureWorksLT',
                   strcat("SELECT * FROM Core.Measurement WHERE Ts >= CONVERT(DATETIME, '", Ts_Day, "',102) AND tS < DATEADD(DAY , 1, CONVERT(DATETIME, '", Ts_Day, "', 102))"))
                   : (Ts: datetime,  SignalName: string, MeasurementValue: real) 
                  ;
tbl



.create-or-alter function with (docstring = "Get Measurement data from a SQL Server Database",folder = "Source") Source_GetMeasurementFromSQLFullWhere(WherePart:string) { 
let tbl =  
     evaluate 
       sql_request('Server=tcp:<serverName>.database.windows.net,1433;Authentication="Active Directory Integrated";Initial Catalog=AdventureWorksLT',
                   strcat("SELECT * FROM Core.Measurement ", WherePart))
                   : (Ts: datetime,  SignalName: string, MeasurementValue: real) 
                  ;
tbl
}


}


*/


-- If @SourceSchema and @SourceObject are also specified, then they can be used to restrict transfer to specific objects
DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
        ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
        ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
        ,@SourceSystemName sysname      = 'SQLToADX_ADXFunction'
   
EXEC [Helper].[GenerateSliceMetaData] 
         @LowWaterMark            = @LowWaterMark
        ,@HigWaterMark            = @HigWaterMark
        ,@Resolution              = @Resolution
        ,@SourceSystemName        = @SourceSystemName
        ,@SourceSchema            = 'Core'
        ,@SourceObject            = 'Measurement'
        ,@GetDataADXCommand       = 'Source_GetMeasurementFromSQL'
        ,@DestinationObject       = 'Core_Measurement'



SELECT *
FROM   [Mart].[SlicedImportObject]
WHERE  SourceSystemName  = 'SQLToADX_ADXFunction'



-- If @SourceSchema and @SourceObject are also specified, then they can be used to restrict transfer to specific objects
DECLARE  @LowWaterMark     DATE         = '2021-11-25'   -- GE
        ,@HigWaterMark     DATE         = '2021-11-28'   -- LT   
        ,@Resolution       VARCHAR(25)  = 'Day'   -- Day/Month
        ,@SourceSystemName sysname      = 'SQLToADX_ADXFunctionFullWhere'
   
EXEC [Helper].[GenerateSliceMetaData] 
         @LowWaterMark            = @LowWaterMark
        ,@HigWaterMark            = @HigWaterMark
        ,@Resolution              = @Resolution
        ,@SourceSystemName        = @SourceSystemName
        ,@SourceSchema            = 'Core'
        ,@SourceObject            = 'Measurement'
        ,@DateFilterAttributeName = '[Ts]'
        ,@DateFilterAttributeType = 'DATETIME2(3)'                             -- Datatype should match to source table
        ,@GetDataADXCommand       = 'Source_GetMeasurementFromSQLFullWhere'
        ,@DestinationObject       = 'Core_Measurement'



SELECT *
FROM   [Mart].[SlicedImportObject]
WHERE  SourceSystemName  = 'SQLToADX_ADXFunctionFullWhere'
