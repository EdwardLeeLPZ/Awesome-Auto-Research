# ARIS (Auto-claude-code-research-in-sleep)

> An overnight unattended research agent built on Claude Code and MCP servers, with cross-model review loops and deep integration with Zotero, Obsidian, Kimi, and DeepSeek.

## Overview

ARIS (Auto-claude-code-research-in-sleep) is a research automation agent created by wanshuiyin that runs unattended overnight using Claude Code as its execution backbone and Model Context Protocol (MCP) servers as its tool interface.
With over 5,800 GitHub stars, ARIS has become one of the most popular practical research automation tools in the community.

The core philosophy of ARIS is *run while you sleep*: configure a research task before you go to bed, and wake up to completed experiments, generated reports, and synthesised findings — without writing a single line of automation code yourself.
Unlike systems that require continuous user oversight, ARIS is designed to operate in fully autonomous batches for 6–10 hour stretches.

ARIS sits at the intersection of code agent, literature assistant, and research orchestrator.
It uses Claude Code for implementation tasks, wraps those capabilities with MCP servers for modular tool access, and connects to academic management systems (Zotero) and knowledge bases (Obsidian) for persistent research context that survives across sessions.

The cross-model review loop distinguishes ARIS from simpler overnight agents.
Rather than trusting a single model's output, ARIS routes generated content through alternative models (Kimi, DeepSeek) for independent verification, reducing hallucination risk in long-horizon tasks.

## Architecture

ARIS uses a layered architecture with Claude Code at the centre and MCP servers providing modular tool access:

```
┌──────────────────────────────────────────────────────────┐
│                       ARIS Core                           │
│                                                           │
│  ┌─────────────────┐         ┌──────────────────────┐   │
│  │  Claude Code    │         │   MCP Servers        │   │
│  │  (backbone)     │◄───────►│  - File system       │   │
│  │                 │         │  - Web / arXiv search │   │
│  └────────┬────────┘         │  - Zotero API        │   │
│           │                  │  - Obsidian sync      │   │
│           ▼                  │  - DeepSeek API       │   │
│  ┌─────────────────┐         │  - Kimi API           │   │
│  │  Task Queue     │         └──────────────────────┘   │
│  │  & Scheduler    │                                     │
│  └────────┬────────┘                                     │
│           │                                              │
│    ┌──────▼──────────────────┐                          │
│    │  Cross-Model Review     │                          │
│    │  (Kimi / DeepSeek)      │                          │
│    └──────┬──────────────────┘                          │
│           │                                              │
└───────────┼──────────────────────────────────────────────┘
            ▼
    Research outputs: reports, code, Zotero entries, Obsidian notes
```

The MCP protocol serves as a standardised JSON-RPC interface for tool access, enabling modular replacement of individual tool servers without changing the agent's core logic.
Any MCP-compatible server can be added to extend ARIS's capabilities.

## Core Workflow

1. **Task specification** — user defines a research objective (topic, scope, desired output format) in a configuration file.
2. **Schedule** — user runs the agent at bedtime, optionally via a cron job for recurring research cycles.
3. **Literature discovery** — agent searches arXiv, Semantic Scholar, and web sources via MCP search servers.
4. **Reference management** — discovered papers are automatically added to Zotero with metadata extraction and auto-generated annotations.
5. **Knowledge synthesis** — agent summarises findings and creates inter-connected notes in Obsidian.
6. **Experiment design** — for empirical tasks, agent designs experiments and generates code via Claude Code.
7. **Code execution** — experiments run in the local environment with all output captured and logged.
8. **Cross-model review** — generated content is passed to Kimi or DeepSeek for independent critique and factual verification.
9. **Revision loop** — Claude Code revises its outputs based on reviewer feedback (typically 2–3 rounds).
10. **Report generation** — final report is produced in Markdown, ready for review in the morning.
11. **Notification** — optional system notification or email on completion.

## Key Features

