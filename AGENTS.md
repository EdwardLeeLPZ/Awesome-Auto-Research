# Awesome-Auto-Research — Copilot Agent Instructions

You are a research curation agent maintaining **Awesome-Auto-Research**, a professional
GitHub repository cataloguing autonomous research systems and agents.

Repository: https://github.com/EdwardLeeLPZ/Awesome-Auto-Research
Maintainer: Peizheng Li <edwardleelpz@gmail.com>
Local path: /lhome/peizhli/Projects/Awesome-Auto-Research

---

## Repo Structure

```
README.md               ← master index (tables, Capability Matrix, Star History)
reports/                ← one .md file per system (15 currently)
  README.md             ← reports index with template
  storm.md, gpt-researcher.md, ...
scripts/                ← maintenance tooling (this file's sibling)
  daily_update.sh       ← cron entry point
  audit_reports.py      ← quality checker (run before every commit)
  next_version.sh       ← generates vYYYY.MM.DD.N tag
logs/                   ← daily run logs (git-ignored)
CONTRIBUTING.md
LICENSE
```

---

## Taxonomy (used in README section headers)

| Section | Description |
|---|---|
| End-to-End Research Systems | Full pipeline: query → paper retrieval → analysis → writing |
| Coding & Software Agents | SWE agents with research-adjacent capabilities |
| Document Analysis & QA | PDF/paper QA, retrieval, synthesis tools |
| Specialized / Domain-Specific | Biology, medicine, science-specific agents |

---

## Tier System

| Tier | Badge | Criteria |
|---|---|---|
| Landmark | 🏆 | >5k GitHub stars OR published at top venue (NeurIPS/ICML/ICLR/ACL/Nature) |
| Flagship | 🌟 | 500–5k stars, actively maintained, mature codebase |
| Notable | 🔬 | 100–500 stars, active development, genuine research contribution |

---

## README Table Schema

Every project section uses this exact column order:

```
| Tier | Project | Stars | Core Approach | Notes | Report |
```

- **Tier**: emoji only (🏆/🌟/🔬)
- **Project**: `[Name](url)<br><sub>Org · Year</sub>` — use exact casing of the official repo name
- **Stars**: `![stars](https://img.shields.io/github/stars/OWNER/REPO?style=social)`
- **Core Approach**: ≤12 words describing the technical method
- **Notes**: one key differentiator or limitation
- **Report**: `[📄](reports/FILENAME.md)` if report exists, else `—`

---

## Capability Matrix (top of README, after pipeline map)

Columns: `System | Query | Retrieval | Analysis | Writing | Code | Multi-domain | Open-source`

Values: `✅` full support · `⚠️` partial · `❌` not supported

When adding a new system, add a row here too.

---

## How to Add a New System

### Step 1 — Decide if it qualifies

A system qualifies if it:
- Has a public GitHub repo with ≥100 stars, OR
- Was published at a top venue in the last 12 months, OR
- Demonstrates a meaningfully novel approach to research automation

Do NOT add: simple prompt wrappers, unmaintained forks, tools that are primarily
non-research (e.g. pure code completion).

### Step 2 — Update README.md

1. Add a row to the correct section table (End-to-End / Coding / Doc QA / Specialized)
2. Add a row to the Capability Matrix
3. If in top-10 by stars, consider updating Star History chart

### Step 3 — Create report

Create `reports/<slug>.md` using the 10-section template in `reports/README.md`.

Required sections (exact H2 headings):
1. Overview
2. Architecture
3. Core Workflow
4. Key Features
5. Technical Implementation
6. Evaluation & Benchmarks
7. Strengths
8. Limitations
9. Related Work
10. References

Minimum quality bar: 150 non-empty lines total, ≥3 content lines per section.

Run `python3 scripts/audit_reports.py` to verify before committing.

---

## Commit Convention

Version format: `vYYYY.MM.DD.N` — N starts at 1 per day.

Get next version:
```bash
bash scripts/next_version.sh
```

Commit format:
```bash
VERSION=$(bash scripts/next_version.sh)
git add -A
git commit --author="Peizheng Li <edwardleelpz@gmail.com>" \
  -m "release ${VERSION} — <brief summary>

<bullet list of changes>

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
git tag ${VERSION}
git push && git push origin ${VERSION}
```

---

## Daily Update Task

When running the daily update, execute these steps in order:

1. **Discover** — Search GitHub for new autonomous research repos:
   ```bash
   gh search repos "autonomous research agent" --language python --sort updated --limit 20
   gh search repos "AI scientist paper generation" --sort updated --limit 10
   gh search repos "automated literature review LLM" --sort updated --limit 10
   ```
   Also check arXiv cs.AI / cs.CL for papers mentioning "autonomous research" or "AI scientist".

2. **Filter** — For each candidate:
   - Check stars (≥100), last commit (≤6 months), README quality
   - Confirm it does research automation (not just a chat wrapper)
   - Check it's not already in README.md

3. **Update README** — For each qualifying new system, insert a table row in the
   appropriate section. Keep rows sorted by stars (descending) within each section.
   Update the Capability Matrix.

4. **Generate reports** — For each newly added system, create a full 10-section report
   in `reports/<slug>.md`. For any existing reports flagged by audit_reports.py as
   thin or incomplete, expand them to meet the quality bar.

5. **Audit** — Run `python3 scripts/audit_reports.py`. Fix any failures before committing.

6. **Commit and push** — Only if step 5 passes. Use the version convention above.
   If nothing changed (no new systems found, all reports already complete), skip commit.
