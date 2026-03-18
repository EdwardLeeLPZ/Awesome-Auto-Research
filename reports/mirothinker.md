# MiroThinker — Deep Research Agent with SOTA BrowseComp Performance
> MiroMind AI's open-source series of RL-trained deep research agents achieving 88.2 on BrowseComp.

---

## 📌 Project Overview

**MiroThinker** is an open-source deep research agent developed by **MiroMind AI**, designed for complex, multi-step research and prediction tasks. It combines long-horizon reasoning with search-augmented tool use, enabling agents to autonomously plan, retrieve, synthesize, and verify information across extended task horizons.

| Attribute         | Details                                                                 |
|-------------------|-------------------------------------------------------------------------|
| Organization      | MiroMind AI                                                             |
| Repository        | https://github.com/MiroMindAI/MiroThinker                              |
| Website           | https://miromind.ai/                                                    |
| Online Demo       | https://dr.miromind.ai/                                                 |
| HuggingFace       | miromind-ai/MiroThinker-1.7, miromind-ai/MiroThinker-1.7-mini          |
| Stars             | 7,093                                                                   |
| Technical Paper   | arXiv:2511.11793 (MiroThinker v1.0)                                     |
| License           | Open-source                                                             |

MiroThinker is released at two parameter scales — **MiroThinker-1.7-mini (30B)** and **MiroThinker-1.7 (235B)** — and additionally offers a proprietary hosted variant, **MiroThinker-H1**, which achieves 88.2 on the BrowseComp benchmark, the highest reported score among comparable systems at time of release.

### Release Timeline

| Version | Date       | Key Highlights                                                              |
|---------|------------|-----------------------------------------------------------------------------|
| v0.1    | 2025-08-08 | Initial release                                                             |
| v0.2    | 2025-09-08 | SOTA on HLE (17.8%) and BrowseComp (17.2%)                                 |
| v1.0    | 2025-11-13 | 256K context window, up to 600 tool calls, models at 8B/30B/72B scales     |
| v1.5    | 2026-01-05 | 30B and 235B models, SOTA on BrowseComp-ZH and GAIA-Text                   |
| v1.7    | 2026-03-11 | MiroThinker-1.7 (30B & 235B), enhanced post-training pipeline              |

---

## 🎯 Project Positioning

MiroThinker targets the **deep research** niche: tasks that require sustained multi-step reasoning, web search, document parsing, and cross-source synthesis — well beyond the capability of single-turn LLM inference.

### Problem Space

Conventional LLMs face fundamental limitations when applied to research-grade tasks:

- **Knowledge cutoff**: Static training data misses recent events and publications.
- **Context depth**: Simple RAG pipelines lack the iterative refinement needed for complex queries.
- **Tool orchestration**: Most agents cannot sustain coherent multi-step plans involving dozens of tool calls.
- **Verification**: Generated answers are frequently unverifiable or hallucinated.

### Positioning in the Research Agent Landscape

MiroThinker positions itself as a **production-grade open research agent** that competes with proprietary systems on standardized benchmarks while remaining deployable by the research community:

- Achieves **88.2 BrowseComp** (MiroThinker-H1) — highest published score at the time.
- Achieves **SOTA among open-source** models on BrowseComp-ZH with the 1.7-mini (30B) model.
- Competitive on GAIA-Val-165 (80.8%) and HLE-Text (39.2%), demonstrating breadth across task types.
- Introduces **interactive scaling** as a third axis of performance improvement alongside model size and compute scaling.

### Target Users

- Academic researchers needing automated literature synthesis and hypothesis validation.
- Analysts performing competitive intelligence or market research.
- Developers building research pipelines requiring long-horizon agent infrastructure.
- AI evaluation practitioners benchmarking deep research capability.

---

## 🏗️ System Architecture