- **Unattended overnight operation** — designed to run reliably for 6–10 hours without user input; structured error handling prevents individual failures from halting the full pipeline.
- **Cross-model review loop** — using multiple LLMs (Claude, Kimi, DeepSeek) for generation and critique reduces hallucination risk in long-horizon autonomous tasks.
- **Zotero integration** — direct API connection to Zotero adds papers, extracts metadata, organises references into session-specific collections, and attaches auto-generated summaries.
- **Obsidian sync** — research notes and knowledge graphs are written directly to Obsidian vaults using `[[wiki-links]]`, creating persistent, navigable memory that accumulates across sessions.
- **MCP server architecture** — modular tool interface via Model Context Protocol; community-contributed MCP servers can extend the system without forking core code.
- **Claude Code backbone** — inherits Claude Code's strong code generation, file manipulation, terminal execution, and multi-step reasoning capabilities.
- **Multi-model flexibility** — routes different tasks to different models based on cost and capability; not locked into a single provider.
- **Configurable review depth** — number of review rounds and reviewer models are configurable per task type.

## Technical Implementation

### MCP Protocol Integration

ARIS uses the Model Context Protocol (MCP) as a standardised tool interface layer.
Each capability domain is implemented as a separate MCP server that speaks JSON-RPC:
- **File system server** — read, write, and organise output files.
- **Search server** — queries arXiv API, Semantic Scholar, and web search engines.
- **Zotero server** — wraps the Zotero Web API for reference management.
- **Obsidian server** — writes Markdown files with proper Obsidian-compatible formatting.
- **DeepSeek/Kimi servers** — proxy API servers that route to the respective model endpoints.

This modular design means any MCP-compatible server (file monitoring, database access, lab equipment APIs) can be plugged in without modifying ARIS core logic.

### Cross-Model Review Loop

The review loop is implemented as a sequential validation pipeline:
1. **Generation phase** — Claude Code generates research content (analysis, code, report sections).
2. **Review phase** — content is passed to a reviewer model with a structured critique prompt covering factual accuracy, logical consistency, and completeness.
3. **Revision phase** — critique is fed back to Claude Code, which produces a revised output.
4. **Convergence check** — if the reviewer's score exceeds a threshold, the loop terminates; otherwise it continues up to a maximum round count.

This adversarial dynamic is inspired by the peer review loops in AI-Scientist and EvoScientist, adapted for general research rather than ML-specific experiments.

### Long-Run Reliability

ARIS implements several mechanisms to ensure reliability over multi-hour runs:
- **Checkpointing** — intermediate outputs are saved after each major stage, enabling partial recovery.
- **Retry logic** — API failures trigger exponential backoff retries before aborting.
- **Modular task isolation** — failures in one sub-task do not cascade to others; partial results are preserved.
- **Log verbosity** — detailed logs capture all tool calls, model outputs, and errors for post-run debugging.

## Evaluation & Benchmarks

ARIS does not publish formal results on standardised benchmarks.
Its evaluation is inherently practical: does it produce useful research outputs unattended?

### Community Adoption Metrics
- 5,800+ GitHub stars as of April 2026, placing it firmly in the 🏆 Landmark tier by community impact.
- Multiple domain-specific forks (biology, NLP, materials science) indicate real-world research use.
- Active issue tracker with feature requests and bug reports from practising researchers.

### Qualitative Assessment
- The cross-model review loop is reported by users to substantially reduce factual errors versus single-model overnight runs.
- Zotero + Obsidian integration addresses a gap other systems ignore: long-term reference organisation and knowledge retention.
- The overnight-run paradigm is unique in the landscape; most competing systems require active user oversight.

### Limitations of Evaluation
- No standard benchmark measures "quality of autonomous overnight research synthesis."
- Task diversity (literature review vs. experiment automation vs. report writing) makes uniform evaluation difficult.
- Future work could evaluate against GPT Researcher or DeerFlow on equivalent tasks.

## Strengths

