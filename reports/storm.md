# STORM — Synthesis of Topic Outlines through Retrieval and Multi-perspective Question Asking
> A Stanford OVAL system that autonomously generates Wikipedia-quality, fully-cited long-form articles from scratch using multi-perspective dialogue and structured retrieval.

---

## 📌 Project Overview

**STORM** (Synthesis of Topic Outlines through Retrieval and Multi-perspective Question Asking) is an open-source research-writing system developed by the **Stanford Open Virtual Assistant Lab (OVAL)**. Given only a topic string, STORM autonomously generates a complete, Wikipedia-style article complete with a hierarchical outline, well-organized sections, and inline citations anchored to real web sources.

The system was introduced in the paper *"Assisting in Writing Wikipedia-like Articles From Scratch with Large Language Models"* (Shao et al., NAACL 2024) and has since been extended with an interactive variant, **Co-STORM**, published at EMNLP 2024.

| Attribute | Detail |
|---|---|
| Repository | https://github.com/stanford-oval/storm |
| Paper | Shao et al., NAACL 2024 |
| License | MIT |
| Core Stack | Python, DSPy, LiteLLM, Streamlit |
| Primary Use Case | Long-form knowledge synthesis and article generation |
| Variants | STORM (automated), Co-STORM (human-in-the-loop) |

STORM addresses a key limitation of naive LLM article generation: hallucination and lack of citations. By grounding every claim through web retrieval and simulating multiple perspectives during the research phase, the system produces content that is significantly more accurate and encyclopedic than direct prompting.

---

## 🎯 Project Positioning

STORM positions itself at the intersection of **retrieval-augmented generation (RAG)** and **automated long-form writing**, aiming specifically at the Wikipedia article creation use case — a well-defined, high-quality target that allows for objective evaluation.

### Target Users
- Researchers needing quick literature overviews
- Knowledge management teams building internal wikis
- Educators creating structured topic summaries
- Developers integrating automated knowledge synthesis into pipelines

### Differentiators vs. Simple RAG
| Dimension | Naive RAG | STORM |
|---|---|---|
| Retrieval triggers | Single query | Multiple perspective-guided queries |
| Coverage | Narrow, single-view | Broad, multi-angle |
| Structure | Flat paragraphs | Hierarchical outline |
| Citations | Optional, post-hoc | Mandatory, grounded per claim |
| Collaboration | None | Co-STORM offers human steering |

STORM does not attempt to replace expert human writing. Instead, it accelerates the **pre-writing and drafting** stages that consume the most research time.

---

## 🏗️ System Architecture

STORM follows a **two-phase pipeline** separated by a clear boundary: a research/retrieval phase and a writing/synthesis phase.

```
Topic Input
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│  PHASE 1 — PRE-WRITING (Research)                       │
│                                                         │
│  1. Perspective Identification                          │
│       └─ LLM generates N distinct "personas"            │
│  2. Multi-perspective Question Generation               │
│       └─ Each persona generates probing questions       │
│  3. Simulated Expert Conversations                      │
│       └─ Persona ↔ Expert LM dialogue with retrieval    │
│  4. Web Retrieval per Question                          │
│       └─ Search API → scrape → chunk → store            │
│  5. Information Aggregation                             │
│       └─ Conversation logs + snippets form a corpus     │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│  PHASE 2 — WRITING (Synthesis)                          │
│                                                         │
│  6. Outline Generation                                  │
│       └─ LLM generates hierarchical section tree        │
│  7. Section-by-section Writing                          │
│       └─ Each section grounded against corpus           │
│  8. Citation Injection                                  │
│       └─ Claims linked to retrieved source URLs         │
│  9. Final Article Assembly                              │
│       └─ Coherent stitching, intro paragraph            │
└─────────────────────────────────────────────────────────┘
    │
    ▼
Wikipedia-style Article (Markdown/HTML) + Reference List
```

### Infrastructure Components

```
storm/
├── knowledge_storm/
│   ├── storm_wiki/              # Core STORM pipeline modules
│   │   ├── modules/             # DSPy modules (perspectives, QA, writing)
│   │   └── engine.py            # STORMWikiRunner orchestration
│   ├── collaborative_storm/     # Co-STORM extension
│   ├── interface.py             # Abstract base classes
│   ├── lm.py                    # LiteLLM wrapper
│   └── rm.py                    # Retrieval module abstractions
├── frontend/
│   └── demo_util/               # Streamlit UI utilities
├── examples/
│   └── storm_examples/          # Runner scripts
└── requirements.txt
```

