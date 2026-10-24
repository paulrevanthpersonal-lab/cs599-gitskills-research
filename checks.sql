-- name: table_counts
SELECT 'artifacts' AS table_name, COUNT(*) AS n FROM artifacts
UNION ALL SELECT 'repos', COUNT(*) FROM repos
UNION ALL SELECT 'artifact_siblings', COUNT(*) FROM artifact_siblings
UNION ALL SELECT 'mining_runs', COUNT(*) FROM mining_runs;
-- name: content_groups
SELECT COUNT(*) AS groups, SUM(n>1) AS multiple_occurrences,
 SUM(owners>1) AS multiple_owners, MAX(n) AS max_occurrences,
 MAX(repos) AS max_repositories, MAX(owners) AS max_owners
FROM (SELECT a.file_sha, COUNT(*) n,
 COUNT(DISTINCT a.repo_full_name) repos, COUNT(DISTINCT r.owner) owners
 FROM artifacts a JOIN repos r ON r.full_name=a.repo_full_name
 GROUP BY a.file_sha);
-- name: representative_invariant
SELECT COUNT(*) AS groups_without_exactly_one_primary
FROM (SELECT file_sha FROM artifacts GROUP BY file_sha
 HAVING SUM(dedup_primary=1)<>1);
-- name: missing_hashes
SELECT COUNT(*) AS n FROM artifacts
WHERE file_sha IS NULL OR TRIM(file_sha)='';
-- name: orphan_artifacts
SELECT COUNT(*) AS n FROM artifacts a LEFT JOIN repos r
 ON r.full_name=a.repo_full_name WHERE r.full_name IS NULL;
-- name: orphan_siblings
SELECT COUNT(*) AS n FROM artifact_siblings s LEFT JOIN artifacts a
 ON a.repo_full_name=s.repo_full_name AND a.path=s.artifact_path
WHERE a.path IS NULL;
-- name: primary_quality
SELECT COUNT(*) AS n, SUM(content IS NULL) AS null_content,
 SUM(TRIM(content)='') AS empty_content,
 SUM(frontmatter_valid=0) AS invalid_frontmatter,
 SUM(composition_fetched=0) AS missing_composition,
 SUM(composition_truncated=1) AS truncated_composition,
 SUM(history_fetched=1) AS history_available,
 SUM(julianday(first_commit_at)>julianday(last_commit_at)) AS reversed_history,
 SUM(julianday(first_commit_at)<julianday('2025-10-01')) AS pre_format_history
FROM artifacts WHERE dedup_primary=1;
-- name: nonprimary_enrichment
SELECT COUNT(*) AS n, SUM(content IS NOT NULL) AS with_content,
 SUM(composition_fetched=1) AS with_composition
FROM artifacts WHERE dedup_primary=0;
-- name: nonprimary_siblings
SELECT COUNT(*) AS n FROM artifact_siblings s JOIN artifacts a
 ON a.repo_full_name=s.repo_full_name AND a.path=s.artifact_path
WHERE a.dedup_primary=0;
-- name: filenames
SELECT filename,COUNT(*) AS n FROM artifacts
GROUP BY filename ORDER BY n DESC;
-- name: locations
SELECT location_class,COUNT(*) AS n FROM artifacts
GROUP BY location_class ORDER BY n DESC;
-- name: repo_quality
SELECT COUNT(*) AS n,COUNT(DISTINCT owner) AS owners,
 SUM(metadata_fetched=0) AS unfetched,
 SUM(language IS NULL OR TRIM(language)='') AS missing_language,
 SUM(license IS NULL OR TRIM(license)='') AS missing_license,
 SUM(is_fork=1) AS forks FROM repos;
-- name: sibling_quality
SELECT COUNT(*) AS n, SUM(content IS NOT NULL) AS text_present,
 SUM(content IS NOT NULL AND TRIM(content)<>'') AS nonempty_text,
 SUM(skipped_reason IS NOT NULL) AS skip_reason_present,
 SUM(entry_type='file') AS files,SUM(entry_type='dir') AS directories
FROM artifact_siblings;
-- name: sibling_fetch_codes
SELECT content_fetched,entry_type,COUNT(*) AS n,
 SUM(content IS NOT NULL) AS text_present
FROM artifact_siblings GROUP BY 1,2 ORDER BY 1,2;
-- name: sibling_count_vs_all_entries
SELECT COUNT(*) AS mismatches FROM artifacts a LEFT JOIN
 (SELECT repo_full_name,artifact_path,COUNT(*) AS n
  FROM artifact_siblings GROUP BY 1,2) s
ON s.repo_full_name=a.repo_full_name AND s.artifact_path=a.path
WHERE a.dedup_primary=1 AND a.composition_fetched=1
 AND a.composition_truncated=0 AND
 COALESCE(a.sibling_count,0)<>COALESCE(s.n,0);
-- name: sibling_count_vs_files
SELECT COUNT(*) AS mismatches FROM artifacts a LEFT JOIN
 (SELECT repo_full_name,artifact_path,SUM(entry_type='file') AS n
  FROM artifact_siblings GROUP BY 1,2) s
ON s.repo_full_name=a.repo_full_name AND s.artifact_path=a.path
WHERE a.dedup_primary=1 AND a.composition_fetched=1
 AND a.composition_truncated=0 AND
 COALESCE(a.sibling_count,0)<>COALESCE(s.n,0);
-- name: history_coverage
SELECT location_class,COUNT(*) AS representatives,
 SUM(history_fetched=1) AS histories
FROM artifacts WHERE dedup_primary=1 GROUP BY 1 ORDER BY 1;
-- name: date_ranges
SELECT MIN(discovered_at) AS min_discovered,
 MAX(discovered_at) AS max_discovered,
 MIN(first_commit_at) AS min_first_commit,
 MAX(last_commit_at) AS max_last_commit FROM artifacts;
-- name: date_parse_failures
SELECT SUM(discovered_at IS NOT NULL AND julianday(discovered_at) IS NULL)
 AS discovery_parse_failures,
 SUM(first_commit_at IS NOT NULL AND julianday(first_commit_at) IS NULL)
 AS first_parse_failures,
 SUM(last_commit_at IS NOT NULL AND julianday(last_commit_at) IS NULL)
 AS last_parse_failures FROM artifacts;
-- name: mining_runs
SELECT * FROM mining_runs ORDER BY run_id;
-- name: annotated_example
SELECT a.repo_full_name,a.path,a.file_sha,a.name,a.body_chars,
 a.sibling_count,a.has_scripts,a.has_references,
 s.entry_name,s.entry_type,s.entry_size
FROM artifacts a JOIN artifact_siblings s
 ON s.repo_full_name=a.repo_full_name AND s.artifact_path=a.path
WHERE a.dedup_primary=1
 AND a.file_sha='00000f2a9d8359900f2075b536b435ca9473a5b9';
-- name: missing_repo_flags
SELECT SUM(is_fork IS NULL) AS unknown_fork,
 SUM(owner IS NULL OR TRIM(owner)='') AS missing_owner,
 SUM(stars IS NULL) AS missing_stars FROM repos;
-- name: strict_filter_audit
SELECT COUNT(*) AS exact_valid_representatives,
 SUM(r.is_fork IS NULL) AS unknown_representative_fork
FROM artifacts a JOIN repos r ON r.full_name=a.repo_full_name
WHERE a.dedup_primary=1 AND a.filename='SKILL.md' COLLATE BINARY
 AND a.frontmatter_valid=1 AND a.content IS NOT NULL;
