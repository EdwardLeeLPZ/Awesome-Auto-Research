# DeepResearchAgent

> A hierarchical multi-agent research system from Skywork AI that incorporates Autogenesis self-evolution, where a planning agent coordinates specialised lower-level agents to conduct deep, structured research.

## Overview

DeepResearchAgent is an open-source research automation framework developed by Skywork AI.
With over 3,300 GitHub stars, it is a significant contribution to the hierarchical multi-agent paradigm for research tasks.
The key architectural innovation is **Autogenesis**: the system generates and refines its own sub-agent specifications dynamically based on the research task, rather than relying on a fixed set of pre-defined agents.

The hierarchical design separates high-level research planning from low-level information gathering and synthesis, enabling the system to tackle complex, multi-faceted research questions that would overwhelm flat agent architectures.
A high-level planning agent decomposes the research question, specifies the roles and goals of lower-level agents, and coordinates their outputs into a coherent final report.

DeepResearchAgent is part of the growing class of "deep research" systems that go beyond single-round web search to implement iterative, multi-angle investigation.
Unlike DeerFlow or STORM which use fixed sub-agent topologies, DeepResearchAgent's topology is task-adaptive through Autogenesis.

## Architecture

DeepResearchAgent uses a two-tier agent hierarchy with a dynamic self-evolution layer:

```
┌──────────────────────────────────────────────────────┐
│               DeepResearchAgent System                │
│                                                       │
│  ┌─────────────────────────────────────┐             │
│  │         Planning Agent (Tier 1)     │             │
│  │   - Decomposes research question    │             │
│  │   - Generates sub-agent specs       │             │
│  │   - Monitors and coordinates        │             │
│  │   - Synthesises final report        │             │
│  └────────────────┬────────────────────┘             │
│                   │  task decomposition               │
│          ┌────────▼─────────┐                        │
│          │   Autogenesis    │                        │
│          │  (self-evolution │                        │
│          │   of sub-agents) │                        │
│          └────────┬─────────┘                        │
│                   │  dynamic agent generation         │
│     ┌─────────────┼─────────────┐                   │
│     ▼             ▼             ▼                   │
│  Agent-A       Agent-B       Agent-C   (Tier 2)     │
│  (web search) (synthesis) (evaluation)              │
└──────────────────────────────────────────────────────┘
```

The planning agent is a general-purpose reasoning LLM instructed with a structured planning prompt.
Tier-2 agents are instantiated dynamically based on the planning agent's sub-task specifications.
Each tier-2 agent receives a focused sub-task with specific tools and termination criteria.

## Core Workflow

1. **Research question intake** — user provides a research question or topic.
2. **High-level planning** — planning agent analyses the question and generates a research plan with numbered sub-tasks.
3. **Autogenesis** — for each sub-task, the planning agent generates a specification (role, goal, tools, output format) for a lower-level agent.
4. **Sub-agent execution** — tier-2 agents execute their sub-tasks in sequence or parallel, using web search, retrieval, and synthesis tools.
5. **Progress monitoring** — planning agent reviews intermediate outputs and may issue follow-up sub-tasks to fill gaps.
6. **Evidence aggregation** — all tier-2 outputs are consolidated by the planning agent.
7. **Report synthesis** — planning agent writes a coherent, cited final report from aggregated evidence.
8. **Quality check** — optional self-evaluation pass to check consistency and completeness.

## Key Features

- **Autogenesis self-evolution** — the planning agent generates and refines sub-agent specifications dynamically, adapting the agent topology to each specific research task.
- **Hierarchical decomposition** — two-tier architecture cleanly separates strategic planning from tactical execution.
- **Task-adaptive topology** — unlike fixed-topology systems, the number and roles of tier-2 agents vary per task.
- **Tool-equipped sub-agents** — tier-2 agents are equipped with web search, document retrieval, and synthesis capabilities.
- **Skywork AI backing** — developed by a research organisation with expertise in LLM evaluation and benchmarking.

## Technical Implementation

### Autogenesis Mechanism

Autogenesis is the process by which the planning agent generates specifications for its own sub-agents.
The planning agent is prompted to output a structured JSON or YAML specification for each needed sub-agent, including:
- Role description (e.g., "web search specialist for recent academic papers").
- List of tools to use (web search, PDF reader, calculator).
- Termination criteria (e.g., "stop after finding 5 relevant sources").
- Expected output format (e.g., "bullet list of key findings with citations").

This specification is then used to instantiate a tier-2 agent with the appropriate system prompt and tool configuration.
Autogenesis enables the system to create specialised agents for unusual sub-tasks without pre-programming those agents.

### Planning Agent

The planning agent uses chain-of-thought reasoning to:
- Analyse the research question's complexity and scope.
- Identify the information types needed (empirical data, theoretical background, recent developments).
- Create a dependency graph of sub-tasks (which tasks must complete before others can start).
- Assign priority and resource allocation to sub-tasks.

### Synthesis Layer

After all tier-2 agents complete their tasks, the planning agent acts as a synthesis layer:
- Identifies contradictions or gaps between sub-agent outputs.
- Issues corrective sub-tasks if needed.
- Writes the final report with proper citation of sub-agent evidence sources.
- Produces an executive summary for quick consumption.

## Evaluation & Benchmarks

DeepResearchAgent has been evaluated on long-form research tasks and deep research benchmarks.

### DeepResearch Bench
- A multi-domain benchmark for deep research agent quality.
- DeepResearchAgent is among the top-performing systems in the open-source category.
- Hierarchical decomposition improves performance on multi-faceted questions versus flat agents.

### Internal Evaluations (Skywork AI)
- Evaluated on scientific question answering, technology trend analysis, and competitive intelligence tasks.
- Autogenesis provides measurable improvement over fixed-topology baselines on novel task types.
- Planning agent generates useful agent specifications for 85%+ of research sub-tasks in internal tests.

