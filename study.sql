-- Strict units: one representative per distinct byte content. Its own
-- filename is exact SKILL.md and the dataset parser accepts its header.
-- Reuse counts include only exact-basename occurrences in nonfork repos.
-- name: group_features
WITH reuse AS (
 SELECT a.file_sha,COUNT(*) AS occurrences,
  COUNT(DISTINCT a.repo_full_name) AS repositories,
  COUNT(DISTINCT r.owner) AS owners
 FROM artifacts a JOIN repos r ON r.full_name=a.repo_full_name
 WHERE a.filename='SKILL.md' COLLATE BINARY
  AND r.metadata_fetched=1 AND r.is_fork=0
 GROUP BY a.file_sha
), folder AS (
 SELECT repo_full_name,artifact_path,
  SUM(entry_type='file') AS recorded_files,
  SUM(entry_type='file' AND content IS NOT NULL) AS text_files
 FROM artifact_siblings GROUP BY 1,2
)
SELECT p.file_sha,p.repo_full_name,p.path,p.name,p.body_chars,
 p.description,p.location_class,p.has_scripts,p.has_references,
 p.composition_fetched,p.composition_truncated,p.history_fetched,
 p.content_sha_ok,r.language,r.stars,r.license,
 u.occurrences,u.repositories,u.owners,
 CASE WHEN u.owners>1 THEN 'cross-owner'
  WHEN u.occurrences>1 THEN 'same-owner-multiple'
  ELSE 'single-occurrence' END AS reuse_stratum,
 COALESCE(f.recorded_files,0) AS recorded_files,
 COALESCE(f.text_files,0) AS text_files
FROM artifacts p JOIN repos r ON r.full_name=p.repo_full_name
JOIN reuse u ON u.file_sha=p.file_sha
LEFT JOIN folder f ON f.repo_full_name=p.repo_full_name
 AND f.artifact_path=p.path
WHERE p.dedup_primary=1 AND p.filename='SKILL.md' COLLATE BINARY
 AND p.frontmatter_valid=1 AND p.content IS NOT NULL
 AND TRIM(p.content)<>'' AND r.metadata_fetched=1 AND r.is_fork=0
ORDER BY p.file_sha;