MiroThinker is built on a **reinforcement learning (RL)-trained agent** backbone, extended with search-augmented generation and multi-step tool orchestration. Its architecture spans three tiers: the base language model, the RL-trained agent policy, and the tool execution environment.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    User Query / Task                    │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              Task Planner (Long-Horizon Reasoner)       │
│  - Decomposes query into sub-tasks                      │
│  - Maintains global task state                          │
│  - Applies step-verifiable reasoning (H1 variant)       │
└──────────────┬──────────────────────┬───────────────────┘
               │                      │
               ▼                      ▼
┌──────────────────────┐  ┌───────────────────────────────┐
│  Web Search Engine   │  │  Document Parser              │
│  - Multi-query search│  │  - PDF, DOCX, PPTX, XLSX, JPG│
│  - Result ranking    │  │  - Structured extraction      │
└──────────┬───────────┘  └────────────────┬──────────────┘
           │                               │
           └──────────────┬────────────────┘
                          ▼
┌─────────────────────────────────────────────────────────┐
│             Context Manager (256K window)               │
│  - Long-context fusion of retrieved content             │
│  - Cross-document deduplication and relevance scoring   │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│          Synthesis & Answer Generation Layer            │
│  - Evidence-grounded answer construction                │
│  - Citation attachment and confidence scoring           │
└─────────────────────────────────────────────────────────┘
```

### Model Variants

| Model                  | Parameters | Context Window | Max Tool Calls | Notes                          |
|------------------------|------------|----------------|----------------|--------------------------------|
| MiroThinker-1.7-mini   | 30B        | 256K tokens    | 300            | Open-source, HuggingFace       |
| MiroThinker-1.7        | 235B       | 256K tokens    | 300            | Open-source, HuggingFace       |
| MiroThinker-H1         | Proprietary| 256K tokens    | 300+           | Hosted, step+globally verifiable|

### Training Infrastructure

- **Base model**: Dense transformer architecture at 30B and 235B scales.
- **Post-training**: Enhanced RL pipeline tailored for long-chain search and reasoning tasks.
- **Reward signal**: Task completion verified against structured answer formats and factual grounding checks.

---

## ⚙️ Core Components & Workflow

MiroThinker's runtime workflow is designed for **iterative, self-directed research** with up to 300 tool calls per task session.

### Core Components

1. **Task Decomposer** — Parses the user's research question into a directed acyclic graph of sub-goals. Tracks dependencies between sub-tasks and schedules tool calls accordingly.

2. **Search-Augmented Reasoner** — Executes web searches, reads returned documents, and integrates findings back into the reasoning chain. Supports multi-query strategies to improve recall.

3. **Document Ingestion Module** — Accepts multi-document input in standard formats:
   - `.pdf` — academic papers, reports
   - `.doc` / `.docx` — word-processed documents
   - `.ppt` / `.pptx` — slide decks
   - `.xls` / `.xlsx` — structured tabular data
   - `.jpg` / image formats — visual content with OCR-based extraction

4. **Tool Executor** — Manages the invocation and result handling of external tools. Maintains a call budget (up to 300 per task) and applies retry logic for failed tool calls.

5. **Context Fusion Engine** — Operates over the 256K-token context window to merge information from multiple retrieved documents, deduplicate overlapping content, and score relevance against the current sub-task.

6. **Answer Synthesizer** — Generates the final structured response with inline citations, confidence indicators, and optional evidence chains for auditability.

### Typical Workflow

```
1. Receive task / research question
2. Decompose into sub-goals (Task Decomposer)
3. For each sub-goal:
   a. Issue web search queries (Search-Augmented Reasoner)
   b. Retrieve and parse documents (Document Ingestion Module)
   c. Execute auxiliary tools as needed (Tool Executor)
   d. Update context window with new evidence (Context Fusion Engine)
   e. Verify sub-goal satisfaction; loop if insufficient
