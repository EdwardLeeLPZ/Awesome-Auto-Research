# deep-research (dzhng)

> **Minimal reference implementation of a recursive, depth-and-breadth-configurable deep research agent. 18 000+ stars on GitHub — the most widely starred open-source deep research scaffold.**

---

## Overview

| Field | Details |
|---|---|
| **Repository** | [github.com/dzhng/deep-research](https://github.com/dzhng/deep-research) |
| **Author / Org** | David Zhang (dzhng) / Aomni |
| **Language** | TypeScript (Node.js) |
| **Created** | February 2025 |
| **Stars** | ~18 600 (as of March 2026) |
| **License** | MIT |
| **Key Dependency** | Firecrawl · Exa · OpenAI / Anthropic / any OpenAI-compatible API |

`deep-research` was released in February 2025 as a minimal, readable implementation of a *deep research agent* — a class of system that autonomously refines a research question through iterative web searches, accumulates findings across multiple rounds, then synthesises the results into a coherent markdown report. Its design philosophy prioritises clarity over capability: the full implementation fits in fewer than 500 lines of code, making it the canonical reference for anyone who wants to understand, fork, or build upon the pattern.

The repository attracted immediate community attention and quickly became one of the most-forked AI-agent projects of early 2025, directly inspiring several downstream projects including LangChain's Open Deep Research and ByteDance's DeerFlow.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     User Input                          │
│              Query · Breadth · Depth                    │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Deep Research Orchestrator                  │
│                                                         │
│   ┌─────────────┐    ┌──────────────┐                   │
│   │ Query       │    │  SERP Query  │                   │
│   │ Generator   │───▶│  Executor    │                   │
│   │ (LLM)       │    │  (Firecrawl/ │                   │
│   └─────────────┘    │   Exa)       │                   │
│                       └──────┬───────┘                   │
│                              │                           │
│                              ▼                           │
│                    ┌──────────────────┐                  │
│                    │  Result Processor │                  │
│                    │  (LLM extraction) │                  │
│                    └────────┬─────────┘                  │
│                             │                            │
│                  ┌──────────┴──────────┐                 │
│                  ▼                     ▼                 │
│           ┌──────────┐         ┌────────────┐            │
│           │ Learnings │         │ Directions │            │
│           │ (facts)   │         │ (next Qs)  │            │
│           └──────────┘         └─────┬──────┘            │
│                                      │                   │
│                              depth > 0 ?                 │
│                           yes ▼         no ▼             │
│                    ┌──────────────┐  ┌────────────────┐  │
│                    │ Recurse with │  │ Final Report   │  │
│                    │ new context  │  │ Generator (LLM)│  │
│                    └──────────────┘  └────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

The architecture is deliberately flat. There is no database, no persistent memory across runs, and no separate agent framework. The entire loop is implemented as a recursive TypeScript function that propagates accumulated learnings and follow-up directions into the next search round.

---

## Core Workflow

### Step 1 — Initial Query Clarification

Upon receiving a user query, the agent optionally generates clarifying follow-up questions to sharpen the research goal. This ensures that vague or multi-faceted queries are decomposed before the expensive search phase begins.

### Step 2 — SERP Query Generation

The LLM generates `breadth` parallel search queries tailored to the current research goal plus any accumulated context from prior rounds. The number of queries per round equals the **breadth** parameter (default: 3–5).

### Step 3 — Parallel Web Search and Scraping

Each generated query is submitted to the configured search backend (Firecrawl or Exa) concurrently. Results are scraped at the page level, not just the snippet level, giving the LLM access to full article text rather than just titles and summaries.

### Step 4 — Extraction and Structuring

A dedicated LLM pass over each scraped page extracts:
- **Learnings** — discrete factual statements relevant to the research goal.
- **Follow-up Directions** — new questions raised by the content that should be explored in the next depth level.

### Step 5 — Recursion (depth > 0)

If the remaining depth count is greater than zero, the agent constructs a new research context combining:
- The original research goal.
- All accumulated learnings from previous rounds.
- The most promising follow-up directions from the current round.

This context drives the next recursion. The effective number of searches grows as `breadth × depth` rounds, bounded by the configurable parameters.

### Step 6 — Final Report Synthesis

When depth reaches zero, all accumulated learnings are concatenated and fed to the LLM with a synthesis prompt. The output is a structured Markdown report with inline citations linking back to the source URLs discovered during search.

---

## Key Features

- **Configurable research depth and breadth** — two integer parameters that independently control how deep (recursion levels) and how wide (parallel queries per level) the search goes.
- **Iterative query refinement** — each recursive call receives the full prior-round context, allowing queries to become progressively more specific.
- **Full-page scraping** — uses Firecrawl or Exa to retrieve complete page content, not just search snippets, for richer LLM extraction.
- **Concurrent search execution** — all queries at a given depth level run in parallel, keeping latency proportional to depth rather than breadth × depth.
- **Provider-agnostic LLM backend** — uses any OpenAI-compatible API endpoint; works with GPT-4o, Claude, Gemini, and local models via LM Studio or similar.
- **Minimal codebase** — <500 lines total, no agent framework dependency, designed for easy forking and modification.
- **Markdown report output** — final synthesis produces a cited, structured markdown document suitable for further editing.
- **TypeScript / Node.js** — runs in any Node 18+ environment; no Python dependency.

---

## Technical Implementation

### Language & Runtime

TypeScript compiled to JavaScript, executed in Node.js 18+. The repo ships with a `package.json` and uses `pnpm` or `npm` for dependency management.

### Search Backends

| Backend | API Type | Strength |
|---------|----------|----------|
| **Firecrawl** | REST (paid) | Full-page markdown extraction, JavaScript rendering |
| **Exa** | REST (paid) | Neural search, semantic query understanding |

Both backends return full page content rather than just URLs, which is the key technical differentiator over simple SERP-only approaches.

### LLM Integration

The system uses the AI SDK (`ai` npm package) with support for:
- OpenAI (gpt-4o, o1)
- Anthropic Claude
- Google Gemini
- Any OpenAI-compatible endpoint

Prompts are structured JSON outputs using the AI SDK's `generateObject` function, ensuring typed, parseable LLM responses for both extraction and synthesis steps.

### Concurrency Model

Parallel search at each depth level is implemented with `Promise.all`, with an optional concurrency limiter (`p-limit`) to avoid overwhelming rate limits. The processing pipeline is:

```
depth-level-start
  └─ breadth queries generated (sequential LLM call)
  └─ breadth searches executed (parallel)
  └─ breadth page-content extractions (parallel)
  └─ merge learnings + directions
  └─ recurse (depth - 1) OR synthesise
```

### Output Format

The final report is a markdown file with:
- An executive summary section
- Thematic subsections covering the research question
- Inline citations in the format `[Source: URL]`
- Appendix of all source URLs referenced

---

## Evaluation & Benchmarks

`deep-research` does not include a formal evaluation suite; the codebase is explicitly positioned as a minimal reference implementation rather than a production research system. Community evaluations have noted the following observable characteristics:

| Dimension | Observation |
|-----------|-------------|
| **Report depth** | Medium depth; sufficient for 2–4 page summaries on well-indexed topics |
| **Citation accuracy** | High — all cited URLs are from actual scraped pages |
| **Breadth coverage** | Good — parallel queries at each level surface diverse perspectives |
| **Hallucination rate** | Lower than pure LLM generation due to grounded page extraction |
| **Latency** | ~2–10 minutes for depth=3, breadth=3 with GPT-4o |
| **Cost per run** | ~$0.50–$2.00 depending on LLM choice and depth/breadth settings |

Downstream implementations that build on this codebase (Open Deep Research, DeerFlow, and others) have published comparative evaluations showing that the recursive refinement pattern consistently outperforms single-pass retrieval-augmented generation on complex multi-hop questions.

---

## Strengths

1. **Extreme simplicity** — The entire agent loop fits in a single file. This makes it the easiest starting point for researchers and engineers who want to understand or extend the deep-research pattern without learning a complex framework.

2. **Recursive context propagation** — Learnings from each round flow into subsequent queries, enabling the system to progressively drill into the most promising threads rather than treating each search independently.

3. **Full-page content extraction** — By using Firecrawl or Exa for page-level scraping rather than SERP snippets, the system gives the LLM substantially more signal per URL, improving extraction quality.

4. **Provider agnostic** — The use of the AI SDK's unified interface means the codebase works with any major LLM provider and can benefit from continued improvements in the underlying models without code changes.

5. **Widely adopted as a scaffold** — The repository's 18 000+ stars and high fork count mean that community extensions (streaming UI, tool integrations, persistence layers) are widely available.

6. **Low operational overhead** — No server, no database, no framework — just a single Node.js process. Can be run locally or deployed as a simple serverless function.

---

## Limitations

1. **No persistent memory** — State is not persisted between runs. Each invocation starts fresh, meaning the system cannot build up a knowledge base over repeated research sessions.

2. **TypeScript only** — The Python ecosystem dominates AI research tooling. Integrating `deep-research` into Python-based pipelines requires a subprocess call or port to Python.

3. **Paid search backends** — Both Firecrawl and Exa require paid API keys. There is no out-of-the-box free alternative, making production usage non-trivial for low-budget projects.

4. **No hypothesis generation** — The system is purely a synthesis and summarisation tool; it does not generate research hypotheses, experimental designs, or code — those capabilities require composition with other tools.

5. **Fixed report format** — The Markdown output is not structured for academic use (no LaTeX, no BibTeX, no figure support). Post-processing is required for any formal publication workflow.

6. **Context window limits** — At high breadth × depth settings, accumulated learnings can exceed the context window of the synthesis LLM, requiring truncation that may lose important details.

7. **No peer review or critique loop** — There is no agent that critiques the generated report or checks for consistency across sources. The final synthesis is a single LLM pass.

---

## Related Work

| System | Relationship |
|--------|-------------|
| [Open Deep Research](open-deep-research.md) | LangChain's reference implementation; explicitly derived from this codebase and adds LangGraph orchestration, MCP tool plugins, and LangSmith tracing |
| [DeerFlow](deerflow.md) | ByteDance's production implementation; adds multi-agent architecture, persistent memory, Python backend, and code execution to the same core recursive pattern |
| [GPT Researcher](gpt-researcher.md) | Parallel contemporary; Python implementation of the same category with a UI layer, LangGraph orchestration, and report export formats |
| [STORM](storm.md) | Academic precursor; introduces multi-perspective question asking before the search phase; more structured but less recursive than deep-research |
| [PaperQA2](paperqa2.md) | Complementary — where deep-research scrapes the web, PaperQA2 queries local scientific paper collections with higher citation accuracy |
| [Tongyi DeepResearch](https://github.com/Alibaba-NLP/DeepResearch) | RL-trained model-based alternative to the scaffold pattern; operates from a trained policy rather than prompt engineering |
| [CognitiveKernel-Pro](cognitivekernel-pro.md) | SFT-trained agent that distills the deep-research pattern into a model weight; achieves stronger performance than scaffold approaches on GAIA |

---

## References

1. Zhang, D. (2025). *deep-research*. GitHub repository. [https://github.com/dzhng/deep-research](https://github.com/dzhng/deep-research)
2. Aomni AI Research Platform. [https://aomni.com](https://aomni.com)
3. Firecrawl documentation. [https://docs.firecrawl.dev](https://docs.firecrawl.dev)
4. Exa AI search API. [https://exa.ai](https://exa.ai)
5. Vercel AI SDK documentation. [https://sdk.vercel.ai](https://sdk.vercel.ai)
6. LangChain Open Deep Research (derived implementation). [https://github.com/langchain-ai/open_deep_research](https://github.com/langchain-ai/open_deep_research)
7. ByteDance DeerFlow (derived implementation). [https://github.com/bytedance/deer-flow](https://github.com/bytedance/deer-flow)
8. Asai, A. et al. (2024). OpenScholar: Synthesizing Scientific Literature with Retrieval-Augmented LMs. *Nature*. [https://arxiv.org/abs/2411.14199](https://arxiv.org/abs/2411.14199)
