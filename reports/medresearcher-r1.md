# MedResearcher-R1 (AQ-MedAI)

> **A knowledge-informed trajectory synthesis framework for training domain-specific medical reasoning models. Achieves top results on MedBrowseComp, GAIA, and XBench-DeepSearch by generating high-quality multi-hop QA and reasoning trajectories from medical knowledge graphs.**

---

## Overview

| Field | Details |
|---|---|
| **Repository** | [github.com/AQ-MedAI/MedResearcher-R1](https://github.com/AQ-MedAI/MedResearcher-R1) |
| **Author / Org** | AQ-MedAI |
| **Language** | Python 3.10+ |
| **Created** | August 2025 |
| **Stars** | ~488 (as of March 2026) |
| **License** | Apache 2.0 |
| **arXiv Paper** | [2508.14880](https://arxiv.org/abs/2508.14880) — *MedResearcher-R1: Knowledge-Informed Trajectory Synthesis Approach* |
| **Model** | [AQ-MedAI/MedResearcher-R1-32B](https://huggingface.co/AQ-MedAI/MedResearcher-R1-32B) (HuggingFace) |
| **Domain** | Biomedical / Clinical |

MedResearcher-R1 addresses a fundamental bottleneck in medical AI: the scarcity of high-quality, multi-hop reasoning trajectories for training deep research agents in clinical and biomedical domains. The system provides a complete three-stage pipeline — from domain knowledge ingestion through knowledge graph construction, to QA synthesis, to trajectory generation and quality filtering — that produces training data capable of fine-tuning a 32B model to state-of-the-art performance on medical reasoning benchmarks.

The framework is unusual in that the primary deliverable is not the agent at inference time, but rather the *training data production pipeline* that generates the agent. This positions MedResearcher-R1 as a meta-research tool: a system for building better medical AI research assistants through structured knowledge distillation.

---

## Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                  MedResearcher-R1 Pipeline                          │
│                                                                    │
│  Stage 1: Knowledge Graph Construction                              │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Medical Domain Knowledge                                    │  │
│  │       │                                                      │  │
│  │       ▼                                                      │  │
│  │  KG Builder ──── D3.js Force-Directed Visualization         │  │
│  │       │                                                      │  │
│  │       ▼                                                      │  │
│  │  Subgraph Sampler (5 algorithms)                             │  │
│  │  mixed · augmented_chain · community_core_path               │  │
│  │  dual_core_bridge · max_chain                                │  │
│  │       │                                                      │  │
│  │       ▼                                                      │  │
│  │  QA Generator                                                │  │
│  │  • Multi-hop question synthesis                              │  │
│  │  • Deep concept obfuscation                                  │  │
│  │  • Reasoning path (cheat_sheet) generation                   │  │
│  │  • Batch processing with QPS control                         │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                         │                                          │
│                         ▼                                          │
│  Stage 2: Trajectory Generation Pipeline                            │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  QA Pairs                                                    │  │
│  │       │                                                      │  │
│  │       ▼                                                      │  │
│  │  Multi-turn Agent Framework                                  │  │
│  │  (tool integration, concurrent task processing)              │  │
│  │       │                                                      │  │
│  │       ▼                                                      │  │
│  │  Quality Filter                                              │  │
│  │  • Token-based validation                                    │  │
│  │  • Tool call/response matching                               │  │
│  │  • Automated error detection                                 │  │
│  │       │                                                      │  │
│  │       ▼                                                      │  │
│  │  MTG Rewriter (Masked Trajectory Guidance)                   │  │
│  │  LLM-powered trajectory optimisation                         │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                         │                                          │
│                         ▼                                          │
│  Stage 3: Evaluation Pipeline                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Trained MedResearcher-R1-32B Model                          │  │
│  │       │                                                      │  │
│  │       ▼                                                      │  │
│  │  Benchmark Evaluator                                         │  │
│  │  MedBrowseComp · GAIA · XBench-DeepSearch                    │  │
│  │  (multi-worker, rollout-based evaluation)                    │  │
│  └──────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
```

---

## Core Workflow

### Stage 1 — Knowledge Graph Construction

**1a. Domain knowledge ingestion** — Medical domain knowledge sources (clinical guidelines, ontologies, literature) are ingested and transformed into a structured knowledge graph. Entities represent medical concepts (diseases, drugs, procedures, biomarkers) and edges represent semantic relationships.

**1b. Interactive visualisation** — A web-based D3.js force-directed graph interface allows domain experts to inspect and curate the knowledge graph before QA generation. This human-in-the-loop inspection step is a deliberate quality gate.

**1c. Subgraph sampling** — The system implements five distinct subgraph sampling algorithms to generate diverse, non-trivial question candidates:
- **mixed** — uniform sampling across all edge types
- **augmented_chain** — linear paths augmented with side-branch nodes
- **community_core_path** — paths through community-central nodes for high-connectivity questions
- **dual_core_bridge** — two high-degree nodes connected via bridge nodes
- **max_chain** — longest non-repeating path for maximum multi-hop depth

**1d. QA synthesis** — For each sampled subgraph, the system generates multi-hop question-answer pairs using:
- *Deep concept obfuscation*: surface forms of medical entities are replaced with paraphrases, synonyms, or indirect descriptions to prevent trivial pattern matching.
- *Quantitative reasoning*: numerical and probabilistic questions are generated where the subgraph supports them.
- *Reasoning path generation*: each QA pair is annotated with a step-by-step `cheat_sheet` detailing the reasoning chain through the knowledge graph.

**1e. Batch processing** — The QA generation system runs with configurable QPS control and checkpoint-resume capability, allowing large-scale production runs to be interrupted and continued.

### Stage 2 — Trajectory Generation

**2a. Multi-turn agent execution** — Each QA pair is fed to a multi-turn agent framework that simulates the reasoning process a medical research agent would follow, including tool calls (database lookups, literature searches, calculations). The agent produces a full reasoning trajectory.

**2b. Quality filtering** — Generated trajectories pass through three validation layers:
- Token count bounds (removing too-short or too-long trajectories).
- Tool call/response matching (ensuring every tool call has a valid response).
- Automated error detection (removing trajectories with logical contradictions or factual errors detectable by rule).

**2c. MTG rewriting** — Masked Trajectory Guidance is an LLM-powered post-processing step that rewrites sub-optimal reasoning steps while preserving the overall trajectory structure and final answer. This step improves the pedagogical quality of the training data without requiring complete trajectory regeneration.

**2d. Training data output** — The final output is a JSONL file of high-quality multi-turn reasoning trajectories, released publicly at `TrajectoryGenerationPipeline/qa_data/open_data.jsonl`.

### Stage 3 — Evaluation

**3a. Interactive evaluation** — Single-question mode with step-by-step reasoning visualisation, useful for qualitative inspection of model behaviour.

**3b. Batch evaluation** — Multi-worker parallel evaluation across benchmark datasets (MedBrowseComp, GAIA, XBench-DeepSearch) with configurable rollout counts and timeout controls.

---

## Key Features

- **Knowledge graph-driven QA generation** — multi-hop questions are grounded in a domain-specific knowledge graph rather than generated from text alone, ensuring they test genuine multi-step reasoning.
- **Five subgraph sampling algorithms** — diverse structural patterns in question generation prevent models from learning spurious shortcuts.
- **Masked Trajectory Guidance (MTG)** — novel LLM-powered trajectory optimisation that improves training data quality without full regeneration.
- **Open training data** — the synthesised QA and trajectory dataset is publicly released, enabling community fine-tuning on the medical domain.
- **32B open-weight model** — MedResearcher-R1-32B is freely downloadable from HuggingFace for local inference.
- **SOTA on MedBrowseComp** — demonstrates the efficacy of knowledge-informed trajectories over generic web-browsing trajectories for medical tasks.
- **Comprehensive evaluation suite** — three benchmark integrations (MedBrowseComp, GAIA, XBench-DeepSearch) with multi-worker rollout evaluation.
- **Interactive KG visualisation** — D3.js-based web interface for domain expert review of the knowledge graph before QA generation.

---

## Technical Implementation

### Knowledge Graph Construction

The KG construction module accepts medical ontology sources (e.g., UMLS, SNOMED CT, DrugBank-compatible formats) and builds a property graph. The graph is stored in a format compatible with the D3.js visualisation frontend, which uses a force-directed layout to show concept clusters and bridge nodes.

Subgraph extraction uses NetworkX-based algorithms for community detection (Louvain method for `community_core_path`) and path finding (DFS/BFS for `max_chain`, `augmented_chain`). The sampling controller maintains statistics on coverage to avoid redundant question generation.

### QA Generation Engine

QA generation is driven by an LLM with a structured prompt that receives:
- The sampled subgraph as a structured representation.
- The target question type (multi-hop, quantitative, counterfactual).
- The target difficulty level.
- A `cheat_sheet` template requiring step-by-step annotation.

The output is a typed JSON object containing the question, answer, reasoning path, and difficulty metadata. Generation runs with token-bucket QPS control to respect API rate limits and supports checkpoint-resume via a progress database.

### Trajectory Generation Framework

The multi-turn agent framework wraps any OpenAI-compatible LLM with a ReAct-style tool use loop. Available tools include:
- Knowledge graph lookup (by entity name or concept ID).
- Arithmetic and unit conversion.
- Literature search (configurable backend).
- Step-by-step reasoning trace output.

The framework records the full tool-call/response sequence in a JSONL format compatible with standard instruction-tuning pipelines.

### Model Fine-Tuning

The released 32B model is fine-tuned from a base LLM (architecture details in the arXiv paper) using the synthesised trajectory dataset. The fine-tuning uses a standard next-token prediction objective over the full multi-turn trajectory, including tool call tokens.

### Evaluation Infrastructure

Benchmark evaluation uses a `BatchDatasetEvaluator` that:
- Distributes questions across a configurable number of worker processes.
- Runs multiple rollouts per question for statistical reliability.
- Enforces per-question timeouts to prevent stalls on intractable queries.
- Aggregates results into a structured performance report.

---

## Evaluation & Benchmarks

| Benchmark | MedResearcher-R1-32B | Notes |
|-----------|----------------------|-------|
| **MedBrowseComp** | SOTA (as reported in paper) | Medical browsing and comprehension |
| **GAIA** | Competitive | General AI assistant multi-step tasks |
| **XBench-DeepSearch** | Competitive | Deep search and information synthesis |

The paper reports that the knowledge-informed trajectory synthesis approach substantially outperforms training on generic web-browsing trajectories for medical domain tasks. Full numerical results and comparisons are available in [arXiv:2508.14880](https://arxiv.org/abs/2508.14880).

---

## Strengths

1. **Domain-grounded QA generation** — by anchoring question generation in a medical knowledge graph rather than raw text, MedResearcher-R1 produces training data with verifiable multi-hop structure and controlled difficulty.

2. **Reasoning path annotation** — every generated QA pair includes a `cheat_sheet` detailing the step-by-step reasoning chain. This annotation quality is difficult to achieve with unstructured web-crawled data.

3. **Five diverse sampling algorithms** — the variety of structural patterns prevents the trained model from overfitting to a particular subgraph topology, improving generalisation across question types.

4. **MTG trajectory rewriting** — the post-processing step that rewrites sub-optimal reasoning steps raises the average quality of the training corpus without the cost of regenerating trajectories from scratch.

5. **Fully open pipeline** — the synthesis framework, training data, and model weights are all released, enabling other teams to apply the approach to new medical subdomains or other specialised fields.

6. **Strong benchmark performance** — SOTA on MedBrowseComp demonstrates that the knowledge-informed approach produces demonstrably better medical research agents than data collected from general web browsing.

---

## Limitations

1. **Domain-specific scope** — the framework is designed for medical/biomedical research. Applying it to other domains requires constructing a new domain knowledge graph, which requires domain expertise and data access.

2. **Dependency on existing knowledge graphs** — the quality of the generated QA is bounded by the completeness and accuracy of the input knowledge graph. Gaps or errors in the KG propagate directly into the training data.

3. **Large model requirement** — the released model is 32B parameters, requiring significant GPU memory (2× A100 80GB minimum for full-precision inference). This limits accessibility for smaller research labs.

4. **No real-time web access** — unlike scaffold-based deep research agents, MedResearcher-R1 at inference time uses the trained model's internal knowledge, not live web search. For tasks requiring up-to-date information (recent clinical trials, new drug approvals), this is a significant limitation.

5. **Training data as primary output** — the system's main contribution is training data generation, not a deployable research agent. End users who want a medical research assistant must first run the full training pipeline or use the released model, rather than simply deploying the system against a question.

6. **Limited documentation for production deployment** — the README focuses on the training pipeline and benchmark evaluation; documentation for deploying the model as an interactive research assistant is sparse.

---

## Related Work

| System | Relationship |
|--------|-------------|
| [Biomni](biomni.md) | Stanford's complementary biomedical agent; Biomni uses a datalake + live tool execution rather than a trained model; both target the biology/medicine domain |
| [CognitiveKernel-Pro](cognitivekernel-pro.md) | Parallel SFT-training approach for general deep research; CK-Pro targets general GAIA tasks while MedResearcher-R1 targets medical multi-hop reasoning |
| [AI-Researcher](ai-researcher.md) | Full-lifecycle research system (NeurIPS 2025); uses live literature search and code execution rather than a pre-trained domain model |
| [PaperQA2](paperqa2.md) | Complementary for scientific literature QA; PaperQA2 uses iterative RAG over PDFs while MedResearcher-R1 uses a fine-tuned model with KG-based training data |
| [OpenScholar](openscholar.md) | Dense retrieval over 45M papers; complementary to MedResearcher-R1 for tasks requiring current literature rather than structured KG reasoning |
| WebDancer / WebSailor | RL-trained general deep research agents; MedResearcher-R1 demonstrates that domain-specific SFT outperforms these on medical tasks |
| MedRAG (Liu et al., 2024) | Earlier work on medical retrieval-augmented generation; MedResearcher-R1 extends this with KG-grounded multi-hop trajectory synthesis |

---

## References

1. AQ-MedAI. (2025). *MedResearcher-R1: Knowledge-Informed Trajectory Synthesis Approach*. arXiv:2508.14880. [https://arxiv.org/abs/2508.14880](https://arxiv.org/abs/2508.14880)
2. MedResearcher-R1-32B model on HuggingFace. [https://huggingface.co/AQ-MedAI/MedResearcher-R1-32B](https://huggingface.co/AQ-MedAI/MedResearcher-R1-32B)
3. GitHub Repository. [https://github.com/AQ-MedAI/MedResearcher-R1](https://github.com/AQ-MedAI/MedResearcher-R1)
4. MedBrowseComp Benchmark. [https://huggingface.co/datasets/AQ-MedAI/MedBrowseComp](https://huggingface.co/datasets/AQ-MedAI/MedBrowseComp)
5. GAIA Benchmark. [https://huggingface.co/spaces/gaia-benchmark/leaderboard](https://huggingface.co/spaces/gaia-benchmark/leaderboard)
6. XBench-DeepSearch. [https://huggingface.co/spaces/Xkev/Leaderboard-XBench](https://huggingface.co/spaces/Xkev/Leaderboard-XBench)
7. Open training data. [TrajectoryGenerationPipeline/qa_data/open_data.jsonl](https://github.com/AQ-MedAI/MedResearcher-R1/blob/main/TrajectoryGenerationPipeline/qa_data/open_data.jsonl)
8. Liu, X. et al. (2024). RAGGED: Towards Informed Design of Retrieval Augmented Generation Systems. arXiv. [https://arxiv.org/abs/2403.09040](https://arxiv.org/abs/2403.09040)
