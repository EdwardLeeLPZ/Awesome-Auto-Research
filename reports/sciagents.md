# SciAgents

> A multi-agent scientific reasoning system from MIT's Buehler Lab that uses ontology graphs as a structured knowledge backbone to enable grounded, multi-step reasoning for hypothesis generation and scientific discovery.

## Overview

SciAgents (now maintained as SciAgentsDiscovery) is a multi-agent scientific reasoning system developed by Markus Buehler's group at MIT.
The system has accumulated over 600 GitHub stars and represents an important contribution to ontology-grounded scientific AI.

The central innovation is the use of **ontology graphs** as the reasoning substrate.
Rather than asking an LLM to generate hypotheses from scratch, SciAgents grounds all reasoning in a structured domain ontology extracted from scientific literature.
Agents traverse this graph to find non-obvious connections between concepts, generating hypotheses that are both novel and literature-grounded.

This approach is particularly well-suited to materials science and biology, where domain ontologies are rich and well-established.
The MIT Buehler lab focuses on biomaterials, protein engineering, and hierarchical materials systems — complex domains where the structured graph representation provides essential scientific context.

SciAgents is distinct from AI-Scientist and similar systems in its emphasis on **scientific knowledge representation** over workflow automation.
Where AI-Scientist automates the experiment loop, SciAgents focuses on the hypothesis generation step and provides a principled, interpretable reasoning chain grounded in domain knowledge.

## Architecture

SciAgents uses a knowledge graph as the shared reasoning infrastructure across all agents:

```
┌─────────────────────────────────────────────────────┐
│                    SciAgents System                  │
│                                                      │
│  ┌──────────────────────────────────┐               │
│  │       Ontology Graph (OG)        │               │
│  │   - Domain concepts (nodes)      │               │
│  │   - Relations (edges)            │               │
│  │   - Literature provenance        │               │
│  │   - Property annotations         │               │
│  └──────────────┬───────────────────┘               │
│                 │ graph queries                      │
│  ┌──────────────┼───────────────────┐               │
│  │              │                   │               │
│  ▼              ▼                   ▼               │
│ Exploration   Synthesis         Critique            │
│ Agent         Agent             Agent               │
│ (traverses    (generates        (validates          │
│ OG paths)     hypotheses)       reasoning)          │
│  │              │                   │               │
│  └──────────────┼───────────────────┘               │
│                 ▼                                    │
│     Multi-step reasoning chain (grounded in OG)     │
└─────────────────────────────────────────────────────┘
```

The ontology graph is constructed from domain literature using NLP-based relation extraction.
Each node represents a scientific concept (material, property, biological entity, method), and each edge represents a typed relation (has-property, interacts-with, enables, contradicts).

## Core Workflow

1. **Ontology construction** — scientific literature is processed to extract domain entities and relations, building the ontology graph.
2. **Query formulation** — user specifies a research area or target concept.
3. **Graph exploration** — exploration agent traverses the ontology graph from the target concept, identifying relevant neighbours.
4. **Path analysis** — agent identifies indirect paths between concepts that suggest non-obvious connections.
5. **Hypothesis generation** — synthesis agent proposes hypotheses based on identified graph paths.
6. **Reasoning chain construction** — agent generates a multi-step reasoning chain tracing each hypothesis back to graph evidence.
7. **Critique** — critique agent evaluates hypotheses for logical consistency and evidence grounding.
8. **Refinement** — hypotheses are refined based on critique feedback.
9. **Output** — structured hypotheses with full reasoning chains, evidence citations, and confidence scores.

## Key Features

- **Ontology-grounded reasoning** — all hypotheses are grounded in a structured domain knowledge graph built from real literature, not LLM priors.
- **Multi-step reasoning chains** — output includes explicit chains of reasoning traceable back to source evidence.
- **Multi-agent critique** — a dedicated critic agent validates each hypothesis independently, improving quality.
- **Domain specialisation** — optimised for materials science, biomaterials, and biology where ontologies are richly structured.
- **MIT Buehler Lab backing** — developed alongside real research in protein engineering and hierarchical materials.
- **Interpretable outputs** — reasoning chains are human-readable and auditable, unlike black-box LLM generation.

## Technical Implementation

### Ontology Graph Construction

The ontology is built from domain papers using a multi-stage NLP pipeline:
1. **Named entity recognition** — domain-specific NER models extract scientific entities (materials, properties, organisms, methods).
2. **Relation extraction** — LLM-based relation extraction identifies typed relations between entities.
3. **Graph population** — extracted entity-relation triples are added to a property graph (Neo4j or NetworkX).
4. **Provenance tracking** — each edge is annotated with its source paper, year, and confidence score.

### Graph Traversal Strategy

The exploration agent uses random walks with restart (RWR) to identify conceptually relevant neighbourhoods.
Random walk seeds are set at the user-specified target concept.
Nodes are ranked by visit frequency; high-frequency nodes form the core relevant subgraph.
Paths between high-frequency nodes are extracted as candidate hypothesis chains.

### Multi-Step Reasoning

SciAgents implements a "chain-of-evidence" reasoning format:
```
Hypothesis: [Concept A] enhances [Concept B] via [Mechanism C]
Evidence chain:
  Step 1: [Paper X] shows A has property P1
  Step 2: [Paper Y] shows P1 enables Mechanism C
  Step 3: [Paper Z] shows Mechanism C drives B
Confidence: 0.73 (based on edge confidence scores in OG)
```

This format enables both human review and automated scoring.

### Agent Communication