4. Synthesize global answer from accumulated context
5. Attach citations and return structured response
```

### Interactive Scaling

MiroThinker introduces **interactive scaling** as a distinct performance dimension:

- Allows users to guide the agent mid-task, redirecting search focus or clarifying ambiguous sub-goals.
- Demonstrated to improve benchmark scores beyond what increased model scale alone achieves.
- Enables human-in-the-loop verification for high-stakes research outputs.

---

## 🔧 Technical Details

### Context Window & Memory

MiroThinker operates with a **256K-token context window**, enabling it to hold the equivalent of multiple full academic papers, web pages, and intermediate reasoning traces simultaneously. This eliminates the need for aggressive summarization that typically degrades multi-hop reasoning quality.

### Reinforcement Learning Post-Training

The agent policy is trained via RL to maximize task completion on long-horizon research benchmarks:

- **Reward shaping**: Intermediate rewards for evidence retrieval steps, not just final answer correctness.
- **Long-chain optimization**: Gradient propagation across multi-step trajectories, enabling the model to learn search strategies rather than single-turn generation.
- **Enhanced post-training pipeline (v1.7)**: Refined reward signals and training data distribution specifically targeting BrowseComp and GAIA-style tasks.

### Tool Use Protocol

```
Tool Call Budget:  Up to 300 per task session
Retry Logic:       Automatic retry on tool failure (configurable attempts)
Tool Types:        Web search, document reader, calculator, code interpreter
Result Handling:   Structured JSON responses parsed and injected into context
```

### Verification Mechanisms

- **Step-verifiable reasoning** (MiroThinker-H1): Each reasoning step is checked for logical consistency before proceeding to the next.
- **Globally verifiable reasoning** (MiroThinker-H1): Final answers are cross-checked against retrieved evidence for factual grounding.
- Open-source models do not currently expose explicit verification APIs but are trained with implicit factual grounding objectives.

### Multi-Document Input

Unlike many research agents limited to text queries, MiroThinker accepts heterogeneous document inputs:

```python
# Conceptual API usage
agent = MiroThinker(model="MiroThinker-1.7")
result = agent.research(
    query="Summarize recent advances in protein folding prediction",
    documents=["paper1.pdf", "slides.pptx", "data.xlsx"]
)
```

### Deployment

- Models are hosted on **HuggingFace** (`miromind-ai/MiroThinker-1.7`, `miromind-ai/MiroThinker-1.7-mini`).
- Online demo available at `https://dr.miromind.ai/`.
- Self-hosted deployment supported through the open-source repository.

---

## 📊 Performance & Benchmarks

MiroThinker has been evaluated on multiple standardized benchmarks spanning web research, factual recall, and complex reasoning.

### BrowseComp Benchmark

BrowseComp evaluates an agent's ability to answer difficult, multi-hop web research questions requiring sustained search and synthesis across many pages.

| Model                        | BrowseComp Score |
|------------------------------|-----------------|
| MiroThinker-H1               | **88.2**        |
| MiroThinker-1.7              | 74.0            |
| (Prior SOTA at v0.2 release) | 17.2            |

MiroThinker-H1's 88.2 represents a substantial leap from the 17.2 achieved at v0.2, demonstrating rapid improvement through successive training iterations.

### BrowseComp-ZH (Chinese Research Benchmark)

| Model                        | BrowseComp-ZH Score | Notes                       |
|------------------------------|---------------------|-----------------------------|
| MiroThinker-1.7-mini (30B)   | **72.3**            | SOTA among open-source      |
| MiroThinker-v1.5-235B        | 71.5                | SOTA among open-source (v1.5)|

Both the 30B mini and the 235B v1.5 model achieve state-of-the-art performance among open-source models on the Chinese-language variant, indicating strong multilingual generalization.

### HLE-Text (Humanity's Last Exam — Text Subset)

| Model                 | HLE-Text Score |
|-----------------------|----------------|
| MiroThinker-v1.5-235B | **39.2%**      |

HLE-Text consists of expert-level questions across academic disciplines, making 39.2% a highly competitive result for an open research agent.

### GAIA-Val-165 (General AI Assistants Benchmark)

| Model                 | GAIA-Val-165 Score |
|-----------------------|--------------------|
| MiroThinker-v1.5-235B | **80.8%**          |

