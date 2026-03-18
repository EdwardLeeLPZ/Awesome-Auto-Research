# AI-Scientist-v2 (SakanaAI)
> The upgraded autonomous research system that generated the first AI-authored paper accepted at a peer-reviewed academic workshop, powered by beam-search-guided agentic tree search.

---

## 📌 Project Overview

**AI-Scientist-v2** is the second-generation autonomous research framework from SakanaAI, building directly upon the foundations laid by AI-Scientist v1 (Lu et al., 2024). The primary architectural advancement is the introduction of **BFTS (Beam-search-like agentic Tree Search)** for experiment planning and execution — a departure from v1's strictly linear pipeline toward a tree-structured exploration of experimental directions.

The most notable milestone achieved by AI-Scientist-v2 is the **generation of the first AI-authored paper accepted through peer review at an academic workshop** — specifically, a paper on *"Adaptive Dual-Scale Denoising"* accepted at an ICLR 2025 workshop. This represents a qualitative leap: not simply generating papers that look plausible to automated reviewers, but producing work that convinces human subject-matter experts in a competitive review process.

Additional improvements over v1 include:
- Integration of **AIDE (Agentic Iterative Design for Experiments)** by WecoAI for the experiment coding phase
- **Docker-based sandboxing** for safer code execution
- More robust experiment tracking and result logging
- Improved paper coherence and reduced hallucination rates
- More modular, extensible codebase
- Broader LLM provider support (AWS Bedrock, Gemini, native OpenAI, native Anthropic)

