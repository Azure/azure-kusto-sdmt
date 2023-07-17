
CREATE PROCEDURE [Helper].[DropExistingSliceMetaData] (
            @SourceSystemName        sysname
		   ,@SourceSchema            sysname   
		   ,@SourceObject            sysname   
		   ,@IncludeHistoryData      bit       = 0)
AS		  
BEGIN

  SET NOCOUNT ON

  BEGIN TRANSACTION

		

        DELETE FROM [Core].[SlicedImportObject]
		WHERE [SourceSystemName]             LIKE @SourceSystemName 
          AND [SourceSchema]                 LIKE @SourceSchema     
          AND [SourceObject]                 LIKE @SourceObject;


		IF @IncludeHistoryData = 1
		BEGIN
          ALTER TABLE [Core].[SlicedImportObject] SET ( SYSTEM_VERSIONING = OFF );

		  DECLARE @SQL_Command NVARCHAR(MAX)
		         ,@Params      NVARCHAR(MAX) = '@SourceSystemName sysname, @SourceSchema sysname, @SourceObject sysname'


		  SET @SQL_Command = 'DELETE FROM [Core].[SlicedImportObjectHistory]
                              WHERE [SourceSystemName]             LIKE @SourceSystemName 
                              AND [SourceSchema]                 LIKE @SourceSchema     
                              AND [SourceObject]                 LIKE @SourceObject'

          EXEC sp_executesql @SQL_Command, @Params, @SourceSystemName=@SourceSystemName, @SourceSchema=@SourceSchema,  @SourceObject= @SourceObject

          ALTER TABLE [Core].[SlicedImportObject] SET ( SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Core].[SlicedImportObjectHistory]));
		END


  COMMIT TRANSACTION

END