GAIA measures tool-augmented reasoning across 165 validation tasks involving web search, file reading, and multi-step computation. 80.8% represents near-human performance on this benchmark.

### Performance Scaling Analysis

MiroThinker demonstrates three axes of performance improvement:

1. **Model scale**: 235B outperforms 30B on most tasks.
2. **Compute scaling**: More tool calls and longer reasoning chains improve accuracy.
3. **Interactive scaling**: Human-guided mid-task interventions further boost performance — a novel contribution.

---

## ✅ Strengths

MiroThinker offers several significant technical and practical advantages over comparable research agent systems:

- **State-of-the-art BrowseComp performance**: 88.2 (H1 variant) is the highest published score, and 74.0 (open-source 1.7) is highly competitive among publicly available models.

- **Open-source availability at scale**: Releasing both 30B and 235B models on HuggingFace enables community adoption, reproducibility, and fine-tuning — rare at this performance tier.

- **Long context window (256K tokens)**: Eliminates aggressive summarization, preserving cross-document evidence chains essential for multi-hop reasoning.

- **High tool call budget (300 per task)**: Enables sustained research trajectories that smaller-budget agents cannot complete.

- **Multilingual capability**: SOTA BrowseComp-ZH results demonstrate strong cross-lingual performance, broadening applicability beyond English-language research.

- **Multi-format document ingestion**: Accepts PDF, DOCX, PPTX, XLSX, and image files, allowing agents to work with real-world heterogeneous document sets without preprocessing.

- **Interactive scaling**: The introduction of human-in-the-loop guidance as a formal performance dimension is methodologically novel and practically useful for high-stakes tasks.

- **Rapid iteration cadence**: Five major releases from Aug 2025 to Mar 2026 demonstrate active development and responsiveness to benchmark feedback.

- **Breadth of benchmark coverage**: Strong scores across BrowseComp, BrowseComp-ZH, HLE-Text, and GAIA-Val demonstrate that improvements are generalizable rather than benchmark-specific.

- **RL-trained agent policy**: Training the agent end-to-end with task-completion rewards produces more robust multi-step strategies than prompt-engineering approaches.

---

## ⚠️ Limitations

Despite strong benchmark performance, MiroThinker has several limitations that researchers and practitioners should consider:

- **H1 variant is proprietary**: The highest-performing variant (88.2 BrowseComp) is a closed hosted service. The open-source 1.7 model trails by 14+ BrowseComp points, and the verification mechanisms of H1 are not fully disclosed.

- **Resource requirements for 235B model**: Self-hosting the full 235B parameter model requires substantial GPU infrastructure (likely 4–8× H100/A100 GPUs), limiting accessibility for smaller research groups.

- **Tool call latency at scale**: Executing up to 300 tool calls per task introduces significant wall-clock latency. Production deployments with strict SLAs may require task decomposition strategies to parallelize tool calls.

- **Limited public documentation of RL training details**: The technical paper (arXiv:2511.11793) covers v1.0; v1.5 and v1.7 training pipeline changes are described at a high level without full methodological disclosure.

- **Benchmark ceiling effects**: BrowseComp-ZH scores (71.5–72.3) are close together between the 30B and 235B models, suggesting potential ceiling effects or dataset limitations rather than true model capability differences at this task.

- **Dependency on external search APIs**: The agent's performance is coupled to the quality and availability of the underlying web search APIs. Results may degrade on private intranets or restricted-access document corpora.

- **Evaluation scope**: GAIA-Val-165 uses only 165 validation tasks; generalization to the full GAIA test set or domain-specific research tasks (e.g., clinical literature, legal documents) has not been systematically demonstrated.

- **Image understanding limited to OCR**: The `.jpg` input support appears to rely on OCR-based text extraction rather than vision-language reasoning, limiting utility for diagram-heavy or chart-rich documents.

- **No persistent memory across sessions**: Each research task starts from a clean context, requiring re-retrieval of previously found information in follow-up queries.

