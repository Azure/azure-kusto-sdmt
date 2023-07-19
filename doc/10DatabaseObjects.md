
## Relvant database objects

### Tables

#### [Core].[SlicedImportObject]

The table [Core].[SlicedImportObject] is used to store metadata about sliced import objects. It contains information such as the source system name, source schema, source object, destination schema, destination object, and more.


| AttributeName         | DataType         | DefaultValue                           | Description                                                                              |
|-----------------------|------------------|----------------------------------------|------------------------------------------------------------------------------------------|
| SlicedImportObject_Id | UNIQUEIDENTIFIER | newsequentialid()                      | Primary key for the table. Assigned a new sequential ID by default.                      |
| SourceSystemName      | sysname          | NOT NULL                               | Name of the source system from where the data is being imported.                         |
| SourceSchema          | sysname          | NOT NULL                               | Schema name in the source system where the data is located.                              |
| SourceObject          | sysname          | NOT NULL                               | Specific object (e.g., table, view) in the source schema from where data is imported.    |
| GetDataCommand        | NVARCHAR(MAX)    | NULL                                   | Command/query used to fetch data from the source system.                                 |
| FilterDataCommand     | NVARCHAR(1024)   | NULL                                   | Command/query used to filter data while fetching from the source system.                 |
| GetDataADXCommand     | NVARCHAR(MAX)    | NULL                                   | Command/query used to fetch data from Azure Data Explorer (ADX).                         |
| FilterDataADXCommand  | VARCHAR(10)      | NULL                                   | Command/query used to filter data while fetching from Azure Data Explorer (ADX).         |
| DestinationSchema     | sysname          | NULL                                   | Schema name in the destination system where data will be stored.                         |
| DestinationObject     | sysname          | NULL                                   | Specific object (e.g., table, view) in the destination schema where data will be stored. |
| ContainerName         | sysname          | NULL                                   | Name of the container where the data will be stored (e.g., in Blob storage).             |
| DestinationPath       | sysname          | NULL                                   | Path in the destination container where data will be stored.                             |
| DestinationFileName   | sysname          | NULL                                   | Name of the file where data will be stored.                                              |
| DestinationFileFormat | VARCHAR(10)      | '.parquet'                             | File format for the stored data. Default is '.parquet'.                                  |
| MaxRowsPerFile        | INT              | NULL                                   | Maximum number of rows to store in each file.                                            |
| AdditionalContext     | VARCHAR(255)     | NULL                                   | Additional context/information, e.g., for ADX.                                           |
| IngestionMappingName  | sysname          | NULL                                   | Name of the ingestion mapping used for data ingestion into ADX.                          |
| Active                | BIT              | DEFAULT ((1)) NOT NULL                 | Flag indicating if the import object is active or not.                                   |
| PipelineRunId         | VARCHAR(128)     | NULL                                   | Identifier for the pipeline run associated with the data import.                         |
| ExtentFingerprint     | VARCHAR(128)     | NULL                                   | Fingerprint of the data extent.                                                          |
| LastStart             | DATETIME         | NULL                                   | Datetime of the last import start.                                                       |
| LastSuccessEnd        | DATETIME         | NULL                                   | Datetime of the last successful import end.                                              |
| LastErrorEnd          | DATETIME         | NULL                                   | Datetime of the last import error end.                                                   |
| RowsTransferred       | INT              | NULL                                   | Number of rows transferred in the last import operation.                                 |
| LastErrorMessage      | NVARCHAR(MAX)    | NULL                                   | Last error message recorded during import.                                               |
| CreatedBy             | sysname          | DEFAULT (suser_sname()) NOT NULL       | User who created the import object.                                                      |
| ValidFrom             | DATETIME2        | GENERATED ALWAYS AS ROW START NOT NULL | Datetime from when the row becomes valid (for system versioning).                        |
| ValidTo               | DATETIME2        | GENERATED ALWAYS AS ROW END NOT NULL   | Datetime until when the row is valid (for system versioning).                            |


