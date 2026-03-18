# II-Researcher — BAML-Powered Deep Search Agent
> Intelligent Internet's open-source deep research framework using BAML-structured LLM functions; 84.12% on Google's Frames multi-hop benchmark.

---

## 📌 Project Overview

**II-Researcher** is an open-source deep search agent developed by [Intelligent Internet (ii.inc)](https://www.ii.inc), designed to perform intelligent, multi-step web research and generate comprehensive, citation-backed answers to complex questions.

| Attribute        | Value                                                              |
|------------------|--------------------------------------------------------------------|
| Repository       | https://github.com/Intelligent-Internet/ii-researcher             |
| Organization     | Intelligent Internet (ii.inc)                                     |
| Stars            | 495                                                               |
| PyPI Package     | `pip install ii-researcher`                                       |
| License          | Open Source                                                       |
| Blog Post        | https://www.ii.inc/web/blog/post/ii-researcher                    |
| Key Benchmark    | **84.12%** on Google Frames (multi-hop fact-checking)             |
| Best Model       | DeepSeek-R1-0528                                                  |

II-Researcher distinguishes itself through its use of **BAML (Boundary-annotated Markup Language)** for structured LLM function definitions, enabling precise, type-safe interactions with language models. The system combines agentic search loops, multi-step reasoning, and vector-based context compression into a cohesive research pipeline deployable via Docker or as a Python package.

Key capabilities include:
- Autonomous multi-hop web research with source verification
- Configurable LLM backends for different subtasks (planning, reasoning, synthesis)
- Support for multiple search providers (Tavily, SerpAPI) and scraping backends (Firecrawl, Browser, BS4, Tavily)
- MCP (Model Context Protocol) server integration for toolchain interoperability

---

## 🎯 Project Positioning

II-Researcher targets the **agentic deep research** segment of the AI tooling landscape, occupying the intersection of structured LLM orchestration and automated information synthesis.

### Target Use Cases
- **Complex question answering** requiring synthesis of multiple web sources
- **Fact-checking and verification** over multi-hop reasoning chains
- **Research automation** for knowledge workers, analysts, and developers
- **Developer tooling** via MCP server integration into LLM-powered workflows

### Differentiation from Peers

| System            | Search Strategy       | LLM Structuring | Context Management     | Open Source |
|-------------------|-----------------------|-----------------|------------------------|-------------|
| II-Researcher     | Agentic loop + reflection | BAML          | Vector compression     | ✅          |
| GPT Researcher    | Parallel web scraping | Prompt-based    | Chunking               | ✅          |
| Perplexity AI     | Index-backed search   | Proprietary     | Proprietary            | ❌          |
| OpenAI Deep Research | Browser use agent  | Function calls  | Summarization          | ❌          |
| LangGraph Research | Graph-based agent    | LCEL / Tools    | Retrieval-augmented    | ✅          |

II-Researcher's primary differentiator is **BAML-driven structured function definitions**, which enforce schema-level contracts between orchestration logic and LLM outputs, reducing hallucination drift in agentic pipelines.

---

## 🏗️ System Architecture

II-Researcher follows a **layered agentic architecture** where a planning agent coordinates search, retrieval, and synthesis modules, each backed by independently configurable LLM models.

```
┌─────────────────────────────────────────────────────────┐
│                     User Query                          │
└────────────────────────┬────────────────────────────────┘
                         │
              ┌──────────▼──────────┐
              │   Planning Agent    │  ← Planning LLM
              │  (BAML-structured)  │
              └──────────┬──────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
  ┌──────▼──────┐ ┌──────▼──────┐ ┌─────▼──────┐
  │ Search Layer│ │Scrape Layer │ │ Reflection │
  │ Tavily/SERP │ │FC/BS4/Brwsr │ │   Agent    │
  └──────┬──────┘ └──────┬──────┘ └─────┬──────┘
         │               │               │
         └───────────────▼───────────────┘
                         │
              ┌──────────▼──────────┐
              │  Context Compressor │  ← text-embedding-3-large
              │  (Vector Similarity)│
              └──────────┬──────────┘
                         │
              ┌──────────▼──────────┐
              │  Synthesis Agent    │  ← Synthesis LLM
              │  (BAML-structured)  │
              └──────────┬──────────┘
                         │
              ┌──────────▼──────────┐
              │  Final Answer +     │
              │  References         │
              └─────────────────────┘
```

### Architectural Principles
- **Separation of concerns**: Planning, reasoning, and synthesis each use independently configured LLM backends
- **Schema-enforced outputs**: BAML guarantees structured, parseable responses from every LLM call
- **Asynchronous execution**: All I/O-bound operations (search, scraping) run concurrently for throughput
- **Composable pipelines**: Search strategies and reasoning methods are swappable without altering core logic

---

## ⚙️ Core Components & Workflow

### Core Components

**1. BAML Function Layer**
- Defines all LLM interactions as typed, schema-validated functions
- Enforces input/output contracts, eliminating brittle string parsing
- Enables deterministic testing and mocking of LLM calls

**2. Planning Agent**
- Decomposes user queries into structured sub-questions
- Determines search strategies and iteration depth
- Manages the agentic loop: search → scrape → reflect → refine

**3. Search Providers**
- **Tavily**: AI-optimized search API with relevance scoring
- **SerpAPI**: Google Search integration for broad coverage

**4. Web Scraping Backends**
- **Firecrawl**: Structured extraction from complex web pages
- **Browser**: Headless browser for JavaScript-rendered content
- **BS4 (BeautifulSoup4)**: Lightweight HTML parsing for static pages
- **Tavily**: Combined search-and-extract mode

**5. Reflection Agent**
- Evaluates sufficiency of retrieved information
- Identifies knowledge gaps and triggers additional search iterations
- Powered by a configurable reasoning LLM (e.g., DeepSeek-R1)

**6. Vector-Based Context Compressor**
- Embeds retrieved content chunks using `text-embedding-3-large`
- Filters by cosine similarity threshold (0.3) against query embedding
- Enforces output cap (4096 words) from input window (32,000 words)

**7. Synthesis Agent**
- Produces final comprehensive answer from compressed context
- Generates inline citations and reference lists
- Structured via BAML for consistent output formatting

### Agentic Search Loop

```
Query → Plan → [Search → Scrape → Compress → Reflect] × N → Synthesize → Answer
             ↑_______________________________________|
                      (loop until sufficient)
```

### MCP Server Integration

II-Researcher exposes a **Model Context Protocol (MCP) server**, allowing it to be used as a tool by other LLM agents and IDE integrations (e.g., Cursor, Claude Desktop).

---

## 🔧 Technical Details

### Installation & Setup

```bash
# Via PyPI
pip install ii-researcher

# Via Docker Compose
git clone https://github.com/Intelligent-Internet/ii-researcher
cd ii-researcher
docker compose up
```

### Environment Configuration

```env
# Search Providers
TAVILY_API_KEY=...
SERPAPI_API_KEY=...

# LLM Backends (independently configurable)
PLANNING_MODEL=gpt-4o
REASONING_MODEL=deepseek-r1-0528
SYNTHESIS_MODEL=gpt-4o

# Scraping
FIRECRAWL_API_KEY=...
```

### BAML Function Example (conceptual)

```python
# BAML defines typed LLM function contracts
function PlanResearch(query: string) -> ResearchPlan {
  client GPT4o
  prompt #"
    Decompose the following query into structured sub-questions
    for web research: {{ query }}
  "#
}

class ResearchPlan {
  sub_questions string[]
  search_strategy SearchStrategy
  max_iterations int
}
```

### Vector Compression Configuration

| Parameter           | Value                   |
|---------------------|-------------------------|
| Embedding Model     | `text-embedding-3-large` |
| Similarity Threshold | 0.3 (cosine)           |
| Max Output Words    | 4,096                   |
| Max Input Words     | 32,000                  |

### Configurable LLM Assignment

The system allows assigning different models to different roles:
- **Planning**: Fast, instruction-following models (e.g., GPT-4o)
- **Reasoning/Reflection**: High-capability reasoning models (e.g., DeepSeek-R1-0528)
- **Synthesis**: Fluent, long-context models for answer generation

This heterogeneous model assignment optimizes cost-performance tradeoffs across the pipeline.

### Deployment Options
- **Local Python**: `pip install ii-researcher` + CLI
- **Docker**: Single-container deployment
- **Docker Compose**: Multi-service orchestration with environment isolation
- **MCP Server**: Embedded tool server for agent frameworks

---

## 📊 Performance & Benchmarks

### Frames Benchmark Results

The **Frames benchmark** (Google, 2024) is a multi-hop fact-checking evaluation requiring systems to retrieve and reason over multiple web sources to answer complex factual questions. It tests: multi-step information retrieval, cross-source reasoning, and factual precision.

| Model                   | Score on Frames |
|-------------------------|-----------------|
| II-Researcher (DeepSeek-R1-0528) | **84.12%** |
| GPT-4o baseline (reported) | ~49.0%    |
| Human performance       | ~85.0%          |

> **84.12%** places II-Researcher near human-level performance on Frames, substantially outperforming standard RAG and single-step retrieval baselines.

### Performance Characteristics

- **Asynchronous search**: Parallel execution of search and scraping reduces latency
- **Configurable depth**: Number of agentic loop iterations trades off latency vs. coverage
- **Context efficiency**: Vector compression prevents LLM context overflow on document-heavy queries
- **Model sensitivity**: Performance scales with reasoning model capability (DeepSeek-R1 > GPT-4o for multi-hop)

### Benchmark Context

The Frames benchmark is particularly demanding because:
1. Questions require chaining facts from 2–15 separate web sources
2. No single source contains the complete answer
3. Systems must detect and resolve conflicting information
4. Temporal reasoning and entity disambiguation are required

---

## ✅ Strengths

1. **BAML-enforced structure**: Schema-validated LLM outputs eliminate brittle string parsing and improve pipeline reliability across all agents in the system.

2. **Near-human Frames performance**: 84.12% on Google's Frames benchmark demonstrates genuine multi-hop reasoning capability, approaching the ~85% human ceiling.

3. **Heterogeneous model assignment**: Planning, reasoning, and synthesis can each use the best-fit model, enabling cost-performance optimization without architectural changes.

4. **Multiple search and scraping backends**: Support for Tavily, SerpAPI, Firecrawl, BS4, and headless browser provides resilience and flexibility across different web content types.

5. **Vector-based context compression**: Embedding-driven chunk filtering efficiently manages long retrieved contexts without naive truncation, preserving the most relevant information.

6. **Asynchronous architecture**: Concurrent I/O operations across search and scraping stages reduce end-to-end latency significantly compared to sequential pipelines.

7. **MCP server support**: Native integration with the Model Context Protocol enables II-Researcher to serve as a composable tool within broader LLM agent ecosystems and IDEs.

8. **Easy deployment**: PyPI package, Docker, and Docker Compose options lower the barrier to integration across development and production environments.

9. **Customizable pipelines**: Reasoning methods and search strategies are modular, allowing domain-specific adaptations without forking core logic.

10. **Active open-source development**: 495 stars and active maintenance by Intelligent Internet's research team signal a healthy contribution trajectory.

---

## ⚠️ Limitations

1. **API cost exposure**: The pipeline requires multiple API calls per query (search providers + LLM calls for planning, reflection, synthesis), which can make per-query costs significant for high-volume deployments.

2. **Latency on deep queries**: Multi-iteration agentic loops with web scraping introduce non-trivial latency (potentially 30–120 seconds per query), limiting real-time use cases.

3. **Search provider dependency**: Core functionality requires paid API access to Tavily and/or SerpAPI; no fully offline or self-hosted search option is available out of the box.

4. **BAML learning curve**: Developers unfamiliar with BAML must learn its schema and tooling before extending or customizing LLM function definitions.

5. **Scraping fragility**: Web scraping backends (BS4, Browser) are inherently brittle against site structure changes, anti-bot measures, and JavaScript-heavy SPAs.

6. **Similarity threshold sensitivity**: The cosine similarity threshold (0.3) for context compression is a global parameter; suboptimal values may discard relevant content or retain noise depending on query type.

7. **No persistent memory**: The system does not maintain cross-session memory or a knowledge base, requiring full re-retrieval for repeated or related queries.

8. **Benchmark generalizability**: The 84.12% Frames result was achieved with DeepSeek-R1-0528; performance with weaker or different reasoning models may vary substantially.

9. **Limited structured data support**: The pipeline is optimized for unstructured web text; tables, PDFs, and databases require additional preprocessing not natively handled.

---

## 🔗 Related Work

### Direct Predecessors & Inspirations

- **GPT Researcher** (Assaf Elovic, 2023): Parallel web research agent; II-Researcher extends the paradigm with BAML structuring and vector compression.
- **WebGPT** (OpenAI, 2021): Early demonstration of LLM-driven web browsing for factual QA; foundational reference for agentic search.
- **ReAct** (Yao et al., 2022): Reasoning + Acting framework; II-Researcher's reflect-and-refine loop is a practical instantiation of ReAct principles.

### Benchmark & Evaluation

- **Frames** (Google DeepMind, 2024): The multi-hop fact-checking benchmark used as II-Researcher's primary evaluation; requires chaining 2–15 web sources.
- **GAIA** (Mialon et al., 2023): General AI assistants benchmark; complementary evaluation for agentic research systems.

### Tooling & Infrastructure

- **BAML** (Boundary ML): Structured LLM function definition language underlying II-Researcher's orchestration layer.
- **Tavily**: AI-native search API providing relevance-scored results and combined search-extract mode.
- **Firecrawl**: Web scraping service optimized for LLM-readable structured extraction.
- **Model Context Protocol (MCP)**: Anthropic's open protocol for exposing tools to LLM agents; II-Researcher implements an MCP server.

### Contemporary Systems

- **OpenAI Deep Research**: Proprietary browser-use agent with similar multi-hop research goals; closed-source.
- **Perplexity AI**: Production RAG search system; index-backed rather than live agentic retrieval.
- **LangGraph Research Agent**: Graph-orchestrated research agent in the LangChain ecosystem; complementary architectural approach.
- **Jina Reader + DeepSearch**: Jina AI's deep search pipeline combining reader APIs with LLM reasoning chains.

---

## 📎 References

1. **II-Researcher GitHub Repository** — Intelligent Internet (ii.inc)
   https://github.com/Intelligent-Internet/ii-researcher

2. **II-Researcher Blog Post** — Intelligent Internet
   https://www.ii.inc/web/blog/post/ii-researcher

3. **Frames: Factuality Evaluation of RAG with Multi-hop Sources** — Google DeepMind (2024)
   Multi-hop fact-checking benchmark used for primary evaluation.

4. **BAML (Boundary-annotated Markup Language)** — Boundary ML
   Structured LLM function definition language.
   https://www.boundaryml.com

5. **Tavily Search API** — Tavily AI
   AI-optimized search provider used for web retrieval.
   https://tavily.com

6. **Firecrawl** — Firecrawl
   Web scraping and extraction service for LLM pipelines.
   https://firecrawl.dev

7. **Model Context Protocol (MCP)** — Anthropic (2024)
   Open protocol for LLM tool interoperability.
   https://modelcontextprotocol.io

8. **GPT Researcher** — Assaf Elovic (2023)
   Open-source parallel web research agent.
   https://github.com/assafelovic/gpt-researcher

9. **ReAct: Synergizing Reasoning and Acting in Language Models** — Yao et al. (2022)
   Foundational agentic reasoning framework.
   https://arxiv.org/abs/2210.03629

10. **DeepSeek-R1** — DeepSeek AI (2025)
    Reasoning model achieving state-of-the-art results on II-Researcher Frames evaluation.
    https://github.com/deepseek-ai/DeepSeek-R1

11. **WebGPT: Browser-assisted Question-answering with Human Feedback** — Nakano et al., OpenAI (2021)
    Seminal work on LLM-driven web browsing for factual QA.
    https://arxiv.org/abs/2112.09332

12. **GAIA: A Benchmark for General AI Assistants** — Mialon et al. (2023)
    Complementary benchmark for evaluating agentic research systems.
    https://arxiv.org/abs/2311.12983

13. **SerpAPI** — SerpAPI
    Google Search integration provider.
    https://serpapi.com

14. **text-embedding-3-large** — OpenAI
    Embedding model used for vector-based context compression in II-Researcher.
    https://platform.openai.com/docs/guides/embeddings
