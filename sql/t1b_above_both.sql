-- T1b. How many ratings are above BOTH the user's mean and the movie's mean?
-- Required columns (one row):
--   n_ratings, n_above_both, share_above_both, share_above_both_20plus
-- share_above_both_20plus: the same share, counting only ratings of movies
-- that have at least 20 ratings.
-- Build on T1a in a CTE; filter or count outside it.
--
-- Prediction (commit before running): share_above_both is about ______.

-- YOUR QUERY HERE

with rating_stats AS (
    SELECT
        user_id,
        movie_id,
        rating,
        AVG(rating) OVER (PARTITION by user_id) user_mean,
        AVG(rating) OVER (PARTITION by movie_id) movie_mean,
        COUNT(*) OVER (PARTITION by movie_id) movie_count
    FROM ratings
)

SELECT
    COUNT(*) as n_ratings,
    SUM(CASE WHEN rating > user_mean AND rating > movie_mean THEN 1 ELSE 0 END) n_above_both,
    SUM(CASE WHEN rating > user_mean AND rating > movie_mean THEN 1 ELSE 0 END) / CAST(COUNT(*) AS REAL) share_above_both,
    SUM(CASE WHEN movie_count >= 20 AND rating > user_mean AND rating > movie_mean THEN 1 ELSE 0 END) / CAST(SUM(CASE WHEN movie_count >= 20 THEN 1 ELSE 0 END) AS REAL) share_above_both_20plus
FROM rating_stats;