- **Truly unattended operation** — the most distinctive feature in the ecosystem; runs reliably for hours without supervision.
- **Cross-model quality control** — multi-model review is a practical and effective hallucination mitigation strategy for long-horizon research.
- **Deep tool integration** — Zotero and Obsidian integrations address the full research workflow, not just the LLM inference layer.
- **MCP architecture** — modular, extensible; community can add tools without forking the core codebase.
- **Practical philosophy** — designed for working researchers and their actual daily workflow, not benchmark maximisation.
- **High community adoption** — 5,800+ stars confirm real-world utility beyond a niche prototype.
- **Composability** — easily integrated into broader workflows; the overnight batch paradigm complements daytime interactive tools.

## Limitations

- **Requires Claude API** — the backbone is Claude Code; there is no open-weight alternative execution path as of this writing.
- **No Docker sandboxing** — experiments run in the user's environment; potentially destructive operations are possible.
- **No formal benchmarks** — absence of standardised evaluation results makes capability comparison with other systems difficult.
- **API cost at scale** — overnight Claude Code sessions for complex research tasks can incur substantial API costs.
- **Configuration complexity** — initial setup of all MCP servers (Zotero, Obsidian, search providers) requires non-trivial configuration effort.
- **Limited multimodal support** — primarily text-focused; limited ability to analyse figures, tables, or images in papers.

## Related Work

- **AI-Scientist** (SakanaAI) — end-to-end paper generation with structured peer review loop; more rigorous but specific to ML research templates.
- **GPT Researcher** — multi-agent web research synthesis; does not run unattended overnight or integrate with Zotero/Obsidian.
- **Agent Laboratory** — multi-role agent for the full research cycle; similar ambition but different implementation philosophy.
- **DeerFlow** (ByteDance) — literature and code pipeline with LangGraph; structured orchestration without overnight specialisation.
- **EvoScientist** — six-agent team with RL self-improvement loop; more structured feedback mechanisms.

## References

1. wanshuiyin. (2025). *ARIS: Auto-claude-code-research-in-sleep*. https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep
2. Anthropic. (2024). *Claude Code: Agentic Coding in the Terminal*. https://docs.anthropic.com/claude-code
3. Anthropic. (2024). *Model Context Protocol (MCP)*. https://modelcontextprotocol.io/
4. Zotero REST API v3 documentation. https://www.zotero.org/support/dev/web_api/v3/start
5. Obsidian developer documentation. https://docs.obsidian.md/
6. Lu, C. et al. (2024). *The AI Scientist*. arXiv:2408.06292.
7. Schmidgall, S. et al. (2024). *Agent Laboratory*. arXiv:2501.04227.

---

### Implementation Notes for Practitioners

**Setup checklist:**
1. Install Claude Code CLI and authenticate with Anthropic API key.
2. Install MCP servers: `npm install -g @modelcontextprotocol/server-filesystem`, plus Zotero and Obsidian servers.
3. Configure `aris.yaml` with your research topic, output paths, Zotero API key, and Obsidian vault path.
4. Set reviewer models in config (`kimi` or `deepseek` for the review loop).
5. Run `aris start --config aris.yaml` before going to sleep.
6. Review output files in your Obsidian vault and Zotero library in the morning.

**Cost estimation:**
A typical 8-hour overnight run processing 20 papers and generating one 5,000-word report costs approximately $8–15 with Claude claude-sonnet-4 as the backbone and Claude claude-haiku-4 for review steps, based on community reports.
Using DeepSeek for the review loop reduces costs significantly (DeepSeek V3 is 20× cheaper than Claude claude-sonnet-4 per token).

**Best use cases:**
- Weekly literature synthesis on a fast-moving research area.
- Pre-meeting research briefings: run overnight, review in the morning.
- Experiment brainstorming: provide a problem statement, receive hypothesis + initial code by morning.
- Report drafting: provide bullet points, receive a structured draft.

**Limitations in practice:**
- Claude Code's context window limits how many papers can be processed in one session without summarisation.
- Zotero API rate limits mean very large literature reviews (>100 papers) may require multiple sessions.
- The Obsidian integration is write-only; ARIS does not read existing Obsidian notes as context.

8. Buehler, M. C. et al. (2024). *Accelerating Scientific Discovery with SciAgents*. Advanced Materials.
