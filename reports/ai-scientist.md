# AI-Scientist (SakanaAI)
> The first comprehensive framework for fully automated, open-ended scientific discovery using large language models.

---

## 📌 Project Overview

**AI-Scientist** is a groundbreaking open-source system developed by SakanaAI that aims to automate the entire lifecycle of machine learning research — from ideation through experimentation to peer-reviewed manuscript generation. Published in 2024 by Lu et al. under the paper title *"The AI Scientist: Towards Fully Automated Open-Ended Scientific Discovery"*, the system demonstrated for the first time that an LLM-based agent could autonomously produce research papers that, in some cases, passed automated peer review at a level comparable to submissions at competitive ML workshops.

Unlike prior systems that automate isolated steps of the research pipeline (e.g., code generation or literature search), AI-Scientist integrates all stages into a single, coherent end-to-end workflow:

1. **Idea Generation** — Brainstorming novel research directions grounded in seed papers
2. **Experiment Implementation** — Automated coding and debugging of experiments
3. **Experiment Execution** — Running experiments via subprocess with result capture
4. **Scientific Manuscript Writing** — LaTeX-based paper generation with figures and tables
5. **Automated Peer Review** — LLM-as-reviewer scoring the generated paper

The system targets narrow but well-defined ML research areas using pre-built experimental templates (e.g., NanoGPT language modeling, 2D diffusion, grokking), ensuring that experiments are reproducible and runnable within reasonable compute budgets. The cost per generated paper is approximately **$15 USD** when using Claude Sonnet 3.5, making it economically competitive with human research assistants for early-stage exploration.

