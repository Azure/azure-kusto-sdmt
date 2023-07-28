# Tips and Tricks plus Q&A


- [Tips and Tricks plus Q\&A](#tips-and-tricks-plus-qa)
  - [Tips and Tricks](#tips-and-tricks)
    - [Balance the load](#balance-the-load)
  - [Q\&A](#qa)
    - [TooManyRequests (429-TooManyRequests):](#toomanyrequests-429-toomanyrequests)



## Tips and Tricks

### Balance the load

One of the benefits of the SDMT is that it allows you to control the load of the data. This is especially important if you have a large number of slices and you would like to avoid that all slices are loaded at the same time.
The settings of the for each activity in the pipeline allow you to control the number of slices that are loaded in parallel. The default setting is 10 slices. If you would like to load more slices in parallel, then you can increase the value of the `batchCount` parameter. If you would like to load less slices in parallel, then you can decrease the value of the `batchCount` parameter.
If needed you can define that pipeline as `sequential`. This will load the slices one after the other. 

## Q&A



### TooManyRequests (429-TooManyRequests): 

If you get the error message TooManyRequests (429-TooManyRequests) then you must reduce the parallelism of the pipeline (`batchCount`). In the extreme case you have to set the pipeline to  `sequential`.
Using the sql_request pluging is more sensitive than the copy activity or getting data via external tables.