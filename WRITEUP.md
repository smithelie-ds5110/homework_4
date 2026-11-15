
# T1. A rating in context

## a) t1a_rating_in_context.sql: 

Prediction: The query should return 100k rows, one for each rating in the database.

Explanation: Window functions preserve the original rows while calculating aggregate statistics over partitions. Since I am not grouping, the rows should hold steady from input to output. 


