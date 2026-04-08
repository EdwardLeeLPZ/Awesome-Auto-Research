# Idea2Paper

> A multi-agent research pipeline from AgentAlphaAGI that converts raw research ideas into structured paper proposals by combining multi-agent orchestration with Knowledge Graph novelty alignment, grounded in Semantic Scholar and arXiv.

## Overview

Idea2Paper is an open-source research automation system developed by AgentAlphaAGI.
With over 1,276 GitHub stars, it addresses one of the most challenging and least automated parts of the research workflow: converting a vague research idea into a structured, novelty-verified research proposal ready for development.

The key innovation is the Knowledge Graph (KG) novelty alignment step.
Before the system generates a research proposal, it builds a knowledge graph from relevant literature and checks whether the proposed idea is genuinely novel or already well-covered.
This novelty filter prevents the pipeline from generating proposals for ideas that have already been extensively studied — a common failure mode of LLM-based idea generation systems.

Idea2Paper integrates with Semantic Scholar and arXiv for grounding, ensuring that generated proposals cite real work and that novelty claims are based on actual literature rather than LLM priors.
The multi-agent architecture distributes the work across specialised agents: one for literature retrieval, one for KG construction, one for idea assessment, and one for proposal writing.

## Architecture

Idea2Paper uses a sequential multi-agent pipeline with a shared Knowledge Graph as the central data structure:

```
User input (raw idea)
        │
        ▼
┌───────────────────┐
│  Literature Agent  │ ─── Semantic Scholar + arXiv APIs
│  (retrieval)       │
└────────┬──────────┘
         │ papers + metadata
         ▼
┌───────────────────┐
│  KG Builder Agent │ ─── Constructs entity-relation graph
│                   │     from retrieved papers
└────────┬──────────┘
         │ knowledge graph
         ▼
┌───────────────────┐
│  Novelty Assessor  │ ─── Compares input idea against KG
│  Agent            │     scores originality (0–1)
└────────┬──────────┘
         │ novelty score + gap analysis
         ▼
┌───────────────────┐
│  Proposal Writer   │ ─── Generates structured research
│  Agent            │     proposal with citations
└────────┬──────────┘
         │
         ▼
  Structured research proposal (Markdown / PDF)
```

The Knowledge Graph is the shared memory layer that connects all agents.
Each agent reads from and writes to the KG, ensuring that later-stage agents benefit from earlier-stage findings.

## Core Workflow

1. **Idea input** — user provides a seed idea (1–3 sentences describing the research direction).
2. **Literature retrieval** — literature agent queries Semantic Scholar and arXiv for related work using multiple search strategies (keyword, author, citation graph traversal).
3. **Paper filtering** — retrieved papers are ranked by relevance; top-K are retained for KG construction.
4. **KG construction** — KG builder agent extracts entities (methods, datasets, metrics, concepts) and relations from paper abstracts and introductions.
5. **Novelty alignment** — novelty assessor agent maps the input idea onto the KG and identifies how much of the idea's components are already covered.
6. **Gap identification** — gaps in the KG (what the input idea proposes that is not yet in the literature) are extracted and ranked by potential impact.
7. **Proposal generation** — proposal writer agent generates a structured research proposal using identified gaps as the contribution claims.
8. **Citation grounding** — all claims in the proposal are grounded in specific papers from the KG.
9. **Output formatting** — proposal is formatted in standard academic structure (Introduction, Related Work, Methodology, Expected Contributions).

## Key Features

- **Knowledge Graph novelty alignment** — the central innovation; ensures proposals are genuinely novel rather than LLM hallucinations.
- **Semantic Scholar + arXiv integration** — real literature grounding, not just LLM priors about what papers exist.
- **Multi-agent architecture** — specialised agents for each stage enable clean task decomposition and independent debugging.
- **Citation grounding** — every contribution claim in the output proposal is linked to real papers in the KG.
- **Gap-driven proposal generation** — proposals are built around identified literature gaps, not generic templates.
- **Configurable novelty threshold** — users can set a minimum novelty score; ideas below the threshold trigger literature gap analysis for idea refinement.

## Technical Implementation

### Knowledge Graph Construction

The KG builder agent uses an LLM to perform information extraction from paper abstracts and introductions.
Extracted entities include: methods, models, datasets, evaluation metrics, domain concepts, and author groups.
Relations include: "improves-on", "uses", "evaluates-with", "extends", and "contradicts".
The KG is stored as a directed property graph (using NetworkX or a similar library).
For each paper, nodes correspond to extracted entities and edges correspond to extracted relations.

### Novelty Alignment

The novelty assessor represents the input idea as a set of entity-relation triples.
It then queries the KG to find whether each triple is already present (as an existing relation) or absent (as a gap).
The novelty score is computed as:
```
novelty_score = (unsupported_triples) / (total_input_triples)
```
A score near 1.0 means the idea is highly novel; near 0.0 means it closely replicates existing work.

### Literature Retrieval Strategy

The literature agent uses a multi-strategy search:
1. **Keyword search** — direct Semantic Scholar API queries with idea keywords.
2. **Citation expansion** — retrieve papers cited by top-K results to find foundational work.
3. **Author traversal** — find other papers by the same authors to understand the research group's trajectory.
4. **arXiv preprint scan** — check for recent preprints not yet indexed in Semantic Scholar.

### Proposal Writer