---

## 🔗 Related Work

MiroThinker exists within a rapidly growing ecosystem of autonomous research agents. The following systems represent key points of comparison:

### Direct Competitors

| System             | Organization     | Key Differentiator                                          |
|--------------------|------------------|-------------------------------------------------------------|
| GPT Researcher     | Assaf Elovic     | Open-source; modular research pipeline; widely adopted      |
| deep-research      | OpenAI           | Integrated into ChatGPT; closed-source; strong general use  |
| DeerFlow           | ByteDance        | Multi-agent workflow with specialized sub-agents            |
| Open Deep Research | HuggingFace      | Fully open replication of deep research paradigm            |

### Complementary Systems

| System              | Focus                                                        |
|---------------------|--------------------------------------------------------------|
| STORM               | Wikipedia-style long-form article generation                 |
| CognitiveKernel-Pro | Cognitive architecture for persistent agent memory           |

### Methodological Predecessors

- **WebGPT** (OpenAI, 2021): Pioneered RL-from-human-feedback for web-assisted question answering — foundational for MiroThinker's RL approach.
- **ReAct** (Yao et al., 2022): Introduced the reasoning-action loop that underpins most modern tool-using agents including MiroThinker.
- **Toolformer** (Schick et al., 2023): Self-supervised tool use as a pretraining objective — contrasts with MiroThinker's RL post-training strategy.
- **GAIA** (Mialon et al., 2023): The benchmark that helped define the deep research agent evaluation landscape.

### Benchmark Context

- **BrowseComp** was introduced by OpenAI to measure the hardest web research tasks; MiroThinker-H1's 88.2 surpasses publicly reported scores from GPT-4o and comparable proprietary systems at the time.
- **HLE** (Scale AI) represents perhaps the most challenging factual reasoning benchmark; MiroThinker's 39.2% on the text subset places it among top-performing agentic systems.

---

## 📎 References

1. **MiroThinker Technical Paper (v1.0)**  
   arXiv:2511.11793. MiroMind AI, 2025.  
   https://arxiv.org/abs/2511.11793

2. **MiroThinker GitHub Repository**  
   MiroMind AI. https://github.com/MiroMindAI/MiroThinker

3. **MiroThinker HuggingFace Models**  
   - `miromind-ai/MiroThinker-1.7`: https://huggingface.co/miromind-ai/MiroThinker-1.7  
   - `miromind-ai/MiroThinker-1.7-mini`: https://huggingface.co/miromind-ai/MiroThinker-1.7-mini

4. **MiroMind AI Website**  
   https://miromind.ai/

5. **MiroThinker Online Demo**  
   https://dr.miromind.ai/

6. **BrowseComp Benchmark**  
   OpenAI. BrowseComp: A Benchmark for Web Research Agents, 2025.

7. **GAIA: A Benchmark for General AI Assistants**  
   Mialon et al., 2023. https://arxiv.org/abs/2311.12983

8. **HLE: Humanity's Last Exam**  
   Scale AI. https://scale.com/hle

9. **ReAct: Synergizing Reasoning and Acting in Language Models**  
   Yao et al., NeurIPS 2022. https://arxiv.org/abs/2210.03629

10. **WebGPT: Browser-Assisted Question-Answering with Human Feedback**  
    Nakano et al., OpenAI, 2021. https://arxiv.org/abs/2112.09332

11. **STORM: Assisting in Writing Wikipedia-like Articles**  
    Shao et al., 2024. https://arxiv.org/abs/2402.14207

12. **GPT Researcher**  
    Assaf Elovic. https://github.com/assafelovic/gpt-researcher

13. **Open Deep Research**  
    HuggingFace. https://github.com/huggingface/smolagents/tree/main/examples/open_deep_research

14. **DeerFlow**  
    ByteDance. https://github.com/bytedance/deer-flow

---

*Report generated for the Awesome-Auto-Research repository. Last updated: 2026-03.*
