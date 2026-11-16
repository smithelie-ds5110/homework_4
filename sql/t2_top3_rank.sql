-- T2 (version 2, RANK). The same question, with RANK() ordered by mean_rating
-- only, keeping rows with pos <= 3.
-- Required columns: occupation, pos, movie_id, title, n, mean_rating
--
-- Prediction (commit before running): ______ rows, which is (more / the same / fewer)
-- than version 1, because ______.

-- YOUR QUERY HERE

-- T2 (version 1, ROW_NUMBER). The three highest-rated movies for each
-- occupation, among movies rated at least 20 times by users with that occupation.
-- Required columns: occupation, pos, movie_id, title, n, mean_rating
-- Order the window so that the result is the same on every run (state your
-- tie-breaker in WRITEUP.md).
--
-- Prediction (commit before running): ______ rows.

-- YOUR QUERY HERE

WITH movie_stats AS (
    SELECT
        u.occupation,
        r.movie_id,
        AVG(r.rating) mean_rating,
        COUNT(*) n
    FROM ratings r
    JOIN users u USING (user_id)
    GROUP BY u.occupation, r.movie_id
    HAVING COUNT(*) >= 20
),
ranked AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY occupation ORDER BY mean_rating DESC) pos
    FROM movie_stats
)

SELECT
    ranked.occupation,
    ranked.pos,
    ranked.movie_id,
    m.title,
    ranked.n,
    ranked.mean_rating
FROM ranked
JOIN movies AS m USING (movie_id)
WHERE pos <= 3;