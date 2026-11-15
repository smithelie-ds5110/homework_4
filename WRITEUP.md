
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
- Result: The result did not depart from my prediction. The result contained 1 row with the desired columns and the number above both was far less than the number of ratings as predicted. In the case
of the restricted data set share, the share actually rose. There were 45,232 ratings with an overall share of 45.23% and a restricted share of 46.04%.
- Explanation: The query uses window functions to calculate the user and movie means, along with the number of ratings per movie. 
A CTE allows these values to be used in the outer query to count ratings above both means and calculate their shares. 
Restricting the calculation to movies with at least 20 ratings reduces the number of ratings which then allowed me to calculate the shares. The shares increased because the retained ratings had a higher
proportion above both means.

<b>t1c_window_rewrite.sql</b>
- Prediction: The separate genre-means aggregation and the join back to movie_genre will disappear. I expect the rewritten query to return the same result set as the original CTE chain.
- Result: The result was as expected. The shape and result set match the reference.
- Explanation: The rewrite works because I used a window function to calculate the average of movie means by genre, rather than calculating them separately in a CTE and joining them back. 
This simplifies the query while preserving the same results as the original.

<b>Additional T1 explanation</b>
1. A query can use two different partitions because each window function operates independently. In this case, one calculates the average rating by user and the other by movie.
2. A movie with only one rating can never count as "above both" because its only rating is equal to its movie mean, not greater than it.
3. In T1c, the window function replaced the separate genre-means aggregation and the join back to the movie-genre data. The original CTE chain needed these steps because GROUP BY collapsed the rows into genre averages, requiring a join to associate those averages with individual movies again.

