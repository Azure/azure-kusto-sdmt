CREATE PROCEDURE [Helper].[GenerateSliceMetaData] (
            @LowWaterMark DATE = '2022.01.01'   -- GE
           ,@HigWaterMark DATE = '2022.03.01'   -- LT
    	   ,@Resolution   VARCHAR(25) = 'day'   -- Day/Month
           ,@SourceSystemName        sysname
		   ,@SourceSchema            sysname   = 'NoSchema'
		   ,@SourceObject            sysname   
		   ,@GetDataCommand          nvarchar (max) = NULL
           ,@GetDataADXCommand       nvarchar (max) = NULL
		   ,@DateFilterAttributeName sysname   = NULL
		   ,@DateFilterAttributeType sysname   = 'DATETIME2'
		   ,@DestinationSchema       sysname   = NULL
		   ,@DestinationObject       sysname   = NULL
		   ,@ContainerName           sysname   = NULL 
		   ,@AlternativeRootFolder   sysname   = NULL  -- If provided, then this value is used, insetad of the @SourceSystemName to create the directory path,
		   ,@MaxRowsPerFile          int       = NULL
           ,@IngestionMappingName    sysname   = NULL
           ,@UseSourceNameForLake    bit       = 1
		   ) 
AS
BEGIN

    SET NOCOUNT ON



	-- Delete existing slices of the same source object
	EXEC [Helper].[DropExistingSliceMetaData]  @SourceSystemName   = @SourceSystemName
	                                          ,@SourceSchema       = @SourceSchema
											  ,@SourceObject       = @SourceObject
											  ,@IncludeHistoryData = 0
    
    DECLARE @NumberOfDays   INT
           ,@NumberOfMonths INT
		   ,@TheDate        DATE
		   ,@NextDate       DATE
    
    
    SET @NumberOfDays   = DATEDIFF(DAY,   @LowWaterMark, @HigWaterMark)
    SET @NumberOfMonths = DATEDIFF(MONTH, @LowWaterMark, @HigWaterMark)

    SET @GetDataCommand     = COALESCE(@GetDataCommand, 'SELECT * FROM ' + @SourceSchema + '.' + @SourceObject +  ' ')
    SET @DestinationSchema  = COALESCE(@DestinationSchema, @SourceSchema)   
    SET @DestinationObject  = COALESCE(@DestinationObject, @SourceObject)
    
    DECLARE @LakeSchemaName sysname
           ,@LakeObjectName sysname

    IF @UseSourceNameForLake = 1 
    BEGIN
      SET @LakeSchemaName = @SourceSchema
      SET @LakeObjectName = @SourceObject
    END
    ELSE
    BEGIN
      SET  @LakeSchemaName = @DestinationSchema
      SET  @LakeObjectName = @DestinationObject
    END

    -- Generate the meta data
	DECLARE @SliceCursor CURSOR

	IF  @Resolution  = 'Day'
	BEGIN
	  SET @SliceCursor = CURSOR FOR
	  SELECT TOP (@NumberOfDays) DATEADD(DAY, RowNumber, @LowWaterMark) AS TheDate, DATEADD(DAY, RowNumber +1, @LowWaterMark) AS NextDate
	  FROM  [Helper].[RowNumberList100K]
	END

	IF  @Resolution  = 'Month'
	BEGIN
	  SET @SliceCursor = CURSOR FOR
	  SELECT TOP (@NumberOfMonths) DATEADD(MONTH, RowNumber, @LowWaterMark) AS TheDate, DATEADD(MONTH, RowNumber +1, @LowWaterMark) AS NextDate
	  FROM  [Helper].[RowNumberList100K]
	END

	OPEN @SliceCursor

	FETCH NEXT FROM @SliceCursor INTO @TheDate, @NextDate;

    -- Loop through cursor data
    WHILE @@FETCH_STATUS = 0
    BEGIN
       -- Do something with cursor data
       PRINT 'Column 1: ' + CONVERT(VARCHAR(10),@TheDate) + ' ' + CONVERT(VARCHAR(10),@NextDate);


       INSERT INTO [Core].[SlicedImportObject]
           ([SourceSystemName]
           ,[SourceSchema]
           ,[SourceObject]
           ,[DateFilterAttributeName]
           ,[GetDataCommand]
           ,[GetDataADXCommand]
           ,[FilterDataCommand]
           ,[FilterDataADXCommand]
           ,[LowWaterMark]
           ,[HighWaterMark]
           ,[DestinationSchema]
           ,[DestinationObject]
           ,[ContainerName]
           ,[DestinationPath]
           ,[DestinationFileName]
           ,[MaxRowsPerFile]
           ,[AdditionalContext]
           ,[IngestionMappingName]
           ,[ExtentFingerprint]
		   )
       SELECT  
            @SourceSystemName                             AS [SourceSystemName]
           ,@SourceSchema                                 AS [SourceSchema]
           ,@SourceObject                                 AS [SourceObject]
           ,@DateFilterAttributeName                      AS [DateFilterAttributeName]
           ,@GetDataCommand                               AS [GetDataCommand]
           ,@GetDataADXCommand                            AS [GetDataADXCommand]
           ,'WHERE ' + @DateFilterAttributeName + ' >= CONVERT(' + @DateFilterAttributeType + ', ''' + CONVERT(VARCHAR, @TheDate, 23) + ''', 120) AND ' 
			          + @DateFilterAttributeName + ' < CONVERT(' + @DateFilterAttributeType + ', ''' + CONVERT(VARCHAR, @NextDate, 23) + ''', 120)' 
                                                          AS [FilterDataCommand]
           ,'| where ((' + @DateFilterAttributeName + ' >= todatetime("' + CONVERT(VARCHAR, @TheDate, 23) + '")) and (' 
                          + @DateFilterAttributeName + ' < todatetime("' + CONVERT(VARCHAR, @NextDate, 23) + '")))' 
			  							                  AS [FilterDataADXCommand]
           ,CONVERT(VARCHAR, @TheDate,112)                AS [LowWaterMark]
           ,CONVERT(VARCHAR, @NextDate,112)               AS [HighWaterMark]
           ,@DestinationSchema                            AS [DestinationSchema]
           ,@DestinationObject                            AS [DestinationObject]
           ,@ContainerName                                AS [ContainerName]
           ,COALESCE(@AlternativeRootFolder, @SourceSystemName) + '/' + @LakeSchemaName + '/' + @LakeObjectName + '/'
               + CONVERT(VARCHAR, DATEPART(YEAR, @TheDate)) + '/'
               + RIGHT('00' + CONVERT(VARCHAR, DATEPART(MONTH, @TheDate)), 2) + '/'
               + RIGHT('00' + CONVERT(VARCHAR, DATEPART(DAY, @TheDate)), 2)
                               AS [DestinationPath]
           ,@LakeSchemaName + '_' + @LakeObjectName + '_' + CONVERT(VARCHAR, DATEPART(YEAR, @TheDate))
               + RIGHT('00' + CONVERT(VARCHAR, DATEPART(MONTH, @TheDate)), 2)
               + RIGHT('00' + CONVERT(VARCHAR, DATEPART(DAY, @TheDate)), 2)
               + CASE WHEN @Resolution = 'Month' THEN '_' + CONVERT(VARCHAR, DATEPART(YEAR, DATEADD(DAY, -1, @NextDate)))
                   + RIGHT('00' + CONVERT(VARCHAR, DATEPART(MONTH, DATEADD(DAY, -1, @NextDate))), 2)
                   + RIGHT('00' + CONVERT(VARCHAR, DATEPART(DAY, DATEADD(DAY, -1, @NextDate))), 2)
               ELSE '' END
                                                          AS [DestinationFileName]
           

           ,@MaxRowsPerFile                               AS [MaxRowsPerFile]
           ,'{"creationTime": "' + CONVERT(VARCHAR, @TheDate) + '"}'  -- Take the last day of the month       
                                                          AS [AdditionalContext]
           ,@IngestionMappingName                         AS [IngestionMappingName]


           ,CONVERT(VARCHAR, DATEPART(YEAR, @TheDate))
               + RIGHT('00' + CONVERT(VARCHAR, DATEPART(MONTH, @TheDate)), 2)
               + RIGHT('00' + CONVERT(VARCHAR, DATEPART(DAY, @TheDate)), 2)
               + CASE WHEN @Resolution = 'Month' THEN '_' + CONVERT(VARCHAR, DATEPART(YEAR, DATEADD(DAY, -1, @NextDate)))
                   + RIGHT('00' + CONVERT(VARCHAR, DATEPART(MONTH, DATEADD(DAY, -1, @NextDate))), 2)
                   + RIGHT('00' + CONVERT(VARCHAR, DATEPART(DAY, DATEADD(DAY, -1, @NextDate))), 2)
               ELSE '' END
                                                          AS [ExtentFingerprint]



       FETCH NEXT FROM @SliceCursor INTO @TheDate, @NextDate;
    END
    
    -- Close cursor
    CLOSE @SliceCursor;
    
    -- Deallocate cursor
    DEALLOCATE @SliceCursor;

END
GO


