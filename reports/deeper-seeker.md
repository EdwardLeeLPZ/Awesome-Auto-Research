# Deeper-Seeker — Iterative Web Research Agent

## Overview

**Deeper-Seeker** is an open-source research automation tool designed as a functional alternative to OpenAI's proprietary Deep Research feature in ChatGPT. It automates comprehensive research workflows through iterative questioning, multi-step search queries, and structured report synthesis from web sources.

- **Repository:** [github.com/HarshJ23/Deeper-Seeker](https://github.com/HarshJ23/Deeper-Seeker)
- **Stars:** 415 (as of March 2026)
- **Language:** Python
- **Year:** 2024
- **Version:** v2.0.0
- **Maintainer:** HarshJ23

---

## Project Positioning

### Target Use Cases

- **Market research automation** — competitive analysis and trend synthesis
- **Investment due diligence** — gathering and structuring business intelligence
- **Academic literature synthesis** — comprehensive topic surveys
- **Policy research** — multi-source evidence gathering
- **Due diligence reporting** — structured research summaries for decision-makers

### Target Audience

- Researchers requiring structured web research with inline citations
- Business intelligence teams automating market analysis
- Investment professionals automating research workflows
- Academic teams conducting systematic literature reviews
- Anyone seeking OSS alternative to OpenAI's Deep Research

### Key Goals

1. **Accessibility** — provide free, open-source alternative to proprietary research tools
2. **Iterative Refinement** — enable human feedback loops during research
3. **Structured Output** — generate professional, cited reports
4. **Scalability** — handle complex multi-step research queries
5. **Citation Transparency** — maintain full source attribution for all claims

---

## System Architecture

Deeper-Seeker follows an **iterative refinement architecture** where human feedback reshapes research direction at multiple stages:

```
User Research Topic
    ↓
┌─────────────────────────────────────────────┐
│  Initial Follow-Up Loop                     │
│  - Generate clarifying questions            │
│  - Collect user feedback on scope           │
│  - Refine research parameters               │
└─────────────┬───────────────────────────────┘
              ↓
┌─────────────────────────────────────────────┐
│  Research Plan Generation                   │
│  - Break problem into logical steps         │
│  - Assign research objectives per step      │
│  - Estimate depth/breadth per objective     │
└─────────────┬───────────────────────────────┘
              ↓
┌─────────────────────────────────────────────┐
│  Multi-Step Research Execution              │
│  ├─ Step 1: Generate search queries (3 per) │
│  ├─ Step 2: Execute queries (Exa API)      │
│  ├─ Step 3: Collect & process results      │
│  └─ (Repeat for all research steps)         │
└─────────────┬───────────────────────────────┘
              ↓
┌─────────────────────────────────────────────┐
│  Result Processing & Insight Extraction     │
│  - Deduplicate findings                     │
│  - Extract key claims with confidence       │
│  - Link claims to source URLs               │
└─────────────┬───────────────────────────────┘
              ↓
┌─────────────────────────────────────────────┐
│  Report Generation                          │
│  - Structure narrative flow                 │
│  - Embed inline citations                   │
│  - Format as markdown                       │
└─────────────┬───────────────────────────────┘
              ↓
        final_report.md
```

### Core Components

1. **Follow-Up Question Engine** — Clarification loop before research begins
2. **Research Plan Decomposer** — Breaks complex queries into step-based objectives
3. **Query Generator** — Creates multiple search queries per research step
4. **Web Search Integration** — Exa API for high-quality search results
5. **Result Processor** — Deduplication and relevance ranking
6. **Insight Extractor** — LLM-based claim identification with citations
7. **Report Formatter** — Markdown generation with inline references

---

## Core Workflow

### Stage 1: Interactive Refinement

```
User inputs: "Research ChatGPT market impact"
↓
Follow-Up Questions:
- Geographic scope? (Global / specific regions)
- Sector focus? (General / specific industries)
- Time horizon? (Recent / long-term trends)
↓
User provides feedback
↓
Research scope refined and locked
```

### Stage 2: Research Plan Generation

1. LLM decomposes refined query into logical research steps (typically 3-5)
2. **Example decomposition for "ChatGPT market impact":**
   - Step 1: Topic Exploration — general ChatGPT adoption metrics
   - Step 2: Competitive Analysis — market share vs. alternatives
   - Step 3: Industry Impact — sector-specific disruptions
   - Step 4: Economic Effects — job displacement and new roles

### Stage 3: Multi-Step Execution

For each research step:
1. **Query Generation** — LLM creates 3 targeted search queries
   - Example for Step 1: `"ChatGPT user growth statistics 2024"`
   - Example for Step 1: `"ChatGPT enterprise adoption rates"`
   - Example for Step 1: `"ChatGPT revenue impact OpenAI"`

2. **Web Search** — Exa API executes queries
   - Returns ranked results with snippets
   - Typically 10 results per query = 30 data points per step

3. **Result Aggregation** — LLM processes findings
   - Identifies consistent claims across sources
   - Filters redundant information
   - Associates insights with source URLs

### Stage 4: Report Synthesis

1. **Insight Organization** — Group related findings into themes
2. **Narrative Structure** — Create logical flow across themes
3. **Citation Integration** — Embed source URLs next to claims
4. **Final Polish** — Markdown formatting with headers, lists, emphasis

---

## Key Features

### Research Workflow Features

1. **Interactive Refinement Loop** — Human feedback before committing to research direction
2. **Multi-Step Query Generation** — Decomposes research topics into objectives (typically 3-5 steps)
3. **Parallel Query Execution** — 3 search queries per step × N steps for breadth
4. **Semantic Web Search** — Exa API provides higher-quality results than keyword matching
5. **Deduplication Engine** — Removes redundant findings across search results
6. **Citation Linking** — Every claim attributed to source URL for verification
7. **Markdown Output** — Professional report format suitable for stakeholder presentation

### Flexibility Features

- **Scope Customization** — Configure geographic regions, sectors, time horizons
- **Query Formulation** — Adaptive generation based on research step requirements
- **Result Filtering** — Confidence-based filtering of extracted claims
- **Extensible Output** — Markdown format enables downstream processing

---

## Technical Implementation

### Technology Stack

- **Core Framework:** Python (standard library + requests)
- **Web Search:** Exa API (semantic search engine)
- **LLM Backend:** OpenAI GPT-4o or GPT-4 Turbo
- **Report Format:** Markdown
- **Visualization:** Text-based tables and lists

### Key Algorithms

1. **Query Decomposition** — Multi-step problem breakdown via tree-structured LLM reasoning
2. **Iterative Refinement** — Human-in-the-loop feedback integration at plan stage
3. **Deduplication** — Similarity hashing to remove redundant findings
4. **Citation Linking** — Associating extracted claims with source URLs

### LLM Integration

- **Model:** GPT-4o (or GPT-4 Turbo as fallback)
- **Token Budget:** ~100K tokens per research session
- **Function Calls:** Structured outputs for plans, queries, insights

### Exa API Integration

- **Purpose:** High-quality semantic web search (alternative to Google Search API)
- **Query Format:** Natural language questions + optional filters
- **Results:** Ranked by relevance + includes page snippets

### Deployment

- **Local Execution:** Python environment (no Docker required)
- **Configuration:** API keys via environment variables
  - `EXA_API_KEY` — Exa semantic search
  - `OPENAI_API_KEY` — GPT-4o backend
- **Output:** `final_report.md` in working directory

---

## Performance & Benchmarks

### Evaluation Status

Deeper-Seeker has not been formally benchmarked against standard research automation suites (DeepResearch-Bench, SWE-Bench, etc.). Evaluation focuses on output quality and user feedback.

### Observed Characteristics

**Strengths:**
- Produces well-structured, cited reports (typical: 2,000–5,000 words)
- Iterative refinement loop improves report relevance vs. single-pass systems
- Clean markdown output suitable for publishing
- Fast execution (typical: 3–10 minutes per research task)

**Trade-offs:**
- Iterative loop requires active user participation (not fully autonomous)
- Limited to web search (no academic database access like OpenScholar)
- No explicit code execution capability
- Report depth depends on query quality

### Comparison with Alternatives

| Aspect | Deeper-Seeker | OpenAI Deep Research | STORM | Open Deep Research |
|--------|----------------|----------------------|-------|-------------------|
| Cost | Low (Exa + GPT-4o) | Closed / requires ChatGPT Pro | Free | Free |
| Autonomy | Moderate (1 refinement loop) | High | High | Configurable |
| Citation Quality | Good | Unknown | Good | Configurable |
| Academic Databases | No | No | No | Via MCP |
| OSS | Yes | No | Yes | Yes |

---

## Strengths

1. **Open-Source Alternative** — Fills gap for users wanting OSS equivalent to OpenAI's tool
2. **Iterative Refinement** — Human-in-the-loop feedback before committing to research direction
3. **Citation Transparency** — Every claim linked to source URL for verification
4. **Fast Iteration** — Typical research completes in 3–10 minutes
5. **Clean Output** — Professional markdown reports suitable for stakeholder sharing
6. **Semantic Search** — Exa API provides higher-quality results than keyword search
7. **Simplicity** — Minimal dependencies, easy to install and run

---

## Limitations

1. **Requires User Interaction** — Not fully autonomous; needs human feedback at refinement stage
2. **Limited Scope** — Web search only; cannot access academic paywall databases
3. **No Code Execution** — Cannot validate technical claims via code runs
4. **Cumulative Latency** — Sequential queries to Exa + LLM calls add wall-clock time
5. **API Dependency** — Requires active Exa API and OpenAI account with credits
6. **No Local LLM Support** — Cannot run with free/local models (requires GPT-4o)
7. **No Formal Evaluation** — Lacks comparative benchmarks vs. other research agents
8. **Hypothesis Quality** — Initial research plan depends entirely on user's input quality

---

## Related Work

- **OpenAI Deep Research** — Proprietary inspiration; closed-source version of similar workflow
- **STORM (Stanford)** — Wikipedia-style article generation using multi-perspective QA
- **Open Deep Research (LangChain)** — Reference implementation with MCP tool support
- **Deep-Research (dzhng)** — Recursive depth/breadth scaffold with similar goals
- **DeerFlow (ByteDance)** — Full end-to-end research + code execution system

**Distinctive Features:**
- Unlike STORM, emphasizes **iterative user feedback** rather than pure automation
- Unlike Open Deep Research, focuses on **simplicity** (no MCP configuration needed)
- Unlike DeerFlow, omits code execution but gains lightweight deployment

---

## References

- **GitHub Repository:** https://github.com/HarshJ23/Deeper-Seeker
- **Exa API Documentation:** https://exa.ai/docs
- **OpenAI API Reference:** https://platform.openai.com/docs
- **Topics:** `deepresearch`, `openai`, `exa`, `research-automation`, `web-search`

---

**Last Updated:** March 2026  
**Status:** Active (recent updates 2024–2026)  
**License:** See repository for details  
**Last Commit:** May 12, 2025