The proposal writer agent uses a structured prompting strategy:
- Introduction: motivated by the most relevant KG gaps.
- Related work: automatically populated from the KG with a coherent narrative.
- Methodology: generated based on the identified contribution claims.
- Expected contributions: directly extracted from the gap analysis.

## Evaluation & Benchmarks

Idea2Paper does not publish results on standardised benchmarks as of this writing.

### Qualitative Evaluation
- Community reports of successfully generated research proposals that passed human expert novelty review.
- Novelty alignment reduces redundant proposal generation versus baseline LLM prompting.
- Proposals contain real citations from Semantic Scholar/arXiv, improving academic credibility.

### Comparison with Alternatives
- Better literature grounding than pure LLM brainstorming (ChatGPT, Claude).
- More novelty-aware than AI-Scientist's idea generation, which uses a different validation approach.
- Less end-to-end than AI-Scientist (does not run experiments), but more focused on idea validation.

## Strengths

- **Genuine novelty checking** — KG alignment addresses a real gap in LLM-based idea generation systems.
- **Real literature integration** — Semantic Scholar and arXiv grounding prevents hallucinated citations.
- **Gap-driven proposals** — generated proposals are motivated by real literature gaps, not generic templates.
- **Composable** — the KG and retrieved papers can be reused as a research database for follow-up work.
- **Configurable thresholds** — novelty filtering can be tuned to use case (exploratory ideation vs. rigorous proposal).

## Limitations

- **No experiment execution** — Idea2Paper stops at the proposal stage; it does not run experiments or write full papers.
- **KG quality dependency** — the quality of novelty alignment depends on how accurately the KG captures the literature.
- **Literature coverage gaps** — Semantic Scholar and arXiv do not cover all venues; domain-specific work may be missed.
- **Computational cost** — KG construction for large literature searches can be slow and LLM-call-intensive.
- **English-only** — primarily designed for English-language research; multilingual literature coverage is limited.
- **No peer review step** — unlike AI-Scientist or EvoScientist, there is no automated reviewer feedback on the generated proposal.

## Related Work

- **AI-Scientist** (SakanaAI) — end-to-end pipeline that also handles hypothesis generation but within a narrower ML template framework.
- **SciAgents** (MIT) — multi-agent scientific reasoning using ontology graphs; similar KG-based approach but different task framing.
- **ResearchAgent** — iterative idea refinement with academic concept databases; similar philosophy.
- **Agent Laboratory** — role-specialised multi-agent for the full research cycle, including experiments.
- **EvoScientist** — six-agent pipeline with RL self-improvement; higher ambition but less specialised for idea novelty.

## References

1. AgentAlphaAGI. (2025). *Idea2Paper*. https://github.com/AgentAlphaAGI/Idea2Paper
2. Baek, J. et al. (2024). *ResearchAgent: Iterative Research Idea Generation over Scientific Literature with LLMs*. arXiv:2404.07738.
3. Lu, C. et al. (2024). *The AI Scientist*. arXiv:2408.06292.
4. Buehler, M. C. et al. (2024). *Accelerating Scientific Discovery with SciAgents*. Advanced Materials.
5. Lo, K. et al. (2020). *S2ORC: The Semantic Scholar Open Research Corpus*. ACL 2020.
6. Clement, C. B. et al. (2019). *On the Use of arXiv as a Dataset*. arXiv:1905.00075.

---

### Practitioner Notes

**Setup and prerequisites:** Idea2Paper requires API keys for Semantic Scholar, arXiv API access (free), and an LLM provider (OpenAI, Anthropic, or compatible).
The KG construction step can be slow for large literature sets; consider limiting initial retrieval to 50 papers for quick exploration runs.

**Novelty threshold calibration:** The default novelty threshold (0.6) balances between too-strict (most ideas rejected) and too-loose (existing work repackaged).
For mature research areas, lower the threshold to 0.5 to allow incremental improvements.
For emerging areas with sparse literature, raise to 0.7 to ensure genuine novelty.

**Knowledge graph limitations:** The KG reflects only what the NLP extraction pipeline can extract from abstracts.
For sub-fields where key contributions are buried in methodology sections (not abstracts), the KG may underestimate coverage.
Manually adding key papers to the KG before running the pipeline improves novelty assessment accuracy for specialised sub-fields.

**Output quality tips:**
Review the extracted KG entities before running the proposal generator.
Spurious entities (e.g., author names mistaken for methods) can distort the novelty analysis.
The citation quality in the generated proposal depends directly on KG quality.

**Integration patterns:**
Use Idea2Paper as a proposal generation front-end for downstream systems.
The generated proposal can be passed to AI-Scientist as an initial hypothesis for experiment generation.
The literature KG is a reusable asset that can be updated incrementally as new papers appear.

**Comparison with manual ideation:**
Expert researchers report that Idea2Paper accelerates the initial literature review and gap identification step from 2–3 days to 2–3 hours for a new research direction.
The output quality is lower than a hand-crafted proposal but sufficient as a starting point for refinement.

**Version notes:** Idea2Paper's KG approach was inspired by early knowledge graph question answering (KGQA) systems.
The integration of Semantic Scholar as the primary literature source provides access to over 200 million papers across all disciplines.
The arXiv integration is particularly valuable for AI and ML research where preprints often precede formal publication by 6–18 months.
Community forks have extended the system to chemistry, biology, and materials science domains with domain-specific ontologies.
Future planned features include real-time KG updates from arXiv RSS feeds and integration with Zotero for persistent bibliography management.