### Stored procdures

#### [Helper].[GenerateSliceMetaData]

The procedure `[Helper].[GenerateSliceMetaData]` is used to generate metadata for sliced import objects. 
It takes in several parameters such as start/end date and the resolution, source system name, source schema, source object, and more. 
The procedure generates metadata by creating slices of the same source object and then deleting existing slices of the same source object. It then generates metadata by looping through cursor data and inserting it into the [Core].[SlicedImportObject] table.


| ParameterName            | DataType      | DefaultValue | Description                                                          |
|--------------------------|---------------|--------------|----------------------------------------------------------------------|
| @LowWaterMark            | DATE          | '2022.01.01' | The lower bound of the time range for which to generate metadata.    |
| @HigWaterMark            | DATE          | '2022.03.31' | The upper bound of the time range for which to generate metadata.    |
| @Resolution              | VARCHAR(25)   | 'day'        | The resolution of the metadata to generate. Can be 'day' or 'month'. |
| @SourceSystemName        | SYSNAME       | NULL         | The name of the source system.                                       |
| @SourceSchema            | SYSNAME       | 'NoSchema'   | The name of the source schema.                                       |
| @SourceObject            | SYSNAME       | NULL         | The name of the source object.                                       |
| @GetDataCommand          | NVARCHAR(MAX) | NULL         | The command to get data from the source object.                      |
| @GetDataADXCommand       | NVARCHAR(MAX) | NULL         | The command to get data from the source object in ADX format.        |
| @DateFilterAttributeName | SYSNAME       | NULL         | The name of the date filter attribute.                               |
| @DateFilterAttributeType | SYSNAME       | 'DATETIME2'  | The data type of the date filter attribute.                          |
| @DestinationSchema       | SYSNAME       | NULL         | The name of the destination schema.                                  |
| @DestinationObject       | SYSNAME       | NULL         | The name of the destination object.                                  |
| @ContainerName           | SYSNAME       | NULL         | The name of the container.                                           |
| @AlternativeRootFolder   | SYSNAME       | NULL         | The alternative root folder.                                         |
| @MaxRowsPerFile          | INT           | NULL         | The maximum number of rows per file.                                 |
| @IngestionMappingName    | SYSNAME       | NULL         | The name of the ingestion mapping.                                   |
| @UseSourceNameForLake    | BIT           | 1            | Whether to use the source name for the lake.                         |

Not all parametes must be defined in all scenarios. But for all of them the following paramters must be provided:
@LowWaterMark, @HigWaterMark,  @Resolution, @SourceSystemName, @SourceObject 

<br>
<br>

#### [Helper].[DropExistingSliceMetaData]

The procedure `[Helper].[DropExistingSliceMetaData]` is used to delete existing slices of the same source object. It takes in parameters such as @SourceSystemName, @SourceSchema, @SourceObject, and @IncludeHistoryData. 
The procedure is used in the stored procedure `[Helper].[GenerateSliceMetaData]` that generates metadata for sliced import objects. It can also be used to clean metadata.

<br>
**Parameters:**

| ParameterName       | DataType | DefaultValue | Description                             |
|---------------------|----------|--------------|-----------------------------------------|
| @SourceSystemName   | sysname  |              | The name of the source system.          |
| @SourceSchema       | sysname  | 'NoSchema'   | The name of the source schema.          |
| @SourceObject       | sysname  |              | The name of the source object.          |
| @IncludeHistoryData | bit      | 0            | Whether to include history data or not, in the delete process. |


the stored procedure is designed to provide flexibility in retrieving SlicedImportObject records from the [Core].[SlicedImportObject] table based on various filtering conditions, including the source system name, import mode, schema, object name, and unique identifier. The procedure can be used to fetch records that are not yet processed, to restart processing for specific objects, or to retrieve all records based on the specified criteria.


#### [Core].[GetSetSlicedImportObjectToLoad]