Agents communicate via a shared message bus with structured message types:
- `GraphQuery(node_id, depth, relation_types)` — from exploration to synthesis agents.
- `Hypothesis(chain, confidence, citations)` — from synthesis to critique agent.
- `Critique(hypothesis_id, verdict, suggested_revisions)` — from critique to synthesis agent.

## Evaluation & Benchmarks

SciAgents has been evaluated primarily in the context of materials science and biomaterials research.

### Scientific Hypothesis Quality
- Evaluated by domain experts from the Buehler lab on hypothesis novelty and plausibility.
- Ontology-grounded hypotheses rated higher for scientific plausibility than LLM baseline hypotheses.
- Multi-step reasoning chains significantly improve expert acceptance rates.

### Nature / Advanced Materials Publications
- The SciAgents approach has been validated in publications from the Buehler lab in Advanced Materials and similar venues.
- Hypotheses generated by SciAgents have been tested experimentally in subsequent work.

### Comparison with Baselines
- Outperforms direct LLM prompting (GPT-4, Claude) on expert-assessed hypothesis plausibility in materials science.
- Reasoning chains are more traceable than competing LLM-only approaches.

## Strengths

- **Scientific rigor** — ontology grounding provides a level of scientific rigor absent from pure LLM generation.
- **Interpretability** — reasoning chains are fully auditable by domain experts.
- **Domain adaptability** — the ontology graph approach generalises to any domain with a rich literature corpus.
- **MIT backing** — developed alongside real experimental research, not just as a demo system.
- **Hypothesis quality** — expert evaluations confirm higher plausibility than LLM-only baselines.
- **Provenance tracking** — every claim in the output is linked to a specific paper, enabling easy verification.

## Limitations

- **Domain specificity** — optimised for structured scientific domains (materials, biology); less effective for social sciences or humanities.
- **Ontology construction overhead** — building a high-quality domain ontology requires significant upfront processing of the literature.
- **Static knowledge graph** — the graph is not updated in real-time; recent papers may not be reflected.
- **No experiment execution** — SciAgents generates hypotheses but does not implement or test them.
- **Scale constraints** — graph traversal becomes computationally expensive for very large ontologies (>100k nodes).
- **LLM hallucination risk** — while grounded in the graph, the synthesis agent can still hallucinate if it departs from graph evidence.

## Related Work

- **Idea2Paper** — multi-agent idea generation with KG novelty alignment; similar knowledge graph approach for a different use case.
- **AI-Scientist** (SakanaAI) — end-to-end paper generation; strong on execution, less on hypothesis quality control.
- **ResearchAgent** — iterative idea refinement with literature databases; less structured knowledge representation.
- **BioAgents** — specialised for biology; different technical approach (specialised agents vs. ontology graphs).
- **Biomni** — Stanford biomedical research agent; broader multimodal scope.

## References

1. Buehler, M. C. et al. (2024). *Accelerating Scientific Discovery with SciAgents: A Multi-Agent Intelligent Graph Reasoning Framework for Scientific Discovery*. Advanced Materials.
2. Buehler, M. C. (2024). *SciAgentsDiscovery: Agentic Scientific Discovery*. https://github.com/lamm-mit/SciAgentsDiscovery
3. Pan, S. et al. (2024). *Unifying Large Language Models and Knowledge Graphs: A Roadmap*. arXiv:2306.08302.
4. Yao, S. et al. (2022). *ReAct: Synergizing Reasoning and Acting in Language Models*. ICLR 2023.
5. Schlichtkrull, M. et al. (2018). *Modeling Relational Data with Graph Convolutional Networks*. ESWC 2018.
6. Baek, J. et al. (2024). *ResearchAgent: Iterative Research Idea Generation over Scientific Literature with LLMs*. arXiv:2404.07738.
7. Lu, C. et al. (2024). *The AI Scientist*. arXiv:2408.06292.

---

### Practitioner Notes

**Domain setup:** SciAgents is most effective when initialised with a domain-specific ontology.
Pre-built ontologies for materials science, cell biology, and protein engineering are available in the repository.
For new domains, use the provided ontology construction pipeline with a corpus of 1,000+ domain papers.

**KG quality matters:** The quality of generated hypotheses is bounded by the quality of the underlying ontology.
Running the entity and relation extraction pipeline on high-quality review articles (not just abstract-only corpora) significantly improves ontology richness.
Manual curation of the top-1000 nodes (adding missing relations, correcting erroneous ones) provides the highest ROI for ontology quality.

**Scaling considerations:**
- 10,000 node ontology: fast traversal, manageable memory, suitable for desktop use.
- 100,000 node ontology: requires dedicated server memory; traversal speed decreases but hypothesis quality improves.
- For very large ontologies, consider indexing with Neo4j for efficient graph queries.

**Hypothesis evaluation:**
Generated hypotheses should be reviewed by domain experts before experimental follow-up.
The confidence scores provided by SciAgents are indicative but not perfectly calibrated to actual experimental validity.
The reasoning chains are the most valuable output for expert review, as they expose the logical steps behind each hypothesis.

**Integration with experiment systems:**
The hypothesis output from SciAgents can be fed to AI-Scientist or Agent Laboratory for experimental follow-up.
SciAgents generates the hypothesis; AI-Scientist designs and runs the experiment; the combination covers hypothesis-to-result.
This hybrid pipeline is increasingly common in computational materials science research groups.

**Buehler Lab research context:**
The SciAgents system was developed alongside active experimental research in hierarchical bioinspired materials.
Several hypotheses generated by SciAgents have been validated experimentally, providing ground truth for system evaluation.
The lab uses SciAgents as a daily research tool, not just a published prototype, which informs the system's practical design choices.
