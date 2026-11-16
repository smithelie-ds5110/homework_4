
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

# T2. Top three per occupation
- Prediction: There are 21 occupations in the database, so I expect ROW_NUMBER() to return at most 63 rows (21 × 3). The actual number may be lower because some occupations may have fewer than three movies meeting the minimum requirement of 20 ratings per movie from users in that occupation. RANK() may return more rows than ROW_NUMBER() because tied movies share the same rank, potentially producing more than three rows per occupation.
- Result: ROW_NUMBER() returned 27 rows, while RANK() returned 28. 
- Explanation: The difference comes from a tie in the educator occupation, where Dr. Strangelove and Rear Window both have an average rating of ~4.5714. ROW_NUMBER() assigns each movie a unique position; excluding one of the tied movies from the top three. RANK() assigns both movies pos 3, allowing both to appear in the results. It also skips the next pos after a tie.

Some occupations have less than 3 qualifying movies because not enough movies meet the minimum requirement of 20 ratings from users in that occupation. Executive only has 2 qualifying movies and technician only has 1. Eleven other occupations have no qualifying movies.
Some occupations have fewer than three qualifying movies because not enough movies meet the minimum requirement of 20 ratings from users in that occupation. Executive has only two qualifying movies, and technician has only one. Eleven other occupations have no qualifying movies.
Some occupations have fewer than three qualifying movies because not enough movies meet the minimum requirement of 20 ratings from users in that occupation. Executive has only two qualifying movies, and technician has only one. Eleven other occupations have no qualifying movies.

# T3. Sessions and frames
t3_sessions.sql
- Prediction: Median ratings per session = 1. This is an educated guess because the total number of ratings does not tell us how frequently users rate movies or how their ratings are distributed over time. The actual median depends on the gaps between consecutive ratings.
- Result: The query identified 2,793 sessions, with a median of 11 ratings per session and a maximum of 737 ratings in one session. My prediction of 1 was incorrect. Removing the explicit ROWS frame did not change the results.
- Explanation:
  - The query uses LAG() to find the previous rating's timestamp for each user. It then assigns a flag of 1 when a new session begins and 0 otherwise. A running SUM() of these flags assigns session numbers, and GROUP BY produces one row per session.
  The default frame produces identical results because ratings with the same timestamp belong to the same session. Only the first rating at a timestamp can have a new session flag of 1; subsequent ratings at that timestamp have a flag of 0.
  The ROWS frame processes flags individually while the default RANGE frame includes tied timestamps together. Since the additional flags are all 0, the session numbers remain unchanged.
  The 30 minute rule could incorrectly split a real session if a user spends 40 minutes watching a movie before submitting another rating. Even though the user remained active, the rule would identify a new session.

t3b_running_mean.sql
- Prediction: I predict the two running averages will disagree on many rows because some ratings may have identical timestamps. One method processes tied ratings together, while the other processes them one at a time.
- Result: The two running averages disagreed on 49,787 rows. There were 75,772 rows sharing a timestamp with another rating from the same user and all 49,787 disagreements occurred among those rows. The final running averages agreed for all 943 users.
- Explanation: The differences occur when a user has multiple ratings with the same timestamp. The default RANGE frame includes all ratings tied at the current timestamp, while the explicit ROWS frame processes ratings individually.
- Unlike the session flags, which only contain 0s after the first rating at a timestamp, individual rating scores can differ. Including several ratings at once can therefore change the running average compared with processing them one at a time.
The calculations agree on each user's final value because both frames have included all of that user's ratings by the end. The final result is the overall average rating for that user, regardless of how the intermediate averages were calculated.

# T4. Two indexes for four queries
I am choosing to add indexes for movie_id and timestamp.
- Prediction: 
  - Query A: BEFORE: SEARCH existing PK index + temp B-tree for sorting AFTER: Same
  - Query B: BEFORE: SCAN AFTER: SEARCH using movie_id
  - Query C: BEFORE: SCAN AFTER: SEARCH using timestamp
  - Query D: BEFORE: SCAN AFTER: SCAN
  - Query D(rewritten): BEFORE: SCAN if no index AFTER: SEARCH using timestamp

- Result/Explanation: Both indexes were created successfully and all queries returned unchanged results.
  - Why did I choose these indexes? 
    - I chose indexes on movie_id and timestamp because they provide the greatest benefit across the queries. The movie_id index speeds up Query B, while the timestamp index speeds up Query C and the rewritten Query D. Query A already benefits from an existing index.

  - Why did A_profile use an index before I added any? 
    - The ratings table already has a composite primary key on (user_id, movie_id), which sqlite automatically indexes. Since Query A filters by user_id, sqlite can use the first column of that existing index to find matching ratings.

  - What additional work does USE TEMP B-TREE FOR ORDER BY perform? 
    - Although the existing index helps locate a user's ratings, it does not store them in timestamp order. sqlite must therefore perform an additional sorting operation using a temporary B-tree to identify the 20 most recent ratings.

  - How many bytes do the indexes use? 
    - The database increased from 3629056 to 5967872 bytes after adding the indexes. The indexes added about 2338816 bytes.
  
  - Why does the original D_month query remain a SCAN? 
    - The original query uses strftime() to convert each timestamp into a calendar month. Because the index stores raw timestamps rather than the transformed values, sqlite cannot directly search the index for a particular month. sqlite still needs to SCAN in order to evaluate strftime().

  - What does rewriting D_month change?
    - A direct timestamp range is used, allowing an index on timestamp to be used to execute a SEARCH.

  - Did considering the rewrite change my choice of indexes? 
    - No, I'd stick with my choice. The rewrite just unlocked the ability to use the timestamp index while keeping my other performant gains viable.
    - Queries B and C improved by approximately 115× and 154×, respectively, while the rewritten D improved by approximately 13×. Query A showed no meaningful improvement, and the original D improved only slightly.

# T5. Recommendation
I would recommend adding indexes for movie_id and timestamp because they significantly improve query performance without altering the results.
Based on measurements, the movie_id index made Query B about 115 times faster while the timestamp index made query C about 154 times faster.
Also, rewriting Query D so it could use the timestamp index made it about 13 times faster.

I would leave out an additional index for Query A because it already uses an existing index and runs in about 0.08 ms. There is little to gain by adding another index
when performance is already excellent.

The downside of adding indexes, however, is the increased storage requirements and slower writes, since indexes must be maintained whenever new data is written. In our case, the indexes added just under 2.5 MB to the database.

However, I believe the additional costs are justified for a read-heavy database. Storage is generally cheaper than compute time, specifically in cloud workloads and faster queries save developer time.
For write-heavy workloads, I would reconsider whether the performance gains justify the additional maintenance costs.