The stored procedure `[Core].[GetSetSlicedImportObjectToLoad]` is designed to retrieve a list of sliced import objects that need to be loaded into a system. It is used in data import or ETL (Extract, Transform, Load) processes to fetch relevant data for processing. The procedure accepts several input parameters to filter and control the retrieval of sliced import objects based on specific criteria.

**Parameters:**

| Parameter Name       | Data Type    | Default Value | Description                                                                                                  |
|----------------------|--------------|---------------|--------------------------------------------------------------------------------------------------------------|
| @SourceSystemName    | sysname      |               | Specifies the name of the source system for which sliced import objects are being retrieved.                 |
| @SourceSchema        | sysname      | '%'           | Specifies the source schema name. If not specified or set to '%', the procedure considers all source schemas. |
| @SourceObject        | sysname      | '%'           | Specifies the source object name. If not specified or set to '%', the procedure considers all source objects. |
| @SlicedImportObject_Id | varchar(64) | '%'           | Specifies the ID of the sliced import object. If not specified or set to '%', the procedure considers all objects. |
| @Mode                | VARCHAR(25)  | 'REGULAR'     | Specifies the mode of retrieval. Possible values are: 'REGULAR', 'RESTART', or 'ALL'. <br>    If set to `REGULAR`, the procedure will only retrieve sliced import objects where the `LastStart` column is null. </br> If set to `RESTART`, it will only retrieve sliced import objects where the `LastStart` column is not null and the `LastSuccessEnd` column is null. </br> If set to `ALL`, it will retrieve all sliced import objects regardless of their status.                    |


#### [Core].[GetADXDropExtentsCommand]

The purpose of the stored procedure `[Core].[GetADXDropExtentsCommand]` is to generate and return a list of commands for dropping extents in the Azure Data Explorer (ADX) database. The procedure retrieves information from the `[Core].[SlicedImportObject]` table based on the provided parameters `@SourceSystemName` and `@Mode`. It then constructs the necessary commands using the retrieved data.

**Parameters:**

| Parameter Name       | Data Type   | Default Value | Description                                                                                                                                                                                                 |
|----------------------|-------------|---------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| @SourceSystemName    | sysname     | None          | This parameter specifies the name of the source system. The procedure will fetch information only for objects associated with this particular source system.                                                   |
| @Mode                | VARCHAR(25) | 'StartedSlices'| This parameter controls the mode of operation for the procedure. The available options are:                                                                                                                                                                      |
|                      |             |               | - 'StartedSlices': When this mode is selected (default), the procedure will return commands for dropping extents for slices that have started but have not yet completed successfully.                   |
|                      |             |               | - 'AllSlices': When this mode is selected, the procedure will return commands for dropping extents for all slices, regardless of their start or completion status.                                    |

A sample output may look like this:

    .execute database script <| 
    .drop extents <| .show table Measurement extents where tags has 'ExtentFingerprint:20211127'
    .drop extents <| .show table Measurement extents where tags has 'ExtentFingerprint:20211125'
    .drop extents <| .show table Measurement extents where tags has 'ExtentFingerprint:20211126'



#### [Core].[ResetSlicedImportObject]

The purpose of the stored procedure `[Core].[ResetSlicedImportObject]` is to reset specific attributes of records in the `[Core].[SlicedImportObject]` table based on the provided parameters. The procedure takes two optional parameters @SourceSystemName and @SlicedImportObject_Id, which allow you to filter and update specific rows in the table. <br>
To use the stored procedure, you can call it with the desired values for `@SourceSystemName` and `@SlicedImportObject_Id`. If either of the parameters is not provided (NULL), the procedure will update all records in the `[Core].[SlicedImportObject]` table that match the given condition. The update sets specific attributes (`LastStart`, `LastSuccessEnd`, `LastErrorMessage`, and `RowsTransferred`) to NULL, effectively resetting those attributes.


**Parameters:**