---

## ⚙️ Core Components & Workflow

### 1. Perspective Identification

The system prompts an LLM to generate a set of **N distinct perspectives** (typically 3–5) that a thorough Wikipedia article on the topic would need to address. Each perspective is represented as a named "persona" with a description of their viewpoint.

```python
# DSPy Signature (conceptual)
class IdentifyPerspectives(dspy.Signature):
    """Generate N distinct perspectives for researching a topic."""
    topic = dspy.InputField()
    perspectives = dspy.OutputField(desc="List of persona descriptions")
```

Example for topic *"Quantum Computing"*:
- **Physics Researcher**: focuses on qubit implementations, decoherence
- **Software Engineer**: focuses on programming models, Qiskit, error correction
- **Business Analyst**: focuses on commercial timelines, investments, IBM/Google
- **Philosopher/Ethicist**: focuses on societal implications, cryptography risks

### 2. Simulated Conversation Engine

The core innovation of STORM is its **conversation simulation**. For each persona, STORM instantiates a **dialogue loop** between two LLM roles:
- **Questioner** (the persona): asks probing, specific questions about the topic
- **Expert Answerer**: retrieves web content and synthesizes answers

```
Persona Questioner  ←→  Expert Answerer
        │                      │
   asks question          runs search query
        │                search_api(question)
        │                      │
        │              retrieve top-k results
        │                      │
        │           synthesize answer with citations
        ◄──────────────────────┘
   follow-up or next question
```

The conversation continues for a configurable number of turns (default: 3–5 per persona). This multi-turn format encourages depth — the questioner can ask follow-ups when an answer is incomplete.

All conversation transcripts and their associated retrieved documents form the **knowledge base** for the writing phase.

### 3. Web Retrieval Integration

STORM abstracts retrieval through a `Retriever` interface, supporting:

| Search Backend | Class | Notes |
|---|---|---|
| You.com | `YouRM` | Recommended default |
| Bing | `BingSearch` | Requires API key |
| Google | `GoogleSearch` | Custom Search Engine |
| Brave | `BraveRM` | Privacy-focused |
| Tavily | `TavilySearchRM` | AI-optimized search |
| SearXNG | `SearXNGRM` | Self-hosted, FOSS |
| DuckDuckGo | `DuckDuckGoSearchRM` | No API key needed |

Each retrieval call fetches top-k snippets, which are stored with source URL metadata for downstream citation.

### 4. Outline Generation

After the research corpus is assembled, STORM generates a **hierarchical outline**:

```python
class GenerateOutline(dspy.Signature):
    """Generate a Wikipedia-style section outline."""
    topic = dspy.InputField()
    old_outline = dspy.InputField()   # optional: from prior iteration
    information = dspy.InputField()   # conversation logs and snippets
    outline = dspy.OutputField()      # H2/H3 hierarchy
```

The outline is refined in multiple rounds — a "draft" outline is first generated, then refined using the conversation corpus to ensure it covers all discovered sub-topics.

### 5. Section Writing with Citation Grounding

Each section is written independently using the outline as structure and the research corpus as evidence:

```python
class WriteSection(dspy.Signature):
    """Write a Wikipedia-style section grounded with citations."""
    topic = dspy.InputField()
    section_title = dspy.InputField()
    section_outline = dspy.InputField()
    retrieved_passages = dspy.InputField()
    section_content = dspy.OutputField()  # Markdown with [1][2] refs
```

Claims in the output are linked to specific passages, ensuring **every statement is traceable** to a retrieved source.

### 6. Co-STORM: Collaborative Discourse

Co-STORM extends STORM by introducing a **human participant** into the research conversation. Instead of fully simulating the questioner, a real user can:
- Inject questions into the dialogue
- Redirect the research toward their interests
- Accept or reject proposed outline sections
- Mark information as already known (to avoid repetition)

Co-STORM introduces a **Discourse Manager** that coordinates between human inputs and the automated expert agents, maintaining a coherent research thread across interruptions.

---

## 🔧 Technical Details

### DSPy Integration

STORM is built entirely on **DSPy** (Declarative Self-improving Python), Stanford's framework for compositional LM programming.

Key DSPy concepts used:

| Concept | STORM Usage |
|---|---|
| `dspy.Signature` | Defines typed I/O contracts for every LM call |
| `dspy.Module` | Encapsulates multi-step LM logic (e.g., question generation) |
| `dspy.ChainOfThought` | Used for reasoning-heavy steps (outline refinement) |
| `dspy.Retrieve` | Integrated with custom retrieval modules |
| Optimizers | Can use `BootstrapFewShot` to tune prompts with examples |

