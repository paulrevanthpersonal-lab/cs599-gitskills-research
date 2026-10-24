# CS 599 MSR research checkpoint

**Project:** Verification Guidance and Reuse in GitSkills

**Student:** Paul Revanth Madasu

**Instructor:** Professor Igor Steinmacher

**Public repository:** https://github.com/paulrevanthpersonal-lab/cs599-gitskills-research

## Start here

Read the [checkpoint report PDF](docs/checkpoint-1.pdf) or edit the [Word version](docs/checkpoint-1-apa.docx). The paragraph source is [paper/checkpoint-1.md](paper/checkpoint-1.md). This is the **dataset-understanding and study-design checkpoint**, not a completed final paper.

The audit is complete. Instructor approval of the documented sample, human annotation, research-question comparisons, actual peer feedback and the in-class check-in remain outstanding. [STATUS.md](STATUS.md) records these distinctions. Do not treat blank coding forms or planned procedures as findings.

Use the fixed **checkpoint-1-v1** tag for this package: https://github.com/paulrevanthpersonal-lab/cs599-gitskills-research/tree/checkpoint-1-v1

## Questions and scope

The first question compares actionable verification guidance between single-occurrence, same-owner repeated and cross-owner contents. The second checks whether local files explicitly referenced by verification steps are present in the representative folder's complete inventory. The unit is one distinct content group (`file_sha`); folder facts apply only to the selected occurrence (`dedup_primary = 1`). Static presence is not invocation or effectiveness.

The proposed population is the public GitSkills sample. The module requires instructor approval for a documented subset; that approval has not been recorded. The sample audit demonstrates feasibility and does not assert approval. Zenoh contribution work is a separate project.

## Reproduce the completed audit

The audit uses **Python 3.10+ and only its standard library**. The recorded run used Python 3.12.14 and SQLite 3.53.1. No dataset commands or scripts are executed. Database access is read-only.

From a clean repository checkout, download the pinned ZIP (about 83 MB), extract it (about 291 MB) and verify the database identity:

```sh
mkdir -p data
curl -L --fail 'https://raw.githubusercontent.com/giuseppedestefanis/gitskills-sample/fff3df93beeee51a5444450891751f143e38da3e/agent_skills_sample.zip' -o data/agent_skills_sample.zip
unzip data/agent_skills_sample.zip -d data
python3 -c "import hashlib; print(hashlib.sha256(open('data/agent_skills_sample.db','rb').read()).hexdigest())"
```

Expected database SHA-256:

```text
683888c923a51952fb66f83f21351ed5bf1127ddddf380e517592ae27c367658
```

Run the analysis from the repository root, using a fresh output directory:

```sh
python3 run_checks.py data/agent_skills_sample.db --out rerun-results
```

Expected observations include 29,786 artifact rows, 13,000 content groups, 11,841 repositories, integrity result `ok`, zero mismatches among 13,000 independent representative hash checks, and 11,192 eligible groups. `results/observed_results.json` contains the full audit; `results/study_summary.json` contains the eligibility summary. Compare outputs with the committed evidence. Runtime version fields may differ on another installation; population and audit results should not. Do not overwrite completed human labels with a fresh blank form.

Optional SQLite CLI demonstration:

```sh
sqlite3 -readonly data/agent_skills_sample.db < examples.sql
```

`examples.sql` reports the artifact count, zero groups violating representative uniqueness, and counts by location. Complete quality checks are in `checks.sql`; eligibility extraction is in `study.sql`. `results/schema.sql` is the actual database DDL.

## Sampling and annotation materials

The executed sampling frame selects 80 units from each of three strata using SHA-256 of `cs599-label-v1:` plus `file_sha`. The frame has 8,265 single-occurrence groups, 693 same-owner repeated groups and 2,234 cross-owner groups. It selects 240 units; **all semantic labels are blank**.

Use [sampling/annotation-blind.csv](sampling/annotation-blind.csv) for coding without reuse strata, reach counts or stars. Keep the stratum key in `results/label_sample_uncompleted.csv` separate during coding. [docs/codebook.txt](docs/codebook.txt) describes V0-V3, local-reference checks, pilot selection and delayed recoding. Human validation and research-question comparisons have not been executed.

## Build the editable checkpoint

The audit does not require document packages. To rebuild the Word report, optionally install its separate dependencies in a local virtual environment:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r paper/requirements-docs.txt
.venv/bin/python paper/build_checkpoint.py --output docs/checkpoint-1-apa.docx
```

Open the DOCX in Word or LibreOffice and export it as PDF. If LibreOffice is installed for local command-line conversion:

```sh
libreoffice --headless --convert-to pdf --outdir build docs/checkpoint-1-apa.docx
```

The exported PDF is named `checkpoint-1-apa.pdf`; the published report copy is `docs/checkpoint-1.pdf`. Exact pagination can vary with fonts and office software. The source uses paragraphs, bold APA-style headings, double spacing and author-date citations. It omits the title-page date and late-submission label as requested. The final paper must instead follow the [anonymous IEEE 4+1-page requirements](paper/FINAL_PAPER_REQUIREMENTS.md); the checkpoint is not that final manuscript.

## Progress and review workflow

Keep dated evidence, obstacles and next steps in [ACTIVITY_LOG.md](ACTIVITY_LOG.md). Record actual student contributions separately from AI-assisted preparation. Do not backfill unperformed work or hours.

Create a branch for each substantial revision, commit the work, open a pull request describing the change and validation, and record review and responses there. The clean checkpoint rebuild follows that workflow. Earlier direct commits remain visible and are not retrospectively described as reviewed. An agent-assisted verification or maintainer self-check does not satisfy the assignment's review by another group.

Ask real peer reviewers to follow [reviews/reproduction-guide.md](reviews/reproduction-guide.md). Preserve their actual observations and document each response. [reviews/status.md](reviews/status.md) currently records that no such feedback has been received.

## Remaining milestones

Before November 3: obtain sample approval, request peer reproduction, pilot the codebook and report actual annotation progress. During November: complete and validate coding, comparisons and sensitivity analyses. Prepare the December 3 presentation and December 9 paper and replication package. Final Canvas materials also require slides, peer reviews/responses, an activity log and a contribution statement. Conference submission is optional; completion of course deliverables is required.

## Data provenance and rights

GitSkills creators are Giuseppe Destefanis, Daniel Graziotin, Matteo Vaccargiu and Marco Ortu. The analyzed sample is pinned to revision `fff3df93beeee51a5444450891751f143e38da3e`. Full release version 1.0.0 is archived at DOI 10.5281/zenodo.21875637, but the full release was not queried.

- Paper: https://arxiv.org/html/2608.10906v3
- Sample and dictionary: https://github.com/giuseppedestefanis/gitskills-sample/tree/fff3df93beeee51a5444450891751f143e38da3e
- Full archive: https://zenodo.org/records/21875637
- Parquet mirror and license conditions: https://huggingface.co/datasets/mvaccargiu/gitskills
- Challenge call: https://conf.researchr.org/track/msr-2027/msr-2027-mining-challenge

Collected metadata/aggregation are CC BY 4.0; reproduced file contents retain origin licenses. The database and raw skill text are not committed. The runner's generated group-features file may contain parsed descriptions; inspect licenses before redistributing it. No personally identifying enrichment is performed. AI assistance was used for extraction, verification and document preparation, and no AI-generated labels are claimed as human judgments.
