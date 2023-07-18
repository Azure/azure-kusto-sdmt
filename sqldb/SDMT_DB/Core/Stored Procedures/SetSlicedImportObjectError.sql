

CREATE PROCEDURE [Core].[SetSlicedImportObjectError]
     @SlicedImportObject_Id uniqueidentifier
    ,@Error NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON

    -- Update LastStart to the current time
    UPDATE [Core].[SlicedImportObject]
    SET [LastSuccessEnd]    = NULL
       ,[LastErrorEnd]      = GETUTCDATE()
       ,[LastErrorMessage]  = @Error
    WHERE [SlicedImportObject_Id] = @SlicedImportObject_Id;

    -- Select all attributes for the given SlicedImportObject_Id
    SELECT 'DONE' [ForPipeline];
END;