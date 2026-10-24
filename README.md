# CS 599: GitSkills research

This repository contains the Checkpoint 1 dataset audit and proposed research design for **Verification Guidance and Reuse in GitHub Agent Skills**. It is separate from the Eclipse Zenoh contribution project.

## Research questions

1. How does actionable verification guidance differ between skills with a single occurrence, multiple occurrences under one owner, and occurrences across multiple owners?
2. When a representative skill's verification steps refer to local supporting files, are those files present in its complete recorded folder inventory, and does support differ by verification specificity?

The main unit is a distinct content group (`file_sha`), with one explicitly selected representative (`dedup_primary = 1`). Folder information belongs to that representative occurrence and must not be projected onto every content copy.

## Completed work

The public SQLite sample was downloaded and inspected on October 23, 2026. The sample contains 29,786 occurrences, 13,000 content groups, 11,841 repositories and 47,829 sibling entries. SQLite integrity checking passed, and independently recalculated Git blob hashes matched all 13,000 representative contents.

The executed audit found 16 enriched nonprimary copies, 1,755 truncated representative inventories, missing repository fields, and strongly unequal history coverage. The main eligible frame contains 11,192 groups; 10,079 have fetched, untruncated folder inventories. Full outputs are in `results/observed_results.json` and `results/study_summary.json`.

The deterministic 240-group coding frame has been generated. **Its semantic labels are blank. Human coding, label validation and final research-question comparisons have not been completed.** No peer feedback is claimed. The full 44.4 GB release has not been queried.

## Reproduce the observed analysis

Python 3.10 or newer is recommended; the analysis uses only the standard library. The original run used Python 3.12.14 and SQLite 3.53.1. Network access is needed only for downloading the sample.

Download the pinned public sample into an ignored data directory:

```sh
mkdir -p data
curl -L --fail 'https://raw.githubusercontent.com/giuseppedestefanis/gitskills-sample/fff3df93beeee51a5444450891751f143e38da3e/agent_skills_sample.zip' -o data/agent_skills_sample.zip
unzip data/agent_skills_sample.zip -d data
```

Verify the database SHA-256 before running:

```sh
python3 -c "import hashlib; print(hashlib.sha256(open('data/agent_skills_sample.db','rb').read()).hexdigest())"
```

Expected SHA-256:

```text
683888c923a51952fb66f83f21351ed5bf1127ddddf380e517592ae27c367658
```

Run the audit:

```sh
python3 run_checks.py data/agent_skills_sample.db --out rerun-results
```

The database is opened read-only. The script never executes dataset instructions or bundled scripts. It exports the observed audit, schema, group features, study summary and uncompleted coding form. Compare its JSON outputs with the committed `results/` files. Generated group features include parsed descriptions and remain local by default.

A short SQLite demonstration, if the SQLite command-line client is installed:

```sh
sqlite3 -readonly data/agent_skills_sample.db 'SELECT COUNT(*) FROM artifacts;'
```

Expected output: `29786`.

## Files

- `checks.sql`: executed data-quality checks.
- `study.sql`: executed content-group eligibility and feature extraction.
- `run_checks.py`: read-only runner and independent Git blob hash checks.
- `manifest.json`: snapshot identity, checksums and source URLs.
- `results/`: observed query outputs, schema, study summary and blank coding frame.
- `docs/codebook.txt`: proposed human annotation rules and validation plan.
- `docs/checkpoint-1.pdf`: paragraph-based checkpoint report with required headings, including limitations and assignment gaps.
- `docs/checkpoint-1-paragraphs.txt`: editable paragraph text for revising wording.
- `docs/peer-feedback.md`: honest record of current peer-review status.

## Next steps and course milestones

Before the November 3 progress report, pilot the codebook and complete as much annotation as possible with explicit denominators. During November, finish annotation, blind recoding and the planned statistical comparisons. Prepare the presentation for December 3 and final paper for December 9. The report contains the detailed work plan and contingencies.

Another group's feedback and a documented response remain outstanding. The in-class check-in is also a separate course requirement. Team membership and individual responsibilities should be updated to match the actual group; no second coder is claimed.

## Data sources and attribution

GitSkills creators: Giuseppe Destefanis, Daniel Graziotin, Matteo Vaccargiu and Marco Ortu.

- Paper: https://arxiv.org/html/2608.10906v3
- Sample and field dictionary: https://github.com/giuseppedestefanis/gitskills-sample/tree/fff3df93beeee51a5444450891751f143e38da3e
- Full release, version 1.0.0: https://zenodo.org/records/21875637
- Parquet mirror and license information: https://huggingface.co/datasets/mvaccargiu/gitskills
- MSR challenge: https://conf.researchr.org/track/msr-2027/msr-2027-mining-challenge

The dataset card releases collected metadata and aggregation under CC BY 4.0. Reproduced file contents retain their origin licenses. The raw database, ZIP and skill text are not committed here. Missing repository licenses do not establish permission to redistribute file contents.

## Preparation disclosure

AI assistance was used for source retrieval, analysis execution and report preparation. The observed audit outputs were produced by the included code. Semantic labels and final research findings are not represented as completed work.
