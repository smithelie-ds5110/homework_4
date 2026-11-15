
# T1. A rating in context

<b>a) t1a_rating_in_context.sql</b>
- Prediction: The query should return 100k rows, one for each rating in the database.
- Result: The result was as expected and aligns with the explanation. The net result is 100k rows with columns for user_mean and movie_mean.
- Explanation: Window functions preserve the original rows while calculating aggregate statistics over partitions. Since I am not grouping, the rows should hold steady from input to output. 

<b>b) t1b_above_both.sql</b>
- Prediction: The query should return one row containing the total number of ratings (100k), the number of ratings above both the user and movie means and two shares.
I expect the number above both means to be less than the total number of ratings. 
Restricting the share to movies with at least 20 ratings will decrease the numerator and may decrease the denominator used to calculate the share. This, however, can cause the 
share to increase, decrease or remain fixed; it depends on the proportional changes with the new restricted sets.