## Strengths

- **Task-adaptive architecture** — Autogenesis enables the system to handle unusual research tasks without pre-programmed sub-agents.
- **Clean separation of concerns** — strategic planning and tactical execution are well-separated, making the system easier to debug and extend.
- **Skywork AI engineering quality** — professional software engineering standards with comprehensive documentation.
- **Hierarchical robustness** — partial failure of a tier-2 agent does not crash the system; planning agent can retry or re-route.

## Limitations

- **Autogenesis reliability** — dynamically generated sub-agent specs can be poorly formed for unusual tasks, leading to agent confusion.
- **Planning agent bottleneck** — all coordination goes through the planning agent; its quality directly limits system performance.
- **No persistent memory** — unlike ARIS (Obsidian/Zotero), there is no long-term knowledge retention across research sessions.
- **LLM dependency** — performance is strongly dependent on the planning agent's underlying LLM quality.
- **Less community tooling** — compared to GPT Researcher or DeerFlow, fewer plugins and integrations are available.

## Related Work

- **GPT Researcher** — flat multi-agent web research; simpler architecture, lower overhead, widely deployed.
- **DeerFlow** (ByteDance) — fixed-topology sub-agent orchestration with LangGraph; more predictable but less adaptive.
- **STORM** (Stanford) — multi-perspective structured outline generation; different task formulation.
- **Agent Laboratory** — role-specialised agents for full research cycle including experiments; broader scope.
- **MiroThinker** — single-model RL approach; different architecture philosophy.

## References

1. Skywork AI. (2025). *DeepResearchAgent*. https://github.com/SkyworkAI/DeepResearchAgent
2. Wang, L. et al. (2023). *A Survey on Large Language Model based Autonomous Agents*. arXiv:2308.11432.
3. Shinn, N. et al. (2023). *Reflexion: Language Agents with Verbal Reinforcement Learning*. NeurIPS 2023.
4. Hong, S. et al. (2023). *MetaGPT: Meta Programming for A Multi-Agent Collaborative Framework*. arXiv:2308.00352.
5. Park, J. S. et al. (2023). *Generative Agents: Interactive Simulacra of Human Behavior*. UIST 2023.
6. Schmidgall, S. et al. (2024). *Agent Laboratory*. arXiv:2501.04227.

---

### Practitioner Notes

**Getting started:** DeepResearchAgent is available as a pip-installable Python package.
Configuration requires an LLM API key (OpenAI, Anthropic, or compatible) and a web search API key (Serper, Bing, or SerpAPI).
The planning agent model and tier-2 agent models can be configured independently for cost optimisation.

**Cost optimisation strategies:**
- Use a high-capability model (GPT-4o, Claude claude-sonnet-4) for the planning agent where strategic reasoning matters.
- Use a cheaper, faster model (GPT-4o-mini, Claude claude-haiku-4) for tier-2 execution agents that perform repetitive retrieval tasks.
- Limit the maximum number of tier-2 agents per task (default: 5) to control costs.
- Enable caching for web search results to avoid redundant API calls on repeated queries.

**Autogenesis quality tips:**
The planning agent's sub-agent specification quality depends heavily on the prompt quality for the planning step.
Including a few in-context examples of good sub-agent specifications in the planning prompt significantly improves Autogenesis output.
For domain-specific tasks (e.g., biomedical research), including domain-specific tool names and data sources in the planning context improves sub-agent utilisation.

**Integration patterns:**
DeepResearchAgent can be integrated as a research sub-system in larger pipelines.
Its output (structured report with citations) can be used as input to writing agents (STORM, GPT Researcher) for final report polishing.
The hierarchical architecture maps well to LangGraph for teams using the LangChain ecosystem.

**Known failure modes:**
- Planning agent occasionally generates sub-agent specs with overlapping roles, leading to redundant work.
- Autogenesis fails silently for very unusual tasks where the planning agent lacks domain knowledge to specify appropriate sub-agents.
- Inter-agent communication can become bottlenecked when multiple tier-2 agents complete simultaneously and queue reports to the planning agent.

**Comparison with flat architectures:**
For simple single-topic research questions, flat agents like GPT Researcher are faster and cheaper.
DeepResearchAgent's hierarchical architecture provides the most benefit for questions requiring 4+ distinct research angles or cross-domain synthesis.

**Benchmark comparison notes:**
DeepResearchAgent was evaluated on DeepResearch Bench, which tests across six research domains.
Hierarchical decomposition shows the largest relative improvement on "technology landscape" and "competitive analysis" queries where multiple independent research threads must be synthesised.
Single-topic "explain this concept" queries show minimal improvement over flat architectures, suggesting the overhead is not justified for simple tasks.

**Research roadmap (community expectations):**
The Skywork AI team has indicated plans for persistent memory across sessions, enhanced Autogenesis with self-critique, and an evaluation dashboard for monitoring agent quality over time.
Community contributions for domain-specific planning prompts (biomedical, legal, financial) are actively encouraged.

**Academic context:**
The Autogenesis concept has roots in meta-learning and self-organising systems research.
Related academic work includes AutoML (automatically designing ML pipelines), AutoPrompt (automatically generating prompts), and self-play approaches in RL.
Applying dynamic agent specification to multi-agent research tasks is a genuinely novel contribution that deserves further formal investigation.
Future work should include ablation studies comparing fixed vs. dynamic agent topologies across diverse research task categories.

**Version history:** DeepResearchAgent v1.0 used a flat two-level hierarchy.
v2.0 introduced Autogenesis for dynamic sub-agent specification.
Community benchmarks showed measurable quality improvement in v2.0 for complex multi-angle queries.