DSPy allows STORM modules to be **optimized** with a set of annotated examples, improving output quality without manual prompt engineering.

### LiteLLM Backend

STORM uses **LiteLLM** as a unified interface layer for LLM providers:

```python
from knowledge_storm.lm import LiteLLMModel

lm = LiteLLMModel(
    model="gpt-4o",
    api_key=os.environ["OPENAI_API_KEY"],
    max_tokens=4096,
    temperature=0.1
)
```

Supported providers via LiteLLM: OpenAI, Anthropic Claude, Google Gemini, Azure OpenAI, Cohere, Mistral, Ollama (local), Groq, Together AI, and any OpenAI-compatible endpoint.

### STORMWikiRunner

The main orchestration class:

```python
from knowledge_storm import STORMWikiRunnerArguments, STORMWikiRunner

args = STORMWikiRunnerArguments(
    output_dir="./output",
    max_conv_turn=3,
    max_perspective=5,
    search_top_k=3,
    retrieve_top_k=10,
)

runner = STORMWikiRunner(args, lm_configs, retrieval_module)
runner.run(topic="Quantum Error Correction", do_research=True, do_generate_outline=True, do_generate_article=True, do_polish_article=True)
```

### Citation Tracking System

Retrieved passages are stored in an `InformationTable` with:
- `url`: source URL
- `title`: page title  
- `snippets`: list of relevant text chunks
- `citation_id`: integer assigned at storage time

During writing, the model outputs `[citation_id]` inline markers. A post-processing step validates that all cited IDs exist in the `InformationTable` and assembles the final reference list.

### Streamlit Web UI

The STORM-Wiki UI is a Streamlit app providing:
- Topic input field
- Real-time progress display (which phase is running)
- Collapsible section viewer for the final article
- Citation sidebar linking to source URLs
- Export to Markdown

---

## 📊 Performance & Benchmarks

### Human Evaluation (NAACL 2024)

The paper evaluated STORM-generated articles against human-written Wikipedia articles using crowdsourced evaluators:

| Metric | STORM | GPT-4 Baseline | Human Wikipedia |
|---|---|---|---|
| Breadth of Coverage | 4.1 / 5 | 3.2 / 5 | 4.5 / 5 |
| Citation Accuracy | 87% | 41% | 98% |
| Factual Density | High | Medium | High |
| Structure Quality | 4.0 / 5 | 2.8 / 5 | 4.6 / 5 |

### Quantitative Metrics

| Metric | Value |
|---|---|
| Average article length | ~2,000–4,000 words |
| Average citations per article | 25–50 |
| Avg. unique perspectives explored | 4–5 |
| Total retrieval calls per article | 40–80 |
| End-to-end latency (GPT-4o) | ~3–8 minutes |

### Co-STORM Evaluation (EMNLP 2024)

Co-STORM was evaluated on user satisfaction and coverage:
- Users reported **31% higher satisfaction** than automated STORM
- **Coverage** of user-specified subtopics improved by ~22%
- Conversational naturalness rated higher than alternatives

### Cost Estimates (GPT-4o)

| Component | Approx. Token Cost |
|---|---|
| Perspective generation | ~500 tokens |
| Per conversation turn | ~800–1,200 tokens |
| Outline generation | ~1,500 tokens |
| Per section write | ~2,000 tokens |
| **Total per article** | **~40,000–80,000 tokens** |

---

## ✅ Strengths

1. **Citation Grounding by Design**: Unlike systems that add citations post-hoc, STORM's retrieval is integral to the writing process — every section is written against retrieved evidence, dramatically reducing hallucination.

2. **Multi-perspective Coverage**: The persona-based question generation systematically explores a topic from multiple angles, producing more balanced and comprehensive coverage than single-pass generation.

3. **Modular, Swappable Components**: Both the LLM backend (via LiteLLM) and the retrieval backend (via pluggable RM classes) are fully configurable, enabling deployment with local models or self-hosted search.

4. **DSPy-Powered Optimization**: Because STORM is built on DSPy signatures, individual modules can be optimized with few-shot examples, allowing quality improvement without rewriting prompts.

5. **Production-Ready Tooling**: The Streamlit UI, CLI runners, and FastAPI compatibility make STORM deployable as an end-user-facing product, not just a research demo.

6. **Co-STORM Human-in-Loop Extension**: The collaborative extension preserves the value of human expert knowledge while leveraging automation for breadth — a thoughtful blend of AI and human.

