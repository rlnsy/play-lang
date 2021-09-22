--------------------
-- SAMPLE QUERIES --
--------------------

-- Find overall assist counts listed highest to lowest --
SELECT * FROM (SELECT COUNT(*) AS assist_tot, assist_by FROM plays GROUP BY assist_by) ORDER BY assist_tot DESC;