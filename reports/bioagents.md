# BioAgents — AI Agent Framework for Biological Research

## Overview

**BioAgents** is a specialized AI agent framework designed for autonomous discovery and analysis in biological and life sciences research. It combines state-of-the-art literature retrieval agents with domain-optimized analysis capabilities, achieving top-tier performance on biological benchmarks. The framework emphasizes modular agent selection, enabling researchers to swap backends based on task requirements.

- **Repository:** [github.com/bio-xyz/BioAgents](https://github.com/bio-xyz/BioAgents)
- **Stars:** 114 (as of March 2026)
- **Language:** TypeScript (Node.js backend)
- **Year:** 2025
- **Organization:** bio-xyz (open-source)
- **Maintainer:** Community-driven

---

## Project Positioning

### Target Use Cases

- **Biomedical literature mining** — automated discovery of biological relationships
- **Drug discovery workflows** — hypothesis generation from literature
- **Protein research** — literature-guided protein function prediction
- **Disease research** — cross-linking disease mechanism papers
- **Genomics analysis** — context retrieval for gene function studies
- **Clinical decision support** — evidence-based literature synthesis

### Target Audience

- Biological researchers seeking AI-augmented literature analysis
- Biotech teams automating knowledge synthesis
- Academic labs with domain-specific research questions
- Computational biology groups building research pipelines
- Developers building biology-focused AI applications

### Key Goals

1. **Domain Specialization** — LLM + retrieval optimized for biological knowledge
2. **Benchmark Excellence** — achieve SOTA on biological QA tasks
3. **Modularity** — swappable agent backends (BioAgents, Edison, OpenScholar)
4. **Conversational + Deep Research** — support both quick Q&A and extended investigation
5. **Interpretability** — transparent evidence grounding for all findings

---

## System Architecture

BioAgents employs a **modular agent architecture** with pluggable backends for literature and analysis tasks:

```
User Input (Research Question / Analysis Task)
    ↓
┌──────────────────────────────────────────────────┐
│  Routing Layer                                   │
│  - Classify task as: Chat QA vs. Deep Research   │
│  - Select appropriate agent pipeline             │
└──────────┬───────────────────────────────────────┘
           ├─────────────────────┬─────────────────────┐
           ↓                     ↓                     ↓
    [Chat Route]         [Deep Research]      [Analysis Route]
           ↓                     ↓                     ↓
┌──────────────────────────────┐  ┌──────────────────────────────┐
│  Literature Agent (Pluggable)│  │  Analysis Agent (Pluggable)  │
│  Primary: BioAgents API      │  │  Primary: BioAgents Data Eng  │
│  Alt: OpenScholar            │  │  Alt: Edison                 │
│  Alt: Edison                 │  │                              │
│  - Semantic similarity search │  │  - Pattern detection         │
│  - LLM reranking of results  │  │  - Statistical analysis      │
│  - Evidence extraction        │  │  - Reasoning over facts      │
└──────────┬───────────────────┘  └──────────┬───────────────────┘
           │                                 │
           └─────────────┬───────────────────┘
                         ↓
            ┌────────────────────────────┐
            │  Response Synthesis        │
            │  - Integrate findings      │
            │  - Format for user         │
            │  - Cite sources            │
            └────────────────────────────┘
                         ↓
                    User Response
```

### Core Components

1. **Configurable Literature Agents**
   - **BioAgents (Primary)** — Custom-trained semantic search + LLM reranking on biomedical corpora
   - **OpenScholar (Alternative)** — Dense retrieval over 45M open-access papers
   - **Edison (Alternative)** — General-purpose research agent (fallback)

2. **Configurable Analysis Agents**
   - **BioAgents Data Analysis** — Specialized for biological patterns and relationships
   - **Edison (Alternative)** — General-purpose analysis backend

3. **Dual-Mode Orchestration**
   - **Chat Mode** (`/api/chat`) — Low-latency single-turn Q&A with automatic literature search
   - **Deep Research Mode** (`/api/deep-research`) — Iterative hypothesis-driven investigation

4. **State Management** — Context preservation across multi-turn conversations
5. **API Gateway** — Express-based HTTP interface for easy integration

---

## Core Workflow

### Mode 1: Chat-Based Q&A

```
User Query: "What is the function of TP53 in tumor suppression?"
    ↓
1. Literature Lookup
   - Search BioAgents API: "TP53 tumor suppression"
   - Retrieve top-10 ranked papers with snippets
   - Rerank via LLM relevance scoring
    ↓
2. Context Synthesis
   - Extract key claims from retrieved passages
   - Identify consensus findings
   - Flag conflicting evidence
    ↓
3. Response Generation
   - Compose narrative explanation
   - Include 3-5 inline citations
   - Highlight evidence confidence
    ↓
User receives cited answer in <5 seconds
```

### Mode 2: Deep Research

```
User Request: "Investigate link between BRCA1 mutations and cancer risk"
    ↓
Iteration 1: Initial Exploration
- Literature Agent searches: "BRCA1 cancer risk association"
- Finds: ~50 relevant papers
- Extracts: BRCA1 function, mutation types, tissue specificity
    ↓
Iteration 2: Mechanism Investigation
- Hypothesis: BRCA1 loss impairs DNA repair
- Literature search: "BRCA1 DNA repair pathway"
- Extracts: Homologous recombination role, downstream effects
    ↓
Iteration 3: Clinical Implications
- Search: "BRCA1 mutations clinical outcomes"
- Compile: Penetrance estimates, cancer subtypes, screening strategies
    ↓
Analysis Agent Synthesis
- Integrate findings into coherent narrative
- Identify knowledge gaps
- Highlight clinical relevance
    ↓
Generate Deep Research Report (30–60 sec)
- Comprehensive literature synthesis
- Mechanistic explanation
- Clinical context
```

### Implementation Paths

#### Chat Flow (`/api/chat`)

1. User sends natural language question
2. System determines if literature search needed
3. Literature Agent executes query
4. LLM synthesizes response with citations
5. Fast response (ideal for exploratory queries)

#### Deep Research Flow (`/api/deep-research`)

1. User provides research focus + constraints
2. System generates hypothesis-driven search plan
3. Iterative cycles:
   - Execute targeted literature queries
   - Extract and synthesize findings
   - Generate follow-up hypotheses
4. Compile findings into structured report
5. Slower but more comprehensive (ideal for deep dives)

---

## Key Features

### Literature Retrieval Capabilities

1. **Pluggable Literature Backends** — Swap between BioAgents, OpenScholar, or Edison
2. **Semantic Search** — Embedding-based retrieval optimized for biological corpora
3. **LLM Reranking** — GPT-4o reranking for biological relevance
4. **Citation Extraction** — Automatic attribution to source papers
5. **Evidence Confidence** — Scoring of finding reliability based on source agreement

### Analysis Capabilities

1. **Domain-Specialized Reasoning** — Understands biological pathways, genes, disease mechanisms
2. **Pattern Detection** — Identifies key concepts and relationships in literature
3. **Biological Nomenclature** — Recognizes standard names, synonyms, and identifiers
4. **Multi-Turn Reasoning** — Maintains context across iterations for consistent analysis

### Operational Modes

1. **Chat Mode** — Fast Q&A with automatic literature grounding (< 5 sec response)
2. **Deep Research Mode** — Multi-iteration hypothesis-driven investigation (30–60 sec)
3. **Configurable Backends** — Switch analysis and literature engines via .env

### Integration & Deployment

- HTTP API endpoints via Express
- TypeScript type definitions for IDE support
- Modular design enables custom agent pluggability
- Stateless architecture for scalable deployment

---

## Technical Implementation

### Technology Stack

- **Backend:** Node.js + TypeScript
- **API Framework:** Express.js
- **AI Models:** Claude (primary), GPT-4o (optional)
- **Literature Backends:**
  - BioAgents API (custom semantic search)
  - OpenScholar API (45M papers + dense retrieval)
  - Edison API (fallback)
- **Deployment:** HTTP endpoints via Express
- **Frontend Support:** TypeScript types for IDE integration

### Configuration System

```env
# .env configuration
PRIMARY_LITERATURE_AGENT=bio      # bio | openscholar | edison
PRIMARY_ANALYSIS_AGENT=bio        # bio | edison
CLAUDE_API_KEY=sk-***
OPENAI_API_KEY=sk-***
```

### BioAgents-Specific Features

1. **Semantic Search** — Embedding-based retrieval trained on biological corpora
2. **LLM Reranking** — GPT-4o reranks results for biological relevance
3. **Domain Optimization** — Understands biological nomenclature, pathways, disease names
4. **Citation Extraction** — Automatically attributes findings to source papers

---

## Performance & Benchmarks

### BixBench Evaluation

BioAgents analysis agent achieves state-of-the-art on **BixBench**, a benchmark of biological QA tasks:

| Evaluation Mode | Score | Baseline | Gap |
|-----------------|-------|----------|-----|
| **Open-Answer** | **48.78%** | 42% (Kepler) | +6.78% |
| **Multiple-Choice (with refusal)** | **55.12%** | 51% (GPT-5) | +4.12% |
| **Multiple-Choice (no refusal)** | **64.39%** | 60% (Others) | +4.39% |

### Benchmark Analysis

- **Outperforms:** Kepler (biomedical specialist LLM), GPT-5, other general LLMs
- **Strength:** Open-ended reasoning on biological questions
- **Technique:** Combines specialized literature retrieval with analysis optimized for biological patterns

### Comparison with Related Systems

| System | Lit Database | Analysis Specialization | Benchmark | Language |
|--------|--------------|-------------------------|-----------|----------|
| **BioAgents** | Biomedical focus | Biological QA (BixBench) | 48.78% | TypeScript |
| **OpenScholar** | 45M papers | General retrieval-augmented LM | Nature paper | Python |
| **Biomni** | Biomedical datalake | General biomedical QA | None published | Python |
| **Edison** | General | General | None | Python |

---

## Strengths

1. **SOTA on BixBench** — Significantly outperforms baselines on biological QA
2. **Domain Specialization** — Built specifically for biological research workflows
3. **Modular Architecture** — Swap backends without recoding (BioAgents ↔ OpenScholar ↔ Edison)
4. **Dual-Mode Operation** — Single system supports quick Q&A and deep research
5. **Easy Integration** — Simple HTTP API, TypeScript types for IDE support
6. **Transparent Configuration** — `.env` file controls all key settings
7. **Recent Development** — Active development (March 2025 push); community-maintained

---

## Limitations

1. **TypeScript-Only** — No Python support (unlike most research automation systems)
2. **API Dependency** — Requires external API keys (OpenAI, BioAgents, OpenScholar)
3. **Limited Autonomy** — Primarily a synthesis tool, not code execution or hypothesis generation
4. **Benchmark Specificity** — BixBench is biological QA; performance on other research tasks unknown
5. **Early Stage** — Only 114 stars; ecosystem not as mature as STORM or GPT Researcher
6. **No Local Model Support** — Requires commercial API access
7. **Documentation** — Limited to README; no technical paper or detailed architecture documentation
8. **Scalability Unknown** — Concurrent request handling and state management not well characterized

---

## Related Work

- **Biomni (Stanford SNAP)** — Biomedical datalake system; similar domain focus but different architecture
- **OpenScholar (Nature)** — 45M paper retrieval system; can serve as backend to BioAgents
- **STORM (Stanford)** — Multi-perspective QA; not domain-specialized but can be fine-tuned
- **Open Deep Research (LangChain)** — General deep research; configurable but non-specialized
- **PaperQA2** — PDF-based QA system; complements web-based retrieval

**Distinctive Positioning:**
- Only end-to-end agent framework **optimized specifically for biological research**
- Novel modular backend selection (literature + analysis)
- SOTA benchmark performance on biological tasks
- Bridges gap between general research agents and domain-specific tools

---

## References

- **GitHub Repository:** https://github.com/bio-xyz/BioAgents
- **Scientific Paper (arXiv):** https://arxiv.org/abs/2601.12542
- **Blog:** Introducing BioAgents (http://ai.bio.xyz/blog/introducing-bios)
- **BixBench Benchmark:** [Reference in arXiv paper]
- **Topics:** `agentic-ai`, `ai-scientist`, `desci`, `science`, `biology`
- **LangChain Integration:** Potential via LLM backend support

---

**Last Updated:** March 2026  
**Status:** Active (recent push: March 19, 2026)  
**License:** See repository for details  
**Community:** Open-source maintained by bio-xyz team
