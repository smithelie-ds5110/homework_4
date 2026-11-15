-- T1a. Every rating next to its user's mean and its movie's mean.
-- Required columns: user_id, movie_id, rating, user_mean, movie_mean
-- One query, no join, no GROUP BY.
--
-- Prediction (commit before running): this query returns ______ rows, because ______. Prediction is in the WRITEUP.

SELECT
    user_id,
    movie_id,
    rating,
    avg(rating) over (partition by user_id) user_mean,
    avg(rating) over (partition by movie_id) movie_mean
FROM ratings;