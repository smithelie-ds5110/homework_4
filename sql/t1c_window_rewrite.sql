-- T1c. Rewrite t1c_week6_chain.sql with a window function: no genre_means
-- step and no join back. It must return the same rows.
-- Required columns: genre_id, movie_id, movie_mean, genre_mean
--
-- Prediction (commit before running): which two steps of the chain disappear?

WITH movie_stats AS (
    SELECT
        movie_id,
        AVG(rating) AS movie_mean
    FROM ratings
    GROUP BY movie_id
    HAVING COUNT(*) >= 30
),
movie_genre AS (
    SELECT
        mg.genre_id,
        s.movie_id,
        s.movie_mean
    FROM movie_stats AS s
    JOIN movie_genres AS mg USING (movie_id)
),
genre_context AS (
SELECT
    genre_id,
    movie_id,
    movie_mean,
    AVG(movie_mean) OVER (PARTITION BY genre_id) genre_mean
FROM movie_genre)

SELECT
    genre_id,
    movie_id,
    movie_mean,
    genre_mean
FROM genre_context
WHERE movie_mean >= genre_mean + 0.5


