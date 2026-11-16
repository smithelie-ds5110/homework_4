-- T3. Rating sessions. A user's ratings form one session until there is a gap
-- of more than 1800 seconds (30 minutes) since that user's previous rating.

-- Required columns, one row per session:
--   user_id, session_no, n_ratings, start_ts, duration_s

-- session_no counts 1, 2, 3, ... within each user, in time order.

-- Suggested steps (one CTE each): gap with LAG; a 0/1 new_session flag;
-- a running SUM of the flag with an explicit ROWS frame; GROUP BY.
--
-- Prediction (commit before running): median ratings per session = ______.

-- YOUR QUERY HERE

WITH gaps AS (
    SELECT
        user_id,
        timestamp,
        LAG(timestamp) OVER (
            PARTITION BY user_id
            ORDER BY timestamp, movie_id
        ) AS previous_ts
    FROM ratings
),
flags AS (
    SELECT *,
        CASE
            WHEN previous_ts IS NULL
              OR timestamp - previous_ts > 1800
            THEN 1
            ELSE 0
        END AS new_session
    FROM gaps
),
numbered AS (
    SELECT *,
        SUM(new_session) OVER (
            PARTITION BY user_id
            ORDER BY timestamp
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS session_no
    FROM flags
)
SELECT
    user_id,
    session_no,
    COUNT(*) AS n_ratings,
    MIN(timestamp) AS start_ts,
    MAX(timestamp) - MIN(timestamp) AS duration_s
FROM numbered
GROUP BY user_id, session_no;