| ParameterName       | DataType          | DefaultValue | Description                                                                                            |
|---------------------|-------------------|--------------|--------------------------------------------------------------------------------------------------------|
| @SourceSystemName   | sysname           | NULL         | The name of the source system to filter the records. If NULL, all records will be considered.          |
| @SlicedImportObject_Id | uniqueidentifier | NULL         | The unique identifier of the SlicedImportObject to filter the records. If NULL, all records will be considered. |


#### [Core].[SetSlicedImportObjectEnd]

The stored procedure `[Core].[SetSlicedImportObjectEnd]` is used to update the status of a `SlicedImportObject`. <br>
It updates the `LastSuccessEnd` column of the `SlicedImportObject` table with the current UTC date and time. This indicates the timestamp when the import process was successfully completed. And it updates the `RowsTransferred` column of the `SlicedImportObject` table with the value of `@RowsTransferred`. This provides information about the number of rows that were successfully transferred during the import process.

**Parameters:**

| ParameterName           | DataType             | DefaultValue | Description                                                                                   |
|-------------------------|----------------------|--------------|-----------------------------------------------------------------------------------------------|
| @SlicedImportObject_Id  | uniqueidentifier     | None         | Unique identifier for the specific SlicedImportObject for which the import has completed.   |
| @RowsTransferred        | int                  | None         | Number of rows successfully transferred during the import process.                            |



#### [Core].[SetSlicedImportObjectError]

The purpose of the stored procedure `[Core].[SetSlicedImportObjectError]` is to update an entry in the `[Core].[SlicedImportObject]` table with error-related information for a specific `@SlicedImportObject_Id`. <br>
The procedure updates the `[Core].[SlicedImportObject]` table with the following information for the given `@SlicedImportObject_Id`:
   - `[LastSuccessEnd]` is set to NULL, indicating that the last successful end time is not available.
   - `[LastErrorEnd]` is set to the current UTC date and time, indicating the time when the error occurred.
   - `[LastErrorMessage]` is set to the value of the `@Error` parameter, storing the error message or description.

**Parameters**

Description of Parameters:
| Parameter Name          | Data Type           | Default Value | Description                                                                                                        |
|-------------------------|---------------------|---------------|--------------------------------------------------------------------------------------------------------------------|
| @SlicedImportObject_Id  | uniqueidentifier   | None          | The unique identifier of the Sliced Import Object for which the error information needs to be updated.           |
| @Error                  | NVARCHAR(MAX)      | None          | The error message or description to be stored for the corresponding Sliced Import Object with the given ID.       |


#### [Core].[SetSlicedImportObjectStart] 

The stored procedure `[Core].[SetSlicedImportObjectStart]` serves the purpose of updating specific attributes of a record in the `[Core].[SlicedImportObject]` table. <br> 
It takes two input parameters: `@SlicedImportObject_Id` and `@PipelineRunId`. The procedure is designed to be used in the context of an ETL (Extract, Transform, Load) process where data is being ingested from a source system into the destination system, particularly for Azure Data Explorer (ADX).
<br>
The procedure begins by updating the `[Core].[SlicedImportObject]` table's record with the given `@SlicedImportObject_Id`. The following attributes are updated:
   - `[LastStart]`: Set to the current UTC date and time using `GETUTCDATE()`.
   - `[PipelineRunId]`: Set to the value passed in `@PipelineRunId`.
   - `[LastSuccessEnd]`, `[LastErrorEnd]`, `[LastErrorMessage]`, and `[RowsTransferred]`: Set to `NULL`.
<br>
Generates multiple commands for the data transfer e.g.:
   - `[SelectCommand]`: Combines `[GetDataCommand]` and `[FilterDataCommand]`.
   - `[ADXFetchCommand]`: Combines ADX commands for ingestion with relevant tags for the ADX table.
   - `[EmptyDestinationSliceCommand]`: Generates a command to empty the destination table using `[FilterDataCommand]`.
   - `[ADXDropExtentCommand]`: Generates a command to drop extents in ADX based on tags with the corresponding `[ExtentFingerprint]`.
   - `[ADXCountRowsInExtentCommand]`: Generates a command to count the rows in the extents based on tags with `[PipelineRunId]` and `[ExtentFingerprint]`.

