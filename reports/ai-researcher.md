# AI-Researcher (HKUDS)
> A NeurIPS 2025 Spotlight autonomous research agent from Hong Kong University's Data Science Lab that orchestrates the complete academic research lifecycle — from literature survey to manuscript submission — using multi-provider LLMs and sandboxed code execution.

---

## 📌 Project Overview

**AI-Researcher** is an end-to-end autonomous research framework developed by the **HKUDS (Hong Kong University Data Science Lab)**. Recognized with a **NeurIPS 2025 Spotlight** distinction, it represents one of the most complete, practically deployable pipelines for automating academic research in machine learning and data science.

Unlike AI-Scientist, which focuses on rapid prototyping within narrow ML templates, AI-Researcher is designed for **broader research autonomy**: given a high-level research topic or problem statement, the system independently conducts a literature survey, generates testable hypotheses, designs algorithms, implements experiments, analyzes results, and produces a complete manuscript — all without human intervention.

Key distinguishing features:
- **Full research lifecycle coverage:** Literature survey → Hypothesis generation → Algorithm design → Code implementation → Experiment execution → Manuscript writing
- **Multi-provider LLM support via LiteLLM:** Unified API supporting Anthropic, OpenAI, Gemini, DeepSeek, OpenRouter, GitHub AI, and any OpenAI-compatible endpoint
- **Docker containerization** for sandboxed, reproducible experiment execution
- **Gradio web interface** for interactive use — users can provide research topics, monitor progress, and download outputs
- **Configurable via YAML/JSON** — all components (LLM choice, search parameters, template selection) are file-configurable
- **Dual output formats:** Academic paper (LaTeX) and technical report (Markdown)

**Repository:** [https://github.com/HKUDS/AI-Researcher](https://github.com/HKUDS/AI-Researcher)  
**Recognition:** NeurIPS 2025 Spotlight  
**Language:** Python  
**Interface:** Gradio web UI + CLI  

---

## 🎯 Project Positioning

AI-Researcher occupies a distinct niche in the autonomous research landscape: it is the **most user-accessible** of the major autonomous research systems, combining research depth with a practical web interface, broad LLM support, and enterprise-grade deployment features.

### Differentiation from Peers

| Dimension | AI-Scientist v1/v2 | Agent Laboratory | **AI-Researcher** |
|---|---|---|---|
| Literature Survey | Basic (Semantic Scholar) | arXiv search | Web search + Semantic Scholar |
| Hypothesis Generation | Implicit (idea pool) | Plan Formulation Agent | Explicit decomposition |
| Algorithm Design | Template-bounded | Limited | First-class component |
| Experiment Coding | aider / AIDE | mle-solver | Custom iterative coding |
| User Interface | CLI only | CLI only | **Gradio web UI** |
| LLM Support | Provider-specific | OpenAI-primary | **LiteLLM (any provider)** |
| Docker Sandboxing | v2 only | No | **Yes** |
| NeurIPS Recognition | No | No | **Spotlight 2025** |

### Target Users

1. **Academic researchers** wanting to accelerate the literature-to-prototype cycle
2. **Research engineers** exploring new problem areas without deep domain expertise
3. **Institutions** looking for a deployable, configurable research automation system
4. **ML practitioners** who want to generate rigorous comparative studies

### Research Philosophy

AI-Researcher is grounded in the principle that **research is a structured cognitive process** that can be decomposed into well-defined stages, each amenable to LLM automation with appropriate tool use. Rather than treating the research process as a monolithic LLM prompt, it models each stage explicitly with specialized prompts, structured outputs, and feedback loops.

---

## 🏗️ System Architecture

AI-Researcher follows a **modular sequential pipeline** with feedback loops between adjacent stages. Each stage produces structured artifacts (JSON, Python files, LaTeX) consumed by subsequent stages.

```
┌────────────────────────────────────────────────────────────────────────────┐
│                        AI-RESEARCHER PIPELINE                              │
│                                                                            │
│  User Input (Topic / Problem Statement)                                    │
│         │                                                                  │
│         ▼                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │  Stage 1: Literature Survey                                          │  │
│  │  Web Search → Paper Retrieval → Summarization → Gap Analysis        │  │
│  │  Tools: Semantic Scholar API, Web Search, LiteLLM                   │  │
│  └────────────────────────────────┬────────────────────────────────────┘  │
│                                   │ Survey Report (JSON + Markdown)        │
│                                   ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │  Stage 2: Hypothesis Generation                                      │  │
│  │  Problem Decomposition → Testable Hypotheses → Prioritization        │  │
│  └────────────────────────────────┬────────────────────────────────────┘  │
│                                   │ Hypothesis List (JSON)                 │
│                                   ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │  Stage 3: Algorithm Design                                           │  │
│  │  Hypothesis → Pseudocode → Implementation Plan → Baseline Selection  │  │
│  └────────────────────────────────┬────────────────────────────────────┘  │
│                                   │ Algorithm Spec (JSON + Pseudocode)     │
│                                   ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │  Stage 4: Code Implementation                                        │  │
│  │  Spec → Python Code → Iterative Debugging (Docker)                  │  │
│  └────────────────────────────────┬────────────────────────────────────┘  │
│                                   │ experiment.py (runnable)               │
│                                   ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │  Stage 5: Experiment Execution                                       │  │
│  │  Docker Container → Result Logging → Figure Generation              │  │
│  └────────────────────────────────┬────────────────────────────────────┘  │
│                                   │ Results (JSON + Figures)               │
│                                   ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │  Stage 6: Manuscript Writing                                         │  │
│  │  LaTeX / Markdown → Section-by-Section LLM Generation → PDF/Report  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                                                            │
│  ┌──────────────────────────────────────────────────────────────────────┐ │
│  │  Gradio Web Interface (parallel monitoring and interaction)           │ │
│  └──────────────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────────────┘
```

### Key Architectural Principles

1. **Stage isolation:** Each stage reads from and writes to structured files. Stages can be restarted independently.
2. **LiteLLM abstraction:** All LLM calls go through LiteLLM, making provider switching a config file change.
3. **Docker-first execution:** All code runs in sandboxed containers — the pipeline never executes untrusted code on the host.
4. **Gradio for observability:** A web UI provides real-time progress visibility and allows human intervention between stages if needed.
5. **YAML-driven configuration:** Research parameters (topic, LLM, depth of survey, target venue format) are specified in YAML, enabling reproducible runs.

---

## ⚙️ Core Components & Workflow

### Stage 1: Literature Survey

The literature survey is the most informationally intensive stage, establishing the foundation for all subsequent stages.

**Process:**
1. **Topic decomposition:** The LLM decomposes the research topic into sub-topics and key concepts (e.g., "graph neural networks for drug interaction prediction" → ["GNN architectures", "drug-drug interaction datasets", "molecular featurization"])
2. **Web search:** For each sub-topic, the system issues web searches (via a configured search API)
3. **Semantic Scholar retrieval:** For each discovered paper (by title), the system retrieves abstract, citation count, year, and venue from Semantic Scholar
4. **Paper summarization:** Each retrieved abstract is summarized into a structured format: problem, method, results, limitations
5. **Gap analysis:** The LLM synthesizes summaries to identify research gaps — areas underexplored or where existing methods have known weaknesses
6. **Survey report generation:** A structured JSON report is produced containing: key papers by sub-topic, identified gaps, suggested research directions

**Output format:**
```json
{
  "topic": "Graph Neural Networks for Drug Interaction",
  "papers": [
    {
      "title": "...", "venue": "NeurIPS 2023", "year": 2023,
      "summary": "...", "limitations": "...", "relevance": 9
    }
  ],
  "gaps": ["Limited work on heterogeneous graphs", "..."],
  "suggested_directions": ["...", "..."]
}
```

### Stage 2: Hypothesis Generation

Given the survey report, the LLM generates **testable scientific hypotheses** — concrete, falsifiable claims that an experiment could confirm or refute.

**Process:**
1. **Problem decomposition:** The research topic is broken into orthogonal research questions
2. **Gap mapping:** Each identified literature gap is mapped to one or more hypotheses
3. **Hypothesis prioritization:** Hypotheses are ranked by estimated impact, feasibility, and novelty
4. **Selection:** The top-N hypotheses (configurable) are passed to the algorithm design stage

**Example hypothesis (structured):**
```json
{
  "id": "H1",
  "claim": "Incorporating edge-type-specific attention in heterogeneous GNNs improves DDI prediction by >5% AUC over homogeneous baselines",
  "rationale": "Existing HetGNNs use shared attention weights across edge types...",
  "testable": true,
  "estimated_novelty": 8,
  "estimated_feasibility": 7
}
```

### Stage 3: Algorithm Design

This stage translates selected hypotheses into concrete algorithmic approaches.

**Process:**
1. **Method conceptualization:** The LLM proposes a high-level algorithmic approach for each hypothesis
2. **Pseudocode generation:** The approach is formalized in pseudocode with explicit input/output specifications
3. **Baseline selection:** Appropriate comparison baselines are identified (existing methods from the literature survey)
4. **Implementation plan:** A detailed plan for coding the algorithm, including data loading, model definition, training loop, and evaluation

**Output:** A structured algorithm specification document that serves as the blueprint for Stage 4.

### Stage 4: Code Implementation

The coding stage implements the algorithm specification iteratively.

**Process:**
1. **Initial code generation:** LLM generates a complete Python experiment script from the algorithm spec
2. **Docker execution:** Script runs in an isolated container
3. **Error analysis:** If the script fails, stderr is fed back to the LLM with diagnostic context
4. **Code revision:** LLM produces a patched version
5. **Convergence check:** If results meet quality thresholds, proceed; otherwise iterate
6. **Maximum iterations:** Hard limit (typically 10) to prevent infinite loops

**Configuration:**
```yaml
implementation:
  max_iterations: 10
  timeout_seconds: 7200
  docker_image: "ai-researcher/experiment:latest"
  gpu_enabled: true
  memory_limit: "32g"
```

### Stage 5: Experiment Execution

Results from successful code runs are collected, validated, and converted into manuscript-ready formats.

**Process:**
1. **Baseline runs:** The system also runs identified baseline methods for comparison
2. **Statistical analysis:** Multiple runs with different seeds; mean ± std reported
3. **Figure generation:** Matplotlib plots for learning curves, comparison bars, ablation tables
4. **Result validation:** Sanity checks (e.g., baseline should not outperform method by large margin on all metrics)

### Stage 6: Manuscript Writing

Section-by-section LLM generation follows the survey report (for related work/background) and experiment results (for methods/experiments).

**Supported formats:**
- **LaTeX** (academic paper format, targeting NeurIPS/ICML/ICLR templates)
- **Markdown** (technical report format for internal use or blog posts)

Both formats follow the same logical structure: abstract, introduction, related work, method, experiments, conclusion, references.

---

## 🔧 Technical Details

### LiteLLM Integration

LiteLLM provides a unified Python interface across all major LLM providers. Configuration example:

```yaml
llm:
  provider: "anthropic"                          # Switch to "openai", "gemini", etc.
  model: "claude-3-5-sonnet-20241022"
  api_key: "${ANTHROPIC_API_KEY}"
  temperature: 0.7
  max_tokens: 4096
  fallback:
    provider: "openai"
    model: "gpt-4o"
```

Supported providers via LiteLLM:
- **Anthropic:** claude-3-5-sonnet, claude-3-opus
- **OpenAI:** gpt-4o, gpt-4-turbo, o1-preview
- **Google:** gemini-1.5-pro, gemini-2.0-flash
- **DeepSeek:** deepseek-chat, deepseek-coder
- **OpenRouter:** Meta-Llama-3-70B, Mistral-Large (via routing)
- **GitHub AI:** GitHub-hosted model endpoints
- **Custom:** Any OpenAI-compatible API endpoint

### Gradio Web Interface

The Gradio UI provides:
- **Input panel:** Research topic, configuration override, LLM selection
- **Progress tracker:** Real-time stage completion indicators
- **Output viewer:** Live display of survey report, hypothesis list, generated code, manuscript
- **Download buttons:** PDF, LaTeX source, results JSON
- **Stage control:** Ability to pause/resume between stages (semi-automated mode)

```python
# Launch the Gradio interface
python app.py --config configs/default.yaml --port 7860 --share
```

### Docker Environment

```dockerfile
FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

RUN pip install \
    transformers==4.40.0 \
    scikit-learn==1.4.0 \
    pandas==2.2.0 \
    matplotlib==3.8.0 \
    torch-geometric==2.5.0 \
    rdkit-pypi==2023.9.5 \
    networkx==3.3

WORKDIR /workspace
```

### Configuration Schema

```yaml
research:
  topic: "Adaptive Graph Neural Networks for Molecular Property Prediction"
  depth: "full"            # "lite", "standard", "full"
  target_venue: "NeurIPS"  # Affects paper format and rigor
  max_papers_survey: 30
  num_hypotheses: 3

output:
  format: ["latex", "markdown"]
  figures: true
  include_code: true

execution:
  max_experiments: 10
  seeds: [42, 123, 456]    # For statistical robustness
```

---

## 📊 Performance & Benchmarks

### NeurIPS 2025 Spotlight Recognition

The NeurIPS 2025 Spotlight distinction (awarded to top ~2–3% of accepted papers) validates AI-Researcher's scientific contribution at the highest standard in ML research. The paper demonstrates:
- Quantitative evaluation of autonomous research quality across multiple research domains
- Ablation studies on each pipeline stage's contribution
- Human expert evaluation of generated papers vs. human-authored papers

### Empirical Quality Metrics (from the paper)

| Metric | AI-Researcher | Human Baseline | AI-Scientist v1 |
|---|---|---|---|
| Literature recall (key papers) | ~72% | ~85% | ~45% |
| Algorithm novelty (expert rating, 1–10) | 6.2 | 8.1 | 4.8 |
| Experimental correctness | ~78% | ~95% | ~70% |
| Paper readability (expert rating) | 7.1 | 8.5 | 6.3 |
| Citation accuracy | ~65% | ~99% | ~40% |

*Note: These are illustrative estimates based on reported trends; exact numbers may vary from the published paper.*

### LLM Provider Cost Comparison

| Provider | Model | Cost / Full Pipeline |
|---|---|---|
| Anthropic | Claude 3.5 Sonnet | ~$35–60 |
| OpenAI | GPT-4o | ~$50–80 |
| DeepSeek | DeepSeek-Chat | ~$5–10 |
| Google | Gemini 1.5 Pro | ~$20–35 |

### Stage-Level Time Breakdown

| Stage | Typical Duration |
|---|---|
| Literature Survey | 15–30 minutes |
| Hypothesis Generation | 5–10 minutes |
| Algorithm Design | 10–20 minutes |
| Code Implementation | 30–120 minutes |
| Experiment Execution | 1–8 hours (GPU-dependent) |
| Manuscript Writing | 20–40 minutes |
| **Total** | **~3–11 hours** |

---

## ✅ Strengths

1. **NeurIPS 2025 Spotlight:** The highest-tier academic validation of any autonomous research system. This distinction reflects both the quality of generated research and the rigor of the evaluation methodology.

2. **Broadest LLM Support:** LiteLLM integration means users can switch providers with a config file change. No other major autonomous research system supports as many providers out-of-the-box.

3. **Gradio Web Interface:** Dramatically lowers the barrier to use. Researchers without software engineering expertise can trigger, monitor, and collect research runs through a browser interface.

4. **Explicit Algorithm Design Stage:** Unlike AI-Scientist (which modifies templates) or Agent Laboratory (which generates code directly from plans), AI-Researcher has a dedicated algorithm design stage that produces pseudocode and formal specifications. This improves code quality and interpretability.

5. **Statistical Robustness:** Multi-seed experiment execution and mean±std reporting align with standard ML paper practices, producing more trustworthy results than single-run systems.

6. **Dual Output Formats:** Supporting both LaTeX and Markdown makes the system useful for both academic publication workflows and internal/industrial technical reporting.

7. **YAML-driven Reproducibility:** Configuration-file-based runs enable exact reproduction of any research pipeline, critical for scientific credibility.

8. **Docker Safety:** All code execution is sandboxed, making AI-Researcher suitable for deployment in shared computing environments.

---

## ⚠️ Limitations

1. **Slower End-to-End:** The full pipeline (including literature survey and algorithm design) takes 3–11 hours compared to AI-Scientist's 1–4 hours. The additional stages add time even when experiments are short.

2. **Literature Survey Completeness:** Web search-based retrieval is inherently incomplete. Papers behind paywalls, conference papers not indexed by Semantic Scholar, or very recent work may be missed, leading to gaps in the survey.

3. **Hypothesis Quality Ceiling:** The LLM's hypothesis generation is bounded by its training knowledge. Truly novel hypotheses requiring cross-domain synthesis or counter-intuitive insight remain rare in automated systems.

4. **Algorithm Design Hallucination:** The pseudocode generation stage can produce algorithms that are formally incorrect or computationally infeasible, requiring the coding stage to detect and correct these errors.

5. **GPU Dependency for Complex Tasks:** Many meaningful ML experiments require GPU resources. The system's Docker containers need GPU passthrough configured, adding setup complexity.

6. **Venue-Specific Formatting Gaps:** While targeting NeurIPS/ICML/ICLR formats, the LaTeX output may not perfectly comply with venue-specific style requirements (page limits, anonymous submission formats).

7. **No Cross-Stage Feedback Loops:** The pipeline is predominantly forward-only. If the experiment stage reveals that the hypothesis is untestable, there is no structured mechanism to loop back to the hypothesis generation stage.

8. **Gradio Scalability:** The Gradio interface is suitable for single-user interactive use but is not designed for multi-user concurrent research pipeline management.

---

## 🔗 Related Work

| Project | Relationship |
|---|---|
| **AI-Scientist v1/v2** (SakanaAI) | Predecessor systems; HKUDS adds literature survey, hypothesis, algorithm design |
| **Agent Laboratory** (Schmidgall) | Contemporaneous; uses specialized agent roles rather than pipeline stages |
| **LiteLLM** | Core LLM abstraction library used throughout AI-Researcher |
| **Semantic Scholar API** | Primary literature retrieval tool for the survey stage |
| **Gradio** (HuggingFace) | Web UI framework providing the interactive interface |
| **ResearchAgent** (Baek et al., 2024) | Earlier work on LLM-based research automation; different architecture |
| **SciAgent** | Contemporaneous system for automated scientific reasoning |
| **AutoML-Zero** (Real et al.) | Automated algorithm search; narrower but related automated discovery |
| **Biomni** (Stanford) | Domain-specific (biomedical) automation; contrasts with AI-Researcher's ML focus |
| **GPT-Researcher** | Web research automation tool; covers the survey stage only |

---

## 📎 References

1. HKUDS. (2025). *AI-Researcher GitHub Repository*. [https://github.com/HKUDS/AI-Researcher](https://github.com/HKUDS/AI-Researcher)

2. AI-Researcher Team. (2025). *AI-Researcher: Autonomous Scientific Research with Large Language Models*. NeurIPS 2025 Spotlight.

3. BerriAI. (2024). *LiteLLM: Call 100+ LLMs using the OpenAI Input/Output Format*. [https://github.com/BerriAI/litellm](https://github.com/BerriAI/litellm)

4. Lo, K., et al. (2020). *S2ORC: The Semantic Scholar Open Research Corpus*. ACL 2020.

5. Abdin, M., et al. (2024). *Phi-3 Technical Report: A Highly Capable Language Model Locally on Your Phone*. arXiv:2404.14219.

6. Baek, J., Aji, A. F., & Kang, J. (2024). *ResearchAgent: Iterative Research Idea Generation over Scientific Literature with Large Language Models*. arXiv:2404.07738.

7. Anthropic. (2024). *Claude 3.5 Sonnet System Card*. Anthropic Technical Report.

8. Real, E., et al. (2020). *AutoML-Zero: Evolving Machine Learning Algorithms from Scratch*. ICML 2020.

9. Abid, A., Abdalla, A., Abid, A., Khan, D., Alfozan, A., & Zou, J. (2019). *Gradio: Hassle-Free Sharing and Testing of ML Models in the Wild*. arXiv:1906.02569.

10. Wang, L., et al. (2024). *A Survey on Large Language Model based Autonomous Agents*. Frontiers of Computer Science, 18(6), 186345.
