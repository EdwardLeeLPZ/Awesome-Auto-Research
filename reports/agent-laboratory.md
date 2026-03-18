# Agent Laboratory (Samuel Schmidgall)
> An end-to-end autonomous research system using specialized LLM agent roles — from literature review through experiment execution to LaTeX manuscript generation — with human-in-the-loop support and OpenAI o1/o3 as the primary reasoning backbone.

---

## 📌 Project Overview

**Agent Laboratory** is an open-source autonomous research framework developed by **Samuel Schmidgall** at Johns Hopkins University. Published under the paper *"Agent Laboratory: Using LLM Agents as Research Assistants"* (arXiv 2025), it takes a **multi-agent role-specialization approach** to research automation: instead of a single LLM completing the entire pipeline, distinct agents with well-defined roles collaborate to produce research, with a **Professor Agent** orchestrating the overall process.

The system's design philosophy mirrors how human research labs operate: a senior researcher (the Professor Agent) oversees junior researchers (specialized agents), each with a domain of responsibility. This division of cognitive labor allows the system to deploy the most appropriate model for each role — a reasoning-optimized model for planning, a code-optimized model for implementation.

Key features:
- **7 specialized agents:** Literature Review, Plan Formulation, Data Preparation, Running Experiments, Report Writing, Professor, and Review Critic
- **Primary LLMs:** OpenAI o1, o3, GPT-4o (for reasoning-intensive tasks); also supports DeepSeek
- **HuggingFace integration** for dataset access (Hub, Datasets library)
- **arXiv search** for literature retrieval with abstract parsing
- **Human-in-the-loop (HITL) mode:** The pipeline can pause at configurable checkpoints for human review
- **Checkpointing:** Intermediate state saved to disk, enabling resume after interruptions
- **Output:** Complete LaTeX research report with figures, tables, and bibliography
- **mle-solver component:** Specialized ML experiment code generation and execution