**Repository:** [https://github.com/SakanaAI/AI-Scientist](https://github.com/SakanaAI/AI-Scientist)  
**Paper:** arXiv:2408.06292 (Lu et al., 2024)  
**Language:** Python  
**License:** Apache 2.0  

---

## 🎯 Project Positioning

AI-Scientist positions itself at the frontier of **autonomous scientific intelligence** — an emerging subfield combining AI agents, LLM reasoning, and automated experimentation. Its primary research question is: *Can an LLM autonomously generate, test, and communicate novel scientific ideas?*

### Target Audience

- **AI researchers** studying the limits of LLM reasoning and autonomy
- **Research institutions** exploring tools to scale literature-to-experiment pipelines
- **Automation researchers** interested in multi-agent systems for knowledge production

### Research Context

The project emerged from a broader trend of applying LLMs to scientific reasoning tasks, including AlphaCode (code generation), ChemCrow (chemistry), and Eureka (RL reward design). AI-Scientist is distinct in its ambition: it does not assist a human researcher — it *replaces* the researcher role for a complete paper cycle.

It directly addresses the bottleneck in scientific production: human time is expensive, experiments are slow, and the gap between idea generation and publication is long. By automating the loop, AI-Scientist hypothesizes that the velocity of scientific exploration can be dramatically increased.

### Comparison to Human Workflow

| Stage | Human Researcher | AI-Scientist |
|---|---|---|
| Idea Generation | Days–Weeks | Minutes (LLM brainstorm) |
| Literature Check | Hours | API query (Semantic Scholar) |
| Coding Experiment | Days | Hours (LLM + aider loop) |
| Running Experiment | Hours–Days | Hours (subprocess) |
| Writing Paper | Weeks | Hours (LLM templated) |
| Peer Review | Months | Minutes (LLM reviewer) |
| Total Cost | $10k–$100k+ | ~$15 |

This positioning makes AI-Scientist particularly impactful for **early-stage hypothesis exploration** — not replacing thorough human peer review, but dramatically accelerating the initial research cycle.

---

## 🏗️ System Architecture

AI-Scientist follows a **linear sequential pipeline** organized into four major phases, with each phase producing structured artifacts consumed by the next.

```
┌────────────────────────────────────────────────────────────────────────┐
│                         AI-SCIENTIST PIPELINE                          │
│                                                                        │
│  ┌──────────────┐   ┌─────────────────┐   ┌─────────────────────────┐ │
│  │  Idea Pool   │──▶│ Idea Generation │──▶│  Novelty Checking       │ │
│  │ (Seed Ideas) │   │  (LLM Few-Shot) │   │ (Semantic Scholar API)  │ │
│  └──────────────┘   └─────────────────┘   └────────────┬────────────┘ │
│                                                         │              │
│                                                         ▼              │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │             Experiment Implementation & Execution               │   │
│  │  ┌──────────────┐   ┌────────────────┐   ┌──────────────────┐ │   │
│  │  │ Code Template│──▶│ LLM Code Edit  │──▶│  subprocess Run  │ │   │
│  │  │ (per topic)  │   │  (aider loop)  │   │  (Python scripts)│ │   │
│  │  └──────────────┘   └────────────────┘   └────────┬─────────┘ │   │
│  │                              ▲                     │           │   │
│  │                              └─────────────────────┘           │   │
│  │                           (iterate on errors / results)        │   │
│  └────────────────────────────────────────────────────────────────┘   │
│                                                         │              │
│                                                         ▼              │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │              LaTeX Paper Writing                                │   │
│  │  ┌─────────────────┐   ┌──────────────┐   ┌────────────────┐  │   │
│  │  │ LaTeX Template  │──▶│ LLM Section  │──▶│ pdflatex Compile│  │   │
│  │  │ (per topic)     │   │ Generation   │   │ (PDF output)   │  │   │
│  │  └─────────────────┘   └──────────────┘   └────────────────┘  │   │
│  └────────────────────────────────────────────────────────────────┘   │
│                                                         │              │
│                                                         ▼              │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │              Automated Peer Review                              │   │
│  │  ┌──────────────┐   ┌───────────────┐   ┌──────────────────┐  │   │
│  │  │ Paper (PDF)  │──▶│ LLM Reviewer  │──▶│ JSON Score Sheet │  │   │
│  │  └──────────────┘   └───────────────┘   └──────────────────┘  │   │
│  └────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────┘
```

### Key Architectural Decisions

- **Modularity by template:** Each research domain (NanoGPT, diffusion, grokking) has its own folder with a Python experiment script template and a LaTeX paper template. This scopes the LLM's search space and dramatically reduces hallucination risk.
- **Subprocess isolation:** Experiments run as separate OS processes, allowing timeout enforcement and result capture without crashing the orchestrating agent.
- **LLM orchestration via Python:** The entire pipeline is driven by Python scripts that construct prompts, call LLM APIs, parse JSON responses, and invoke shell commands.
- **Stateless between phases:** Each phase reads from disk (JSON files, Python scripts, figures), enabling re-entry at any phase without rerunning earlier phases.

---

## ⚙️ Core Components & Workflow

### 1. Idea Generation

The idea generation phase leverages **few-shot prompting** with a curated set of seed ideas stored as JSON files. Each seed idea is a structured object with fields:

```json
{
  "Name": "adaptive_learning_rate",
  "Title": "Adaptive Learning Rate Scheduling for NanoGPT",
  "Experiment": "Modify the training loop to use cosine annealing with warm restarts...",
  "Interestingness": 8,
  "Feasibility": 9,
  "Novelty": 7
}
```

The LLM is prompted with several existing seed ideas and asked to brainstorm new ideas in the same format. The prompt explicitly instructs the model to:

- Target ideas that are **different** from existing seeds
- Estimate interestingness, feasibility, and novelty
- Describe a concrete experimental protocol
- Fit within the constraints of the template codebase

After generation, each candidate idea is checked for novelty against the scientific literature using the **Semantic Scholar API**. The system queries for papers whose titles/abstracts semantically overlap with the candidate idea's title and description. Ideas with high overlap with existing work are filtered out or flagged.

### 2. Experiment Implementation (The aider Loop)

The core innovation of AI-Scientist is the **automated coding loop**. Given an idea and an experiment template (a Python script), the system uses **aider** — an open-source LLM-based code editing tool — to implement the idea.

The loop proceeds as follows:

```
1. Construct prompt: idea description + current experiment.py
2. Call aider (which internally calls LLM API)
3. aider produces git diffs / file edits
4. Run experiment.py via subprocess with timeout
5. Capture stdout/stderr and results JSON
6. If error: feed error back to aider, repeat
7. If success: proceed to paper writing
```

The LLM is instructed to edit the experiment script to implement the idea while preserving the results-logging interface (a standardized JSON output format). This standardization is critical — it allows downstream paper writing to parse results automatically.

A **maximum number of iterations** (typically 3–5) is enforced. If the experiment cannot be debugged within that budget, the idea is abandoned.

### 3. LaTeX Paper Writing

Once experiments produce results (figures in PNG/PDF, metrics in JSON), the paper writing phase begins. Each template includes a skeleton LaTeX file with section markers. The LLM is prompted section-by-section:

- **Abstract** — concise summary with key numerical results
- **Introduction** — motivation and contribution
- **Background / Related Work** — relevant prior work (LLM-generated citations)
- **Method** — description of the implemented approach
- **Experiments** — results tables and figures, discussion of findings
- **Conclusion** — summary and future work

Figures are included via `\includegraphics` commands. The system calls `pdflatex` to compile the document, checks for compilation errors, and feeds them back to the LLM for correction if needed.

A known weakness here is **hallucinated citations** — the LLM generates plausible-looking BibTeX entries that may not correspond to real papers. Mitigation is partial: the system attempts to check key citations against Semantic Scholar, but full verification is not implemented.

### 4. Automated Peer Review

The reviewer module loads the generated PDF (converted to text) and constructs a structured review prompt asking the LLM to score the paper on:

| Criterion | Scale |
|---|---|
| Originality | 1–10 |
| Technical Quality | 1–10 |
| Clarity | 1–10 |
| Significance | 1–10 |
| Overall Score | 1–10 |
| Confidence | 1–5 |

The reviewer prompt also asks for detailed written feedback: summary, strengths, weaknesses, and recommendations. The output is a JSON object that mirrors the structure of NeurIPS/ICLR paper review forms.

Critically, this reviewer can be run on both human-authored and AI-authored papers, enabling **calibration** — authors of AI-Scientist showed that the LLM reviewer scores correlate meaningfully with human reviewer scores when tested on a subset of ICLR papers.

---

## 🔧 Technical Details

### Supported LLMs

| Provider | Models |
|---|---|
| OpenAI | GPT-4o, GPT-4-turbo |
| Anthropic | Claude 3 Sonnet, Claude 3 Opus, Claude 3.5 Sonnet |
| DeepSeek | DeepSeek-Coder-V2, DeepSeek-V2 |
| Google | Gemini 1.5 Pro |

The LLM is specified via a command-line flag (`--model`). Different phases may use different models — e.g., a cheaper model for idea brainstorming and a more powerful one for paper writing.

### Research Templates

| Template | Description |
|---|---|
| `nanoGPT` | GPT-2 scale language modeling, custom training loops |
| `2d_diffusion` | 2D diffusion process modeling and visualization |
| `grokking` | Delayed generalization phenomenon in neural networks |

Each template folder contains:
- `experiment.py` — the runnable Python script
- `plot.py` — plotting utilities for figures
- `template/` — LaTeX skeleton with placeholders
- `ideas.json` — seed ideas for that topic

### Dependencies

```
aider-chat          # LLM code editing
anthropic           # Anthropic API client
openai              # OpenAI API client
semantic-scholar    # Literature search
pdflatex            # LaTeX compilation (system dependency)
matplotlib          # Figure generation
torch               # PyTorch for ML experiments
```

### Execution Flow (CLI)

```bash
# Full pipeline for a single idea
python launch_scientist.py \
  --model claude-3-5-sonnet-20240620 \
  --experiment nanoGPT \
  --num-ideas 5

# Just run the reviewer on existing papers
python review_iclr_2024.py \
  --model gpt-4o \
  --paper path/to/paper.pdf
```

### Experiment Result Format

The `experiment.py` scripts output results in a standardized JSON format:

```json
{
  "means": {"train_loss": 2.31, "val_loss": 2.45},
  "stds":  {"train_loss": 0.02, "val_loss": 0.03},
  "final": {"best_val_loss": 2.38}
}
```

This schema is part of the "template contract" — experiments must conform to it for the paper-writing phase to parse results correctly.

---

## 📊 Performance & Benchmarks

### Cost Analysis

| LLM | Cost per Paper |
|---|---|
| Claude 3.5 Sonnet | ~$15 |
| GPT-4o | ~$25–40 |
| Claude 3 Opus | ~$50+ |
| DeepSeek-V2 | ~$3–5 |

The cost breakdown (approximate for Claude 3.5 Sonnet):
- Idea generation: ~$0.50
- Experiment coding (3–5 aider iterations): ~$5
- Paper writing (section by section): ~$7
- Automated review: ~$1.50
- Miscellaneous API calls: ~$1

### Automated Review Quality

In the original paper, the authors evaluated the LLM reviewer against 500 ICLR 2024 submissions with known human reviewer scores. Key findings:

- **Pearson correlation** between LLM and human overall scores: ~0.48
- **False positive rate** (LLM accepts papers humans reject): ~15%
- **False negative rate** (LLM rejects papers humans accept): ~22%

This suggests the LLM reviewer is a useful but noisy signal — appropriate for automated filtering but not as a replacement for human peer review.

### Paper Quality Assessment

Papers generated by AI-Scientist on the NanoGPT template were evaluated by human ML researchers. Observations:
- **Technical correctness:** ~70% of experimental claims were verifiable
- **Writing quality:** Generally readable; occasionally verbose or repetitive
- **Citation accuracy:** ~40% of citations were hallucinated or incorrect
- **Novelty of ideas:** ~30% were judged as containing a genuinely interesting insight

These numbers reflect the state of LLMs in 2024; improvements in Claude 3.5 Sonnet and GPT-4o have likely shifted these upward.

---

## ✅ Strengths

1. **End-to-End Automation:** AI-Scientist is the most complete publicly available pipeline for autonomous research. No other open-source system covers the full idea→experiment→paper→review loop.

2. **Cost Efficiency:** At ~$15/paper, the system enables high-throughput exploration of research ideas that would otherwise require significant human time investment.

3. **Reproducibility:** Using fixed experiment templates and deterministic subprocess execution, experiments can be reproduced exactly from the generated code.

4. **Extensibility:** Adding a new research domain requires only a new experiment template and LaTeX skeleton — the orchestration pipeline remains unchanged.

5. **Calibrated Reviewer:** The automated reviewer provides structured, actionable feedback that mirrors real conference review forms, enabling filtering of low-quality outputs.

6. **Open Source:** Full codebase, templates, and seed ideas are publicly available, enabling community extensions and improvements.

7. **Multi-LLM Support:** Supporting multiple frontier LLMs enables cost/quality tradeoffs and reduces dependency on any single provider.

8. **Aider Integration:** Using `aider` as the code-editing backend benefits from that project's ongoing improvements and its ability to handle multi-file edits, git integration, and error recovery.

---

## ⚠️ Limitations

1. **Domain Narrowness:** The system only works within pre-defined template domains. Generalizing to biology, chemistry, or social science requires substantial new template engineering.

2. **Citation Hallucination:** The paper writing phase frequently generates plausible but non-existent citations. This is a significant reliability concern and limits use in real academic contexts.

3. **No Internet Access During Experiment:** Unlike humans, the system cannot search for implementation details or debugging tips during the coding loop. It relies entirely on the LLM's parametric knowledge.

4. **Safety Concerns:** Allowing an autonomous agent to write and execute arbitrary Python code raises security concerns. The system runs code with the same privileges as the host process — a significant risk if deployed in production environments.

5. **Limited Novelty Depth:** Generated ideas tend to be shallow recombinations of existing concepts rather than genuinely paradigm-shifting insights. The few-shot seed-based generation is bounded by what already exists in the seed pool.

6. **Compilation Fragility:** LaTeX compilation can fail on complex figures or unusual formatting, and the error-recovery loop is imperfect, sometimes producing incomplete or malformatted PDFs.

7. **Experimental Scope:** Experiments are constrained to fit within template scripts that complete within minutes–hours. Long-running experiments (multi-day GPU training) are not supported.

8. **Evaluation Circularity:** Reviewing AI-generated papers with AI reviewers creates a feedback loop that may reward papers optimized for LLM reviewers rather than genuine scientific quality.

9. **No Iterative Refinement Based on Review:** The v1 pipeline does not loop the reviewer's feedback back into paper revision — papers are generated once and reviewed once.

---

## 🔗 Related Work

| Project | Relationship |
|---|---|
| **AI-Scientist-v2** (SakanaAI) | Direct successor; adds BFTS tree search and AIDE integration |
| **AIDE** (WecoAI) | ML experiment coding agent used in v2 |
| **Agent Laboratory** (Schmidgall) | Similar pipeline; specializes agents for each role |
| **AI-Researcher** (HKUDS) | Extends to full literature survey and algorithm design stages |
| **Eureka** (NVIDIA) | LLM-designed RL reward functions; narrower but similar philosophy |
| **ChemCrow** (Bran et al.) | LLM agent for chemistry research; domain-specialized |
| **AlphaCode** (DeepMind) | LLM code generation; inspires experiment coding component |
| **Semantic Scholar API** | Used for novelty checking in idea generation |
| **aider** (Paul Gauthier) | Core code editing backend for experiment implementation |
| **ResearchAgent** (Baek et al.) | Concurrent work on LLM-based research automation |

---

## 📎 References

1. Lu, C., Lu, C., Lange, R. T., Foerster, J., Clune, J., & Ha, D. (2024). *The AI Scientist: Towards Fully Automated Open-Ended Scientific Discovery*. arXiv:2408.06292.

2. SakanaAI. (2024). *AI-Scientist GitHub Repository*. [https://github.com/SakanaAI/AI-Scientist](https://github.com/SakanaAI/AI-Scientist)

3. Gauthier, P. (2023). *aider: AI pair programming in your terminal*. [https://aither.chat](https://aider.chat)

4. Lo, K., Wang, L. L., Neumann, M., Kinney, R., & Weld, D. S. (2020). *S2ORC: The Semantic Scholar Open Research Corpus*. ACL 2020.

5. Karpathy, A. (2022). *nanoGPT: The simplest, fastest repository for training/finetuning medium-sized GPTs*. [https://github.com/karpathy/nanoGPT](https://github.com/karpathy/nanoGPT)

6. Power, A., Burda, Y., Edwards, H., Goodfellow, I., & Misra, V. (2022). *Grokking: Generalization Beyond Overfitting on Small Algorithmic Datasets*. arXiv:2201.02177.

7. Ho, J., Jain, A., & Abbeel, P. (2020). *Denoising Diffusion Probabilistic Models*. NeurIPS 2020.

8. Ma, Y., Liu, P., & Neubig, G. (2023). *LLM-based Scientific Paper Review: A Survey*. arXiv preprint.

9. Boiko, D. A., MacKnight, R., & Gomes, G. (2023). *Emergent autonomous scientific research capabilities of large language models*. arXiv:2304.05332.

10. Wang, L., Ma, C., Feng, X., Zhang, Z., Yang, H., Zhang, J., ... & Wen, J. R. (2024). *A Survey on Large Language Model based Autonomous Agents*. Frontiers of Computer Science.
