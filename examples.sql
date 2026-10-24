-- Demonstration 1: observed output 29786.
SELECT COUNT(*) FROM artifacts;

-- Demonstration 2: observed output is an empty result (zero invalid groups).
SELECT file_sha FROM artifacts GROUP BY file_sha
HAVING SUM(dedup_primary = 1) <> 1;

-- Demonstration 3: observed counts 2365, 12539 and 14882, respectively.
SELECT location_class, COUNT(*) AS occurrences
FROM artifacts GROUP BY location_class ORDER BY location_class;
