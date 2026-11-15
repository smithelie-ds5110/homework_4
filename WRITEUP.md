
# T1. A rating in context

a) t1a_rating_in_context.sql:
- Prediction: The query should return 100k rows, one for each rating in the database.
- Result: The result was as expected and aligns with the explanation. The net result is 100k rows with columns for user_mean and movie_mean.
- Explanation: Window functions preserve the original rows while calculating aggregate statistics over partitions. Since I am not grouping, the rows should hold steady from input to output. 