7. **Well-Documented Research Basis**: Published at NAACL (STORM) and EMNLP (Co-STORM), both top-tier NLP venues, providing strong scientific grounding.

8. **Active Maintenance**: The Stanford OVAL team actively maintains the repository with regular updates and community engagement.

---

## ⚠️ Limitations

1. **Search API Cost and Rate Limits**: Heavy reliance on external search APIs means production use incurs significant per-article API costs and can hit rate limits for bulk generation.

2. **Latency**: A full article generation run takes 3–8 minutes even with GPT-4o. This is unsuitable for real-time interactive use cases.

3. **Quality Ceiling on Niche Topics**: For topics with sparse web presence, retrieval returns low-quality or irrelevant results, degrading article quality proportionally.

4. **Citation Hallucination Residual Risk**: While citation accuracy (87%) is far above baselines, ~13% of citations may link to sources that do not perfectly support the cited claim.

5. **English-Centric**: The system and its evaluation are optimized for English content. Non-English retrieval and generation quality degrades significantly.

6. **Outline Rigidity**: The outline-then-write approach can produce articles that feel formulaic — sections are not always organically connected in terms of narrative flow.

7. **No Real-time Information**: Results are only as current as the search index at the time of the query. Dynamic, rapidly-changing topics may yield outdated articles.

8. **Compute Requirements for Local LLMs**: Running STORM with local LLMs (via Ollama) requires significant VRAM (≥16GB for quality outputs) and incurs much higher latency.

9. **Co-STORM Complexity**: The collaborative mode requires more user involvement than typical tools, which may frustrate users expecting fully automatic results.

---

## 🔗 Related Work

| Project | Relationship |
|---|---|
| **GPT-Researcher** | Similar multi-agent web research; less focus on Wikipedia structure, more on report formats |
| **DeerFlow (ByteDance)** | Similar multi-agent pipeline; adds code execution sandbox; STORM more citations-focused |
| **OpenScholar** | Shares citation grounding philosophy; OpenScholar targets scientific literature specifically |
| **Perplexity AI** | Commercial product with similar retrieve-and-synthesize concept; proprietary, shorter outputs |
| **AutoGPT** | Earlier general-purpose autonomous agent; not specialized for long-form writing |
| **DSPy** | STORM is the flagship application of DSPy; they share the same Stanford OVAL lab |
| **WebGPT (OpenAI)** | Pioneered web-augmented generation for factual Q&A; STORM extends to long-form articles |
| **Factored Cognition** | Theoretical framework for decomposing complex tasks that influenced STORM's design |

---

## 📎 References

1. Shao, Y., Jiang, Y., Kanell, T., Xu, P., Khattab, O., & Lam, M. (2024). **Assisting in Writing Wikipedia-like Articles From Scratch with Large Language Models**. In *Proceedings of NAACL 2024*. https://arxiv.org/abs/2402.14207

2. Jiang, Y., Shao, Y., et al. (2024). **Into the Unknown Unknowns: Engaged Human Learning through Participation in Language Model Agent Conversations** (Co-STORM). In *Proceedings of EMNLP 2024*. https://arxiv.org/abs/2408.15232

3. Khattab, O., Singhvi, A., Maheshwari, P., Zhang, Z., et al. (2023). **DSPy: Compiling Declarative Language Model Calls into Self-Improving Pipelines**. arXiv preprint. https://arxiv.org/abs/2310.03714

4. STORM GitHub Repository. Stanford OVAL. https://github.com/stanford-oval/storm

5. LiteLLM Documentation. BerriAI. https://docs.litellm.ai/

6. Lewis, P., Perez, E., et al. (2020). **Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks**. In *NeurIPS 2020*. https://arxiv.org/abs/2005.11401

7. Wikimedia Foundation. (2024). **Wikipedia: Manual of Style**. https://en.wikipedia.org/wiki/Wikipedia:Manual_of_Style

8. Min, S., et al. (2023). **FActScoring: Fine-grained Atomic Evaluation of Factual Precision in Long Form Text Generation**. In *EMNLP 2023*. https://arxiv.org/abs/2305.14251

9. OpenAI. (2024). **GPT-4o Technical Report**. https://openai.com/research/gpt-4o

10. Zhu, Y., et al. (2024). **LongRAG: Enhancing Retrieval-Augmented Generation with Long-context LLMs**. arXiv preprint. https://arxiv.org/abs/2406.15319

---

*Report generated for Awesome-Auto-Research. Last updated: 2025.*