**Repository:** [https://github.com/SakanaAI/AI-Scientist-v2](https://github.com/SakanaAI/AI-Scientist-v2)  
**Predecessor:** AI-Scientist v1 (arXiv:2408.06292)  
**Language:** Python  
**License:** Apache 2.0  

---

## 🎯 Project Positioning

AI-Scientist-v2 positions itself as a **production-grade research automation framework** capable of generating not just plausible-looking papers but peer-review-passing research contributions. Its competitive positioning can be summarized along three dimensions:

### 1. Versus AI-Scientist v1

Where v1 demonstrated *feasibility* of end-to-end paper generation, v2 demonstrates *quality* sufficient for actual academic acceptance. The core upgrade — BFTS — addresses v1's fundamental limitation: a fixed, linear sequence of steps that committed early to a single experimental direction with no ability to backtrack or explore alternatives.

### 2. Versus Other Autonomous Research Systems

| System | Search Strategy | Accepted Paper? | Safety |
|---|---|---|---|
| AI-Scientist v1 | Linear pipeline | No | Subprocess only |
| **AI-Scientist v2** | **Tree search (BFTS)** | **Yes (ICLR workshop)** | **Docker** |
| Agent Laboratory | Multi-agent linear | No | Limited |
| AI-Researcher | Linear with loops | No | Docker |
| AIDE (standalone) | Greedy hill-climbing | N/A (no paper writing) | Subprocess |

### 3. Research Philosophy

v2 embraces the principle that **exploration is more important than exploitation** in early research. By maintaining a beam of diverse experimental hypotheses and evaluating each before committing, the system can discover non-obvious research directions that a greedy strategy would miss. This mirrors how human researchers often pursue parallel experimental tracks before converging on the most promising result.

---

## 🏗️ System Architecture

The v2 architecture centers on the BFTS module, which replaces v1's linear "implement → run → write" sequence with a tree-structured search process.

```
┌──────────────────────────────────────────────────────────────────────────┐
│                       AI-SCIENTIST-V2 ARCHITECTURE                       │
│                                                                          │
│  ┌──────────────┐    ┌─────────────────────────────────────────────────┐ │
│  │ Idea Pool    │───▶│            BFTS: Beam Tree Search               │ │
│  │ (Seeds/LLM) │    │                                                  │ │
│  └──────────────┘    │   Root Node (initial hypothesis)                │ │
│                      │        │                                         │ │
│                      │   ┌────┴────┬────────┬────────┐                 │ │
│                      │   ▼         ▼        ▼        ▼                 │ │
│                      │ Branch1  Branch2  Branch3  Branch4              │ │
│                      │   │         │        │        │                 │ │
│                      │ (eval)   (eval)   (eval)   (pruned)            │ │
│                      │   │         │                                   │ │
│                      │ (keep)   (keep)    ← Beam of width W           │ │
│                      │   │         │                                   │ │
│                      │ Sub-branches at next level...                  │ │
│                      └─────────────────────────────────────────────────┘ │
│                                          │                               │
│                                          ▼                               │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │              AIDE: Iterative Experiment Implementation            │   │
│  │  ┌──────────────┐   ┌──────────────┐   ┌──────────────────────┐ │   │
│  │  │  Plan Node   │──▶│  Code Draft  │──▶│  Execute & Evaluate  │ │   │
│  │  │  (from BFTS) │   │  (LLM edit)  │   │  (Docker sandbox)    │ │   │
│  │  └──────────────┘   └──────────────┘   └──────────┬───────────┘ │   │
│  │                            ▲                       │             │   │
│  │                            └───────────────────────┘             │   │
│  │                         (iterate until passing)                  │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                          │                               │
│                                          ▼                               │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │              Paper Writing & Review                               │   │
│  │  LaTeX generation → pdflatex → LLM reviewer → JSON score        │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────┘
```

### Architectural Innovations Over v1

1. **Non-linear experiment planning:** BFTS allows the system to explore multiple experimental variants in parallel and select the most promising.
2. **AIDE replaces raw aider:** AIDE's structured experiment management replaces the more ad-hoc aider loop, providing better code organization and error recovery.
3. **Docker isolation:** Each experiment node in the tree runs in an isolated Docker container, preventing side effects between branches.
4. **Result-aware branching:** Branch expansion decisions are informed by quantitative results (validation metrics, loss curves) from completed experiments.

---

## ⚙️ Core Components & Workflow

### Component 1: BFTS — Beam-search-like Agentic Tree Search

BFTS is the architectural centerpiece of v2. It implements a **heuristic beam search over the space of experimental designs**, treating each candidate experimental configuration as a node in a tree.

#### Tree Structure

- **Root node:** The initial research hypothesis as proposed by the idea generation phase
- **Internal nodes:** Refined or modified experimental designs (e.g., changed hyperparameters, alternative model architectures, different datasets)
- **Leaf nodes:** Fully executed experiments with quantitative results
- **Branching:** At each node, the LLM generates `B` (beam width) candidate modifications
- **Pruning:** After evaluating each child node, only the top-`K` nodes (by validation metric) are expanded further

#### Key Parameters

| Parameter | Description | Typical Value |
|---|---|---|
| Beam width (W) | Number of parallel branches to maintain | 3–5 |
| Max depth (D) | Maximum number of search tree levels | 3–4 |
| Branching factor (B) | Number of children generated per node | 3–4 |
| Evaluation metric | Criterion for ranking branches | Task-specific (val loss, accuracy) |

#### LLM's Role in BFTS

At each expansion step, the LLM is given:
- The current node's experimental plan and results
- The full search history (sibling branches and their outcomes)
- The original research hypothesis

It is asked to generate `B` distinct directions to explore next, each formulated as a concrete experimental modification. This keeps the search **hypothesis-aware** — branches that better test the core idea are preferred over branches that merely optimize performance.

### Component 2: AIDE — Agentic Iterative Design for Experiments

AIDE (developed by WecoAI) is an open-source ML experiment coding agent designed to iteratively improve code quality. In v2, AIDE handles the implementation and debugging of experiments within each BFTS node.

#### AIDE's Internal Loop

```
1. Receive experiment specification (from BFTS node)
2. Generate complete experiment script (LLM)
3. Execute script in sandbox environment
4. Parse output: success metrics + error messages
5. If error: diagnose and patch code (LLM)
6. If result below threshold: propose improvement (LLM)
7. Repeat steps 3–6 up to MAX_ITERATIONS
8. Return: best code version + results
```

Key differences from v1's aider approach:

| Aspect | v1 (aider) | v2 (AIDE) |
|---|---|---|
| Code editing style | Git diff patches | Full file rewrites |
| Error handling | Feed raw stderr back | Structured diagnosis |
| Iteration tracking | Implicit | Explicit result history |
| Integration | CLI subprocess | Python API |
| Context management | File-level | Function-level granularity |

### Component 3: Docker Sandboxing

Each BFTS node's experiment runs inside a Docker container with:

- Pre-installed ML dependencies (PyTorch, NumPy, scikit-learn, etc.)
- Resource limits (CPU, RAM, GPU if available)
- Volume mounts for shared results directory
- Network isolation (no internet access during execution)
- Automatic container cleanup after completion

This addresses v1's primary safety concern: arbitrary code execution in the host environment. Docker isolation means a buggy or malicious experiment cannot damage the host system or access sensitive files.

### Component 4: Improved Paper Writing

The paper writing phase in v2 benefits from the richer experimental data produced by BFTS:

- Multiple experimental comparisons (ablations emerge naturally from tree branches)
- Cleaner results tables from structured AIDE outputs
- Better narrative: the tree search history provides a natural "we tried X, then Y, finding Z" story arc
- Improved citation grounding via enhanced Semantic Scholar integration

The paper for the accepted ICLR workshop submission (*"Adaptive Dual-Scale Denoising"*) was generated using this improved pipeline, incorporating ablation studies that arose from BFTS exploration of denoising scale parameters.

---

## 🔧 Technical Details

### Supported LLM Providers

| Provider | Access Method | Notes |
|---|---|---|
| OpenAI | Direct API | GPT-4o, o1-preview |
| Anthropic | Direct API | Claude 3.5 Sonnet, Claude 3 Opus |
| Anthropic | AWS Bedrock | Enterprise deployment |
| Google | Vertex AI | Gemini 1.5 Pro, Gemini 2.0 |

AWS Bedrock support is a significant addition for enterprise users who require data residency compliance or cannot use direct Anthropic/OpenAI APIs due to security policies.

### Docker Configuration

```yaml
# docker-compose configuration excerpt
services:
  experiment:
    image: ai-scientist-v2:latest
    runtime: nvidia  # Optional: GPU support
    mem_limit: "16g"
    cpus: "8"
    volumes:
      - ./workspace:/workspace
      - ./results:/results
    environment:
      - CUDA_VISIBLE_DEVICES=0
    network_mode: none  # No internet access
```

### Repository Structure

```
ai-scientist-v2/
├── ai_scientist/
│   ├── bfts/                    # Beam-search tree search module
│   │   ├── tree.py              # Tree data structure and expansion
│   │   ├── evaluator.py         # Result-based node scoring
│   │   └── pruner.py            # Beam pruning logic
│   ├── aide/                    # AIDE integration wrapper
│   │   ├── agent.py             # AIDE experiment agent
│   │   └── sandbox.py           # Docker execution interface
│   ├── paper_writing/           # LaTeX generation
│   ├── reviewer/                # Automated peer review
│   └── llm.py                   # Unified LLM API interface
├── templates/
│   ├── nanoGPT/
│   ├── diffusion/
│   └── grokking/
├── docker/
│   └── Dockerfile
└── launch_scientist_v2.py
```

### Key Configuration Parameters

```python
# BFTS Configuration
BFTS_CONFIG = {
    "beam_width": 4,
    "max_depth": 3,
    "branching_factor": 3,
    "evaluation_metric": "val_loss",  # or "accuracy", "f1"
    "pruning_strategy": "top_k",      # or "threshold"
    "max_total_experiments": 20,
}

# AIDE Configuration
AIDE_CONFIG = {
    "max_iterations": 10,
    "timeout_seconds": 3600,
    "error_diagnosis_model": "claude-3-5-sonnet",
    "improvement_threshold": 0.01,
}
```

---

## 📊 Performance & Benchmarks

### The Accepted Paper: Adaptive Dual-Scale Denoising

The landmark result of v2 is the generation and workshop acceptance of a paper on diffusion model denoising. Key details:

- **Venue:** ICLR 2025 Workshop (exact workshop not disclosed publicly)
- **Title:** "Adaptive Dual-Scale Denoising"
- **Core contribution:** A dual-scale noise estimation approach where the model simultaneously processes images at original and downsampled resolutions, adaptively combining predictions
- **How it emerged:** BFTS explored various modifications to the standard DDPM sampling process; the dual-scale branch outperformed alternatives and was selected for paper writing
- **Review outcome:** Accepted — the paper's ablation studies (naturally produced by BFTS) and clear experimental narrative convinced human reviewers

### Comparison: v1 vs v2

| Metric | AI-Scientist v1 | AI-Scientist v2 |
|---|---|---|
| Search strategy | Linear | BFTS (tree) |
| Experiment coding | aider | AIDE |
| Sandboxing | Subprocess only | Docker |
| AWS Bedrock support | No | Yes |
| Workshop acceptance | No | Yes (ICLR) |
| Citation accuracy | ~40% | ~60% (estimated) |
| Cost per paper | ~$15 | ~$30–50 (BFTS overhead) |
| Code modularity | Moderate | High |
| Ablations produced | Manual (1 run) | Automatic (from tree) |

### Cost Analysis for v2

BFTS significantly increases cost compared to v1 due to running multiple experiments:

| Phase | Approximate Cost |
|---|---|
| Idea generation | $0.50 |
| BFTS (20 experiment nodes) | $30–40 |
| Paper writing | $7–10 |
| Automated review | $1.50 |
| **Total** | **~$40–52** |

The increased cost is justified by higher output quality — particularly the natural production of ablation studies and comparative results that strengthen paper narratives.

---

## ✅ Strengths

1. **Peer-Review Validation:** The ICLR workshop acceptance is a concrete, externally validated signal that v2 can produce research of publishable quality — not just by automated standards, but by human expert judgment.

2. **Exploration vs. Exploitation Balance:** BFTS's beam search prevents premature convergence to local optima, allowing the system to discover non-obvious experimental findings that greedy strategies would miss.

3. **Automatic Ablation Generation:** The tree structure naturally produces comparative experiments (ablations) across branches, which are a critical component of convincing ML papers.

4. **Docker Safety:** Isolating experiment execution in Docker containers makes the system far safer for deployment in shared computing environments, addressing one of v1's key criticisms.

5. **AIDE's Robustness:** AIDE's structured approach to iterative experiment improvement outperforms v1's aider-based approach in handling complex, multi-file experiment scripts.

6. **AWS Bedrock Support:** Enterprise-grade LLM access enables deployment in security-constrained environments (financial institutions, healthcare, government research labs).

7. **Modular Architecture:** The clean separation of BFTS, AIDE, paper writing, and review modules makes it straightforward to swap components (e.g., replace AIDE with a different coding agent).

8. **Richer Narrative:** The tree search history provides a natural story for the introduction and related work sections: "We explored X directions; direction Y proved most fruitful for reasons Z."

---

## ⚠️ Limitations

1. **Significantly Higher Cost:** BFTS's need to run many experiments in parallel or sequence makes v2 2–3× more expensive per paper than v1. This limits practical use at scale.

2. **Domain Restriction Unchanged:** Like v1, v2 is still limited to pre-defined template domains. The tree search explores within a domain, not across domains.

3. **Docker Overhead:** Containerized execution adds latency (startup time, image pulling, volume mounting). Fast experiments in v1 may be meaningfully slower in v2.

4. **BFTS Can Thrash:** If the evaluation metric is noisy (e.g., due to random initialization), BFTS may select branches based on noise rather than genuine quality differences. Variance reduction strategies are not always sufficient.

5. **Single Accepted Paper:** The landmark result is based on one accepted paper. Whether this represents systematic improvement or a favorable instance is not yet statistically established.

6. **AIDE Integration Complexity:** AIDE is a separate project with its own API and update schedule. Keeping the v2 integration compatible with upstream AIDE changes creates maintenance overhead.

7. **Still No Citation Verification:** Despite improvements, hallucinated citations remain an issue. The system does not perform systematic citation verification against actual paper databases.

8. **Resource Requirements:** Running 20 Docker containers for BFTS requires significant compute infrastructure — impractical for individual researchers with limited resources.

---

## 🔗 Related Work

| Project | Relationship |
|---|---|
| **AI-Scientist v1** (SakanaAI) | Direct predecessor; BFTS and AIDE replace the linear pipeline |
| **AIDE** (WecoAI) | Core experiment coding agent integrated into v2 |
| **AlphaDev** (DeepMind) | Tree search applied to algorithm discovery; similar search philosophy |
| **FunSearch** (DeepMind) | Evolutionary search over programs; comparable to BFTS in spirit |
| **Agent Laboratory** (Schmidgall) | Alternative multi-agent approach to research automation |
| **AI-Researcher** (HKUDS) | Parallel development; extends to literature survey and hypothesis design |
| **Biomni** (Stanford SNAP) | Domain-specific (biomedical) research agent |
| **OpenAI o1/o3** | Reasoning model improvements enable better BFTS node evaluation |
| **WecoAI/aide** | Upstream AIDE project — key dependency |
| **DDPM** (Ho et al.) | Underlying model for the accepted "Adaptive Dual-Scale Denoising" paper |

---

## 📎 References

1. SakanaAI. (2024–2025). *AI-Scientist-v2 GitHub Repository*. [https://github.com/SakanaAI/AI-Scientist-v2](https://github.com/SakanaAI/AI-Scientist-v2)

2. Lu, C., Lu, C., Lange, R. T., Foerster, J., Clune, J., & Ha, D. (2024). *The AI Scientist: Towards Fully Automated Open-Ended Scientific Discovery*. arXiv:2408.06292.

3. WecoAI. (2024). *AIDE: Agentic Iterative Design for Experiments*. [https://github.com/WecoAI/aideml](https://github.com/WecoAI/aideml)

4. Ho, J., Jain, A., & Abbeel, P. (2020). *Denoising Diffusion Probabilistic Models*. NeurIPS 2020.

5. Rombach, R., Blattmann, A., Lorenz, D., Esser, P., & Ommer, B. (2022). *High-Resolution Image Synthesis with Latent Diffusion Models*. CVPR 2022.

6. Chen, X., et al. (2024). *FunSearch: Making new discoveries in mathematical sciences using large language models*. Nature.

7. Lample, G., et al. (2022). *HyperTree Proof Search for Neural Theorem Proving*. NeurIPS 2022. (Inspiration for tree search in reasoning systems.)

8. Anthropic. (2024). *Claude 3.5 Model Card*. [https://www.anthropic.com/claude](https://www.anthropic.com/claude)

9. AWS. (2024). *Amazon Bedrock Documentation*. [https://docs.aws.amazon.com/bedrock](https://docs.aws.amazon.com/bedrock)

10. Yao, S., et al. (2023). *Tree of Thoughts: Deliberate Problem Solving with Large Language Models*. NeurIPS 2023. (Conceptual precursor to BFTS.)

11. SakanaAI Research Blog. (2025). *AI generates its first peer-reviewed research paper*. [https://sakana.ai/ai-scientist-first-publication/](https://sakana.ai/ai-scientist-first-publication/)
