
CREATE PROCEDURE [Core].[ResetSlicedImportObject]
(
     @SourceSystemName      sysname          = NULL
    ,@SlicedImportObject_Id uniqueidentifier = NULL
)
AS
BEGIN
  SET NOCOUNT ON

  IF (@SourceSystemName IS NOT NULL OR @SlicedImportObject_Id IS NOT NULL)
  BEGIN
    UPDATE [Core].[SlicedImportObject]
    SET [LastStart] = NULL
       ,[LastSuccessEnd] = NULL
       ,[LastErrorMessage] = NULL
	   ,[RowsTransferred] = NULL
    WHERE [SourceSystemName] LIKE ISNULL(@SourceSystemName,'%')
      AND (@SlicedImportObject_Id IS NULL
       OR [SlicedImportObject_Id] = @SlicedImportObject_Id);
   END

    -- Select all attributes for the given SlicedImportObject_Id
    SELECT CONCAT(@@ROWCOUNT, ' rows reset') as Result
END;