**Parameters**

| ParameterName        | DataType         | DefaultValue | Description                                                                                             |
|----------------------|------------------|--------------|---------------------------------------------------------------------------------------------------------|
| @SlicedImportObject_Id  | UNIQUEIDENTIFIER | N/A          | The unique identifier (ID) of the SlicedImportObject record to be updated.                                |
| @PipelineRunId          | VARCHAR(128)     | N/A          | The ID of the pipeline run associated with the SlicedImportObject.                                       |



### Views

#### [Mart].[SlicedImportObject]

The purpose of the view `[Mart].[SlicedImportObject]` is to provide a consolidated and enriched version of data from the underlying table `[Core].[SlicedImportObject]`. <br>
The view includes additional computed columns and a derived column to simplify the representation of data and provide insights into the loading status of imported objects.
In summary, this view provides a more user-friendly representation of data from the underlying table, including the time duration of loading (`[DurationInSecond]`) and a descriptive loading status (`[LoadStatus]`). It simplifies the process of monitoring and managing the loading of import objects within the system. Users can query this view to get insights into the current status of data import operations and easily identify any issues during the loading process.

**Derived Columns**

| Column   | Logic | Purpose|
|---------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| DurationInSecond    | `DATEDIFF(SECOND, [LastStart], COALESCE([LastSuccessEnd], [LastErrorEnd], GETUTCDATE()))`                                                                     | Represents the time duration (in seconds) of the loading process for each import object. It calculates the difference between the `[LastStart]` timestamp and either `[LastSuccessEnd]` or `[LastErrorEnd]`, whichever is not null.                                                                                                             |
| LoadStatus          | `CASE WHEN [LastStart] IS NULL THEN 'Ready to load' WHEN [LastStart] IS NOT NULL AND [LastSuccessEnd] IS NULL AND [LastErrorMessage] IS NULL THEN 'Loading' WHEN [LastStart] IS NOT NULL AND [LastSuccessEnd] IS NULL AND [LastErrorMessage] IS NOT NULL THEN 'Stopped with Error' WHEN [LastStart] IS NOT NULL AND [LastSuccessEnd] IS NOT NULL THEN 'Successfully load' END` | Describes the loading status of each import object based on specific conditions. The column's value is determined by the `CASE` statement, which evaluates the values of `[LastStart]`, `[LastSuccessEnd]`, and `[LastErrorMessage]`. This column provides an easily interpretable status to identify if the object is ready to load, currently loading, stopped with an error, or successfully loaded. |

#### [Mart].[SuspectSlicedImportObject]

The view named `[Mart].[SuspectSlicedImportObject]` is designed to identify "suspect" import objects that are currently loading and have exceeded a specified duration threshold. It operates based on data from the existing view `[Mart].[SlicedImportObject]` and uses a CTE to calculate the duration limit for each `[SourceSystemName]`, `[SourceSchema]`, and `[SourceObject]` combination. The view returns rows for objects that match specific criteria, indicating they are considered suspect during the loading process.

The `[Mart].[SuspectSlicedImportObject]` view identifies import objects that are currently loading and have exceeded a threshold of 30% above the maximum duration encountered for similar objects in the past. This view can be used for monitoring purposes to identify objects that might be experiencing performance issues or potential errors during the loading process.


**Derived Columns**


| Column | Logic | Purpose |
|---------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| LoadStatus          | `'Suspect' AS [LoadStatus]`                                                                                                                                                                      | Provides a descriptive loading status for the import objects that are considered suspect during the loading process. All rows in this view will have the `[LoadStatus]` column set to 'Suspect'. This helps to easily identify and differentiate these suspect objects from other loading states in the `[Mart].[SlicedImportObject]` view. |