**Repository:** [https://github.com/SamuelSchmidgall/AgentLaboratory](https://github.com/SamuelSchmidgall/AgentLaboratory)  
**Paper:** arXiv 2025 (Schmidgall, S.)  
**Language:** Python  
**License:** MIT  

---

## 🎯 Project Positioning

Agent Laboratory's core positioning insight is that **research tasks are not homogeneous** — different stages of the research process require qualitatively different cognitive capabilities:

- Literature review requires **information retrieval and synthesis**
- Research planning requires **structured reasoning and strategy**
- Dataset preparation requires **API literacy and data engineering**
- Experiment coding requires **software engineering and ML expertise**
- Report writing requires **scientific writing and communication**

By assigning specialized agents to each role, Agent Laboratory can deploy the optimal tool for each task rather than relying on a single general-purpose model to excel at all stages.

### Unique Differentiation

1. **Human-in-the-loop first class:** Unlike AI-Scientist and AI-Researcher (which are fully autonomous by default), Agent Laboratory treats HITL as a primary feature, not an afterthought. Researchers can "supervise" the AI research team as a project manager would.

2. **Professor Agent orchestration:** The Professor Agent plays a qualitatively different role from other agents — it does not execute tasks but evaluates outputs, provides critique, and decides whether outputs meet quality standards before proceeding.

3. **o1/o3 as primary backbone:** At launch, Agent Laboratory specifically targeted OpenAI's reasoning-focused o1 and o3 models as primary backends, reasoning that the sequential, multi-step nature of research planning maps well to chain-of-thought reasoning models.

4. **Checkpointing for long runs:** Multi-hour or multi-day research pipelines can be interrupted and resumed without losing progress — a critical practical feature absent in most peer systems.

### Comparison to Human Lab Dynamics

| Human Role | Agent Laboratory Equivalent |
|---|---|
| Graduate Student (Literature) | Literature Review Agent |
| Graduate Student (Planning) | Plan Formulation Agent |
| Research Engineer (Data) | Data Preparation Agent |
| Graduate Student (Experiments) | Running Experiments Agent |
| Technical Writer | Report Writing Agent |
| PI / Professor | Professor Agent |
| External Reviewer | Review Critic Agent |

---

## 🏗️ System Architecture

Agent Laboratory implements a **directed multi-agent pipeline** with bidirectional communication between each specialized agent and the Professor Agent.

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                        AGENT LABORATORY ARCHITECTURE                           │
│                                                                                │
│  Research Topic Input ──────────────────────────────────────────────────────┐ │
│                                                                              │ │
│  ┌───────────────────────────────────────────────────────────────────────┐  │ │
│  │                     PROFESSOR AGENT (o1/o3)                           │  │ │
│  │  Orchestrates, critiques, and approves outputs from all agents        │  │ │
│  └───────┬────────────┬──────────────┬────────────┬───────────┬──────────┘  │ │
│          │            │              │            │           │              │ │
│          ▼            ▼              ▼            ▼           ▼              │ │
│  ┌───────────┐ ┌─────────────┐ ┌──────────┐ ┌────────┐ ┌──────────┐       │ │
│  │ Literature│ │    Plan     │ │   Data   │ │Running │ │  Report  │       │ │
│  │  Review   │ │ Formulation │ │   Prep   │ │ Expts  │ │ Writing  │       │ │
│  │  Agent    │ │   Agent     │ │  Agent   │ │ Agent  │ │  Agent   │       │ │
│  └─────┬─────┘ └──────┬──────┘ └────┬─────┘ └───┬────┘ └────┬─────┘       │ │
│        │              │             │             │           │              │ │
│        ▼              │             ▼             ▼           │              │ │
│   arXiv Search        │     HuggingFace      mle-solver       │              │ │
│   + Summarization     │     Datasets API     (code gen)       │              │ │
│                        │                     + subprocess      │              │ │
│                        ▼                                       ▼              │ │
│               Research Plan (JSON)                       LaTeX Report         │ │
│                                                                              │ │
│  ┌────────────────────────────────────────────────────────────────────────┐ │ │
│  │                     REVIEW CRITIC AGENT                                │ │ │
│  │  Reviews intermediate outputs; provides structured feedback           │ │ │
│  └────────────────────────────────────────────────────────────────────────┘ │ │
│                                                                              │ │
│  ┌────────────────────────────────────────────────────────────────────────┐ │ │
│  │       HUMAN-IN-THE-LOOP CHECKPOINTS (optional)                         │ │ │
│  │  Pause points: after lit review, after plan, after experiments         │ │ │
│  └────────────────────────────────────────────────────────────────────────┘ │ │
└────────────────────────────────────────────────────────────────────────────────┘
```

### State Management

Each stage's output is serialized to disk in a structured format:

```
workspace/
├── state/
│   ├── literature_review.json    # Papers, summaries, gaps
│   ├── research_plan.json        # Plan formulation output
│   ├── datasets.json             # Dataset metadata and paths
│   ├── experiment_code.py        # Generated experiment script
│   ├── results.json              # Experiment results
│   └── report.tex                # Final LaTeX manuscript
└── figures/
    ├── figure1.pdf
    └── figure2.pdf
```

The `checkpoint.json` file records the pipeline's current stage, enabling resume from any completed stage.

---

## ⚙️ Core Components & Workflow

### Agent 1: Literature Review Agent

The Literature Review Agent performs systematic literature search and synthesis.

**Tools:**
- **arXiv search API:** Queries by keyword, title, author, date range
- **Abstract parser:** Extracts structured information from paper abstracts
- **Citation graph:** Explores forward and backward citations for key papers

**Process:**
1. Parse research topic into search queries (multiple keyword combinations)
2. Retrieve top-N papers from arXiv for each query
3. Deduplicate across queries
4. Summarize each paper: problem, method, key results, limitations
5. Identify research gaps and connections
6. Generate annotated bibliography

**Output schema:**
```json
{
  "papers": [
    {
      "arxiv_id": "2303.12345",
      "title": "...",
      "authors": ["..."],
      "year": 2023,
      "venue": "NeurIPS 2023",
      "summary": "...",
      "method": "...",
      "results": "...",
      "limitations": "...",
      "relevance_score": 9
    }
  ],
  "themes": ["Theme 1", "Theme 2"],
  "gaps": ["Gap 1", "Gap 2"],
  "key_papers": ["2303.12345", "..."]
}
```

**Professor Agent review:** The Professor Agent reviews the literature report and may request additional searches ("You missed papers on X") or reject low-quality summaries.

### Agent 2: Plan Formulation Agent

Converts the literature survey into a concrete research plan.

**Inputs:** Literature review output, research topic
**Outputs:** Research plan JSON

```json
{
  "hypothesis": "Adding learned positional encodings improves transformer performance on irregular graphs",
  "methodology": {
    "approach": "Modified transformer with Laplacian PE",
    "baselines": ["Standard Transformer", "GCN", "GAT"],
    "datasets": ["ZINC", "OGBG-MolHIV"],
    "evaluation_metrics": ["MAE", "ROC-AUC"],
    "ablations": ["No PE", "Random PE", "Learned PE"]
  },
  "expected_contributions": ["..."],
  "timeline": {"coding": "2h", "experiments": "4h", "writing": "1h"}
}
```

The plan explicitly specifies baselines and ablations, ensuring the generated experiments are comparative and publishable.

### Agent 3: Data Preparation Agent

Handles dataset downloading, preprocessing, and validation via the **HuggingFace ecosystem**.

**Capabilities:**
- Query HuggingFace Hub for datasets by task type
- Download and cache datasets using `datasets` library
- Apply standard preprocessing transforms
- Validate dataset integrity (check for NaN, size, splits)
- Generate dataset statistics (class distribution, feature statistics)

```python
# Example Data Preparation Agent action
from datasets import load_dataset
dataset = load_dataset("ogb/ogbg-molhiv")
train_data = dataset["train"]
# Validate: check expected number of samples, feature dimensions
assert len(train_data) == 32901, f"Unexpected size: {len(train_data)}"
```

**HuggingFace Integration:**
The agent searches HuggingFace Hub for appropriate datasets using natural language queries. For custom datasets not on the Hub, it can also download from URLs specified in the research plan.

### Agent 4: Running Experiments Agent (with mle-solver)

This is the most technically complex agent. Its core sub-component, **mle-solver**, handles ML experiment code generation and iterative execution.

**mle-solver workflow:**
1. Receive experiment specification (from plan)
2. Generate a complete Python experiment script
3. Execute via subprocess with timeout
4. Parse output: metrics, errors, convergence behavior
5. If error: diagnose (LLM) and patch (LLM)
6. If poor performance: analyze why and propose improvements
7. Repeat until success or max iterations

**mle-solver handles:**
- Model definition (PyTorch/TensorFlow/JAX)
- Data loading pipeline
- Training loop with logging
- Evaluation on validation/test sets
- Figure generation (learning curves, confusion matrices)
- Saving checkpoints and results JSON

**Example generated experiment output:**
```
Epoch 50/100: train_loss=0.234, val_mae=0.198
Epoch 100/100: train_loss=0.187, val_mae=0.163
Test MAE: 0.158 ± 0.012 (5 seeds)
Baseline GCN Test MAE: 0.214 ± 0.018
```

### Agent 5: Report Writing Agent

Generates the complete LaTeX manuscript from experiment results.

**Inputs:** Literature review, research plan, experiment results, figures
**Output:** Complete `.tex` file conforming to a specified venue template

**Section generation order:**
1. **Abstract** (written last, positioned first)
2. **Introduction** (motivation, contributions, paper outline)
3. **Related Work** (organized by theme from literature review)
4. **Method** (technical description of the proposed approach)
5. **Experiments** (setup, results tables, figure captions, analysis)
6. **Conclusion** (summary, limitations, future work)
7. **References** (BibTeX entries from literature review)
8. **Abstract** (filled in with key numbers from experiments)

### Agent 6: Professor Agent

The Professor Agent acts as the **quality gatekeeper** for the entire pipeline.

**Responsibilities:**
- Review each agent's output before the pipeline proceeds
- Provide structured critique (what's missing, what's wrong)
- Decide: accept, revise (with feedback), or reject (restart)
- Set the overall research direction and constraints
- Ensure the research plan is coherent and achievable

**Implemented as:** A special LLM call with a system prompt that establishes the "professor" persona and provides evaluation rubrics for each stage.

### Agent 7: Review Critic Agent

Inspired by conference peer review, the Review Critic Agent provides independent evaluation of intermediate and final outputs.

**Evaluation criteria:**
- Technical correctness
- Novelty relative to literature review
- Experimental rigor (appropriate baselines, ablations, statistics)
- Clarity of writing
- Soundness of conclusions

The Critic Agent's feedback is passed to the Professor Agent for final arbitration.

### Human-in-the-Loop (HITL) Mode

When HITL mode is enabled, the pipeline pauses at configurable checkpoints:

```python
# HITL configuration
HITL_CHECKPOINTS = {
    "after_literature_review": True,
    "after_plan_formulation": True,
    "after_experiments": True,
    "after_report_writing": False  # Don't pause; auto-proceed
}
```

At each checkpoint, the system prints the current output and waits for user input: approve, provide feedback (which is injected into the next agent's context), or abort.

---

## 🔧 Technical Details

### Supported LLMs

| Provider | Models | Recommended For |
|---|---|---|
| OpenAI | o1-preview, o1-mini | Plan formulation, Professor Agent |
| OpenAI | o3 (when available) | Complex reasoning tasks |
| OpenAI | GPT-4o | Coding, report writing |
| DeepSeek | DeepSeek-R1 | Cost-effective alternative to o1 |
| DeepSeek | DeepSeek-Coder-V2 | Experiment coding |

The system allows different agents to use different models — e.g., o1 for the Professor Agent and GPT-4o for report writing — via a per-agent model configuration.

### Repository Structure

```
AgentLaboratory/
├── agents/
│   ├── professor.py         # Professor Agent
│   ├── literature_review.py # Literature Review Agent
│   ├── plan_formulation.py  # Plan Formulation Agent
│   ├── data_preparation.py  # Data Preparation Agent
│   ├── running_experiments.py # Experiment Agent
│   ├── report_writing.py    # Report Writing Agent
│   └── review_critic.py     # Review Critic Agent
├── mle_solver/
│   ├── solver.py            # Main mle-solver loop
│   ├── code_generator.py    # LLM-based code generation
│   └── executor.py          # Subprocess execution
├── tools/
│   ├── arxiv_search.py      # arXiv API wrapper
│   ├── huggingface.py       # HuggingFace Hub access
│   └── latex_builder.py     # LaTeX compilation utilities
├── templates/
│   └── neurips_2024/        # LaTeX template
├── checkpoints/             # Auto-saved state
└── run_laboratory.py        # Main entry point
```

### Checkpointing Implementation

```python
import pickle, os

class Checkpoint:
    def __init__(self, workspace_dir):
        self.path = os.path.join(workspace_dir, "checkpoint.pkl")
    
    def save(self, stage, state):
        with open(self.path, "wb") as f:
            pickle.dump({"stage": stage, "state": state}, f)
    
    def load(self):
        if os.path.exists(self.path):
            with open(self.path, "rb") as f:
                return pickle.load(f)
        return None
```

### CLI Interface

```bash
# Full autonomous run
python run_laboratory.py \
  --topic "Efficient Graph Transformers for Molecular Property Prediction" \
  --model o1-preview \
  --output-dir ./workspace \
  --human-in-loop False

# HITL mode with DeepSeek
python run_laboratory.py \
  --topic "..." \
  --model deepseek-r1 \
  --human-in-loop True \
  --checkpoint-dir ./checkpoints

# Resume from checkpoint
python run_laboratory.py \
  --resume ./checkpoints/checkpoint.pkl
```

---

## 📊 Performance & Benchmarks

### Cost Analysis

| LLM Configuration | Approximate Cost per Paper |
|---|---|
| o1-preview (all agents) | ~$80–150 |
| o1 (Professor) + GPT-4o (others) | ~$40–70 |
| DeepSeek-R1 (all agents) | ~$8–15 |
| GPT-4o (all agents) | ~$30–50 |

The cost is higher than AI-Scientist primarily due to the multi-agent architecture (more LLM calls) and the use of reasoning-optimized models (o1/o3) which are more expensive per token.

### Quality Benchmarks

In the original paper, Agent Laboratory was evaluated on:
1. **Research idea diversity:** How distinct are generated research ideas across multiple runs?
2. **Experiment validity:** What fraction of generated experiments produce statistically meaningful results?
3. **Report quality:** Human researcher ratings on a 1–10 scale for multiple dimensions

**Results (from paper):**
- Experiment success rate (produces valid results): ~75%
- Report quality (human rating): ~6.5/10
- Literature recall: ~68% of key papers found for test topics
- Time to complete full pipeline: 4–12 hours

### HITL vs. Fully Autonomous Comparison

| Metric | Fully Autonomous | HITL Mode |
|---|---|---|
| Experiment success rate | 75% | 88% |
| Report quality (1–10) | 6.5 | 7.8 |
| Time overhead | Baseline | +30–60 min human time |
| Cost | Baseline | Same (HITL is human time) |

The HITL improvement is significant — human guidance at key checkpoints substantially improves output quality, particularly in plan formulation and experiment design.

---

## ✅ Strengths

1. **Role Specialization:** Assigning distinct agents to distinct roles mirrors real research lab organization and allows task-optimal model selection. The Professor Agent's oversight adds a quality control layer absent in pipeline-only systems.

2. **Human-in-the-Loop Support:** First-class HITL mode is a practically important feature for researchers who want AI assistance without full autonomy — the system can act as a capable research team with human project management.

3. **Checkpointing:** Multi-hour research pipelines can be safely interrupted. This is critical for practical use on shared computing clusters with time limits or for iterative refinement workflows.

4. **Review Critic Agent:** The independent critic agent provides a self-assessment layer that catches errors before the Professor Agent's review, reducing the total number of pipeline failures.

5. **HuggingFace Integration:** Native access to the HuggingFace ecosystem — the de facto repository for ML datasets and models — makes data preparation substantially more automated than systems relying on manual dataset specification.

6. **arXiv Coverage:** Targeting arXiv (rather than only Semantic Scholar) gives broader coverage of ML and CS papers, including very recent preprints not yet in other databases.

7. **DeepSeek Support:** Cost-effective alternative models (DeepSeek-R1) make the system accessible to researchers without large API budgets while maintaining reasoning quality.

8. **Open LaTeX Output:** The LaTeX output (not just PDF) allows researchers to post-process, refine, and submit the generated manuscript to actual venues.

---

## ⚠️ Limitations

1. **High Cost with o1/o3:** Using reasoning-optimized models across all agents makes Agent Laboratory one of the most expensive autonomous research systems (~$80–150/paper with o1). The multi-agent architecture amplifies cost.

2. **No Docker Sandboxing:** Unlike AI-Researcher and AI-Scientist v2, Agent Laboratory executes experiment code without container isolation. This is a security concern in shared or production environments.

3. **arXiv-Centric Literature:** The literature review agent primarily searches arXiv, missing papers only in ACL Anthology, IEEE Xplore, or other domain-specific databases without extensive additional configuration.

4. **Agent Coordination Overhead:** The Professor Agent reviewing each other agent's output adds significant latency and cost. In practice, a majority of Professor Agent reviews result in approval — suggesting the overhead may not always be justified.

5. **mle-solver Brittleness:** The mle-solver, while capable, can struggle with complex multi-file experiment codebases or experiments requiring unusual library versions. Error recovery via LLM diagnosis is imperfect for deep debugging scenarios.

6. **No Parallelism:** Agents execute sequentially; the architecture does not support parallel execution (e.g., running multiple experiment configurations simultaneously).

7. **HuggingFace Dependency:** The data preparation agent's reliance on HuggingFace Hub means research on datasets not available there requires manual configuration.

8. **Limited to ML Research:** The system is optimized for ML/CS research with code experiments. Social science, biology, or physics research would require substantial re-engineering.

---

## 🔗 Related Work

| Project | Relationship |
|---|---|
| **AI-Scientist v1/v2** (SakanaAI) | Contemporaneous; template-based vs. Agent Lab's agent-role approach |
| **AI-Researcher** (HKUDS) | Similar full lifecycle; pipeline stages vs. Agent Lab's agent roles |
| **MetaGPT** (DeepWisdom) | Multi-agent software engineering; inspiration for agent role specialization |
| **AutoGen** (Microsoft) | Multi-agent conversation framework; could implement Agent Lab's architecture |
| **OpenAI o1** | Primary reasoning backbone; designed for chain-of-thought reasoning tasks |
| **HuggingFace Hub** | Dataset and model repository used by Data Preparation Agent |
| **arXiv API** | Primary literature source for Literature Review Agent |
| **Eureka** (NVIDIA) | LLM-based reward design; specialized agent for RL experiments |
| **DSPy** (Stanford) | LLM programming framework; contrasts with Agent Lab's prompt engineering approach |
| **SciAgent** | Parallel development in scientific agent automation |

---

## 📎 References

1. Schmidgall, S. (2025). *Agent Laboratory: Using LLM Agents as Research Assistants*. arXiv preprint.

2. SamuelSchmidgall. (2025). *AgentLaboratory GitHub Repository*. [https://github.com/SamuelSchmidgall/AgentLaboratory](https://github.com/SamuelSchmidgall/AgentLaboratory)

3. OpenAI. (2024). *OpenAI o1 System Card*. OpenAI Technical Report.

4. Guo, D., et al. (2024). *DeepSeek-R1: Incentivizing Reasoning Capability in LLMs via Reinforcement Learning*. arXiv:2501.12948.

5. Hong, S., et al. (2023). *MetaGPT: Meta Programming for A Multi-Agent Collaborative Framework*. arXiv:2308.00352.

6. Wu, Q., et al. (2023). *AutoGen: Enabling Next-Gen LLM Applications via Multi-Agent Conversation*. arXiv:2308.08155.

7. Wolf, T., et al. (2020). *Transformers: State-of-the-Art Natural Language Processing*. EMNLP 2020 (HuggingFace).

8. Lu, C., et al. (2024). *The AI Scientist: Towards Fully Automated Open-Ended Scientific Discovery*. arXiv:2408.06292.

9. Sharma, M., et al. (2024). *Towards Automated Research: Survey of LLM-Based Scientific Discovery Systems*. arXiv preprint.

10. Wang, L., et al. (2023). *Voyager: An Open-Ended Embodied Agent with Large Language Models*. arXiv:2305.16291. (Inspiration for persistent agent memory and skill accumulation.)
