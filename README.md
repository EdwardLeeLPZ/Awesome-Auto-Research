<div align="center">

# 🧬 Awesome Auto Research

*Tracking the systems that automate scientific research — from single-purpose code agents to full idea-to-paper pipelines*

[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/sindresorhus/awesome)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Last Updated](https://img.shields.io/badge/last%20updated-March%202026-blue?style=flat-square)](#)
[![Reports](https://img.shields.io/badge/in--depth%20reports-23-orange?style=flat-square)](reports/)

Autonomous research systems have gone from weekend experiments to NeurIPS Spotlight papers in under two years. This repository catalogues 30+ active projects across the full spectrum — lightweight literature scrapers, multi-agent experiment runners, and end-to-end systems that can take a vague research direction and output a reviewable manuscript — together with a [capability comparison matrix](#-capability-matrix), a [pipeline map](#️-research-automation-landscape), a [tool selection guide](#-how-to-choose-the-right-tool), and **[in-depth technical reports](reports/)** for the most impactful systems.

**Latest Additions (2026-03-20):** DATAGEN (1.6k-star multi-agent analyzer), Deeper-Seeker (OpenAI Deep Research alternative), BioAgents (biology-specialized framework)

</div>

---

## 🗺️ Research Automation Landscape

Understanding *where* each tool fits in the research process is key to choosing the right one.

```
╔════════════════════════════════════════════════════════════════════════════════╗
║                     THE AUTONOMOUS RESEARCH PIPELINE                           ║
╠══════════════╦════════════════╦════════════════╦════════════╦══════════════════╣
║   DISCOVER   ║   SYNTHESIZE   ║  HYPOTHESIZE   ║   EXECUTE  ║  WRITE & REVIEW  ║
║              ║                ║                ║            ║                  ║
║  Idea2Paper  ║ STORM          ║ AI-Scientist   ║ OpenHands  ║ AI-Scientist     ║
║  SciAgents   ║ GPT Researcher ║ AI-Researcher  ║ SWE-agent  ║ Agent Lab        ║
║  ResAgent    ║ PaperQA2       ║ Agent Lab      ║ Aider      ║ AI-Researcher    ║
║              ║ OpenScholar    ║ autoresearch   ║ AIDE       ║                  ║
║              ║ DeerFlow       ║                ║            ║                  ║
╠══════════════╩════════════════╩════════════════╩════════════╩══════════════════╣
║                     ◄── FULL PIPELINE (End-to-End) ──►                         ║
║  autoresearch · AI-Scientist v1/v2 · AI-Researcher · Agent Laboratory · Biomni ║
╚════════════════════════════════════════════════════════════════════════════════╝
```

---

## 📑 Contents

- [📊 Capability Matrix](#-capability-matrix)
- [🚀 End-to-End Research Systems](#-end-to-end-research-systems)
- [🔍 Literature Review & Deep Research](#-literature-review--deep-research)
- [⚗️ Experiment Automation & Code Agents](#️-experiment-automation--code-agents)
- [✍️ Idea Generation & Writing Assistants](#️-idea-generation--writing-assistants)
- [📐 Benchmarks & Evaluation Suites](#-benchmarks--evaluation-suites)
- [🎓 Academic Surveys & Papers](#-academic-surveys--papers)
- [🧾 In-Depth Analysis Reports](#-in-depth-analysis-reports)
- [🧭 How to Choose the Right Tool](#-how-to-choose-the-right-tool)
- [🤝 Contributing](#-contributing)
- [📈 Star History](#-star-history)

---

## 📊 Capability Matrix

The **Tier** column groups systems by overall impact and maturity — this same tier label appears in every section table below, so you can quickly cross-reference.

| Tier | System | Lit Review | Hypothesis | Code Exec | Paper Writing | Peer Review | Multimodal | Fully Local |
|:----:|--------|:----------:|:----------:|:---------:|:-------------:|:-----------:|:----------:|:-----------:|
| 🏆 | [OpenHands](https://github.com/All-Hands-AI/OpenHands) | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ✅ |
| 🏆 | [autoresearch](https://github.com/karpathy/autoresearch) | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| 🏆 | [DeerFlow](https://github.com/bytedance/deer-flow) | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ⚠️ |
| 🏆 | [STORM](https://github.com/stanford-oval/storm) | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ⚠️ |
| 🏆 | [GPT Researcher](https://github.com/assafelovic/gpt-researcher) | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ⚠️ |
| 🏆 | [SWE-agent](https://github.com/SWE-agent/SWE-agent) | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ✅ |
| 🏆 | [deep-research](https://github.com/dzhng/deep-research) | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ⚠️ |
| 🏆 | [AI-Scientist](https://github.com/SakanaAI/AI-Scientist) | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ⚠️ |
| 🏆 | [Open Deep Research](https://github.com/langchain-ai/open_deep_research) | ✅ | ❌ | ⚠️ | ✅ | ❌ | ❌ | ✅ |
| 🏆 | [PaperQA2](https://github.com/Future-House/paper-qa) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| 🏆 | [MiroThinker](https://github.com/MiroMindAI/MiroThinker) | ✅ | ❌ | ❌ | ✅ | ❌ | ⚠️ | ✅ |
| 🏆 | [Agent Laboratory](https://github.com/SamuelSchmidgall/AgentLaboratory) | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ⚠️ |
| 🏆 | [AI-Researcher](https://github.com/HKUDS/AI-Researcher) | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |
| 🏆 | [DATAGEN](https://github.com/starpig1129/DATAGEN) | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ | ⚠️ |
| 🌟 | [Biomni](https://github.com/snap-stanford/Biomni) | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ⚠️ |
| 🌟 | [AI-Scientist-v2](https://github.com/SakanaAI/AI-Scientist-v2) | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ⚠️ |
| 🌟 | [OpenScholar](https://github.com/AkariAsai/OpenScholar) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| 🌟 | [EvoScientist](https://github.com/EvoScientist/EvoScientist) | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ⚠️ |
| 🌟 | [ToolUniverse](https://github.com/mims-harvard/ToolUniverse) | ✅ | ⚠️ | ❌ | ⚠️ | ❌ | ❌ | ⚠️ |
| 🔬 | [BioAgents](https://github.com/bio-xyz/BioAgents) | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |

> **Tier legend:**  🏆 Landmark — defined or significantly shaped the field  ·  🌟 Flagship — mature, widely adopted, strong results  ·  🔬 Notable — active, specialized, or emerging  
> **Capability legend:**  ✅ Native  ·  ⚠️ Partial / requires setup  ·  ❌ Not supported

---

## 🚀 End-to-End Research Systems

> Systems that automate the **full research lifecycle**: discovery → hypothesis → experiments → manuscript. The most ambitious category — each one aims to replace or augment the entire scientific process.

| Tier | Project | Stars | Core Approach | Notes | Report |
|:----:|---------|-------|---------------|-------|:------:|
| 🏆 | **[autoresearch](https://github.com/karpathy/autoresearch)**<br><sub>Andrej Karpathy</sub> | ![](https://img.shields.io/github/stars/karpathy/autoresearch?style=social) | 630-line agent; reads its own training script, forms hypotheses, modifies code, runs hundreds of experiments overnight | Minimal & self-contained; seminal proof-of-concept | — |
| 🏆 | **[DATAGEN](https://github.com/starpig1129/DATAGEN)**<br><sub>starpig1129 · 2025</sub> | ![](https://img.shields.io/github/stars/starpig1129/DATAGEN?style=social) | Multi-agent orchestration: hypothesis generation → data analysis → visualization → report generation | LangChain + LangGraph; advanced state tracking via Note Taker agent | [📄](reports/datagen.md) |
| 🏆 | **[AI-Scientist](https://github.com/SakanaAI/AI-Scientist)**<br><sub>SakanaAI · 2024</sub> | ![](https://img.shields.io/github/stars/SakanaAI/AI-Scientist?style=social) | Template-driven idea generation → experiment loop → LaTeX write-up → agentic peer review | First comprehensive end-to-end system; multiple ML research templates | [📄](reports/ai-scientist.md) |
| 🏆 | **[AI-Scientist-v2](https://github.com/SakanaAI/AI-Scientist-v2)**<br><sub>SakanaAI · 2025</sub> | ![](https://img.shields.io/github/stars/SakanaAI/AI-Scientist-v2?style=social) | BFTS (beam-search agentic tree search) + AIDE for code generation | First AI-written paper accepted through standard peer review | [📄](reports/ai-scientist-v2.md) |
| 🌟 | **[AI-Researcher](https://github.com/HKUDS/AI-Researcher)**<br><sub>HKUDS · NeurIPS 2025 Spotlight</sub> | ![](https://img.shields.io/github/stars/HKUDS/AI-Researcher?style=social) | LiteLLM multi-provider + Docker-sandboxed execution + Gradio UI | Broadest LLM compatibility; strong reproducibility focus | [📄](reports/ai-researcher.md) |
| 🌟 | **[Agent Laboratory](https://github.com/SamuelSchmidgall/AgentLaboratory)**<br><sub>SamuelSchmidgall · 2024</sub> | ![](https://img.shields.io/github/stars/SamuelSchmidgall/AgentLaboratory?style=social) | Role-specialized multi-agent: Professor → PhD Student → Reviewer | arXiv + HuggingFace integration for literature and datasets | [📄](reports/agent-laboratory.md) |
| 🌟 | **[EvoScientist](https://github.com/EvoScientist/EvoScientist)**<br><sub>EvoScientist Team · 2026</sub> | ![](https://img.shields.io/github/stars/EvoScientist/EvoScientist?style=social) | Six-agent team (plan, research, code, analyze, write, review) with RL self-improvement | ICAIS 2025 Best Paper; #1 on DeepResearch Bench II; human-on-the-loop paradigm | [📄](reports/evoscientist.md) |
| 🔬 | **[MedResearcher-R1](https://github.com/AQ-MedAI/MedResearcher-R1)**<br><sub>AQ-MedAI · 2025</sub> | ![](https://img.shields.io/github/stars/AQ-MedAI/MedResearcher-R1?style=social) | KG-grounded multi-hop QA synthesis + trajectory generation for medical AI training | SOTA on MedBrowseComp; open 32B model + full training data released | [📄](reports/medresearcher-r1.md) |
| 🔬 | **[Biomni](https://github.com/snap-stanford/Biomni)**<br><sub>Stanford SNAP · 2025</sub> | ![](https://img.shields.io/github/stars/snap-stanford/Biomni?style=social) | Biomedical datalake + know-how library + sandboxed code execution | Domain-specialized for biology & medicine; multimodal inputs | [📄](reports/biomni.md) |
| 🔬 | **[BioAgents](https://github.com/bio-xyz/BioAgents)**<br><sub>bio-xyz · 2025</sub> | ![](https://img.shields.io/github/stars/bio-xyz/BioAgents?style=social) | Specialized literature + analysis agents for biological sciences; state-of-the-art on BixBench | SOTA analysis agent (48.78% open-answer); configurable dual-agent backend | [📄](reports/bioagents.md) |
| 🔬 | **[ARIS](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep)**<br><sub>wanshuiyin</sub> | ![](https://img.shields.io/github/stars/wanshuiyin/Auto-claude-code-research-in-sleep?style=social) | Claude Code + MCP servers; runs overnight unattended | Cross-model review loops; Zotero + Obsidian integration | — |
| 🔬 | **[Idea2Paper](https://github.com/AgentAlphaAGI/Idea2Paper)**<br><sub>AgentAlphaAGI</sub> | ![](https://img.shields.io/github/stars/AgentAlphaAGI/Idea2Paper?style=social) | Multi-agent + Knowledge Graph alignment for novelty checking | Semantic Scholar + arXiv grounding; idea → draft pipeline | — |

---

## 🔍 Literature Review & Deep Research

> Systems specialized in **information gathering, synthesis, and structured report generation**. The entry point for most research workflows — and often the most practical category for daily use.

| Tier | Project | Stars | Core Approach | Notes | Report |
|:----:|---------|-------|---------------|-------|:------:|
| 🏆 | **[deep-research](https://github.com/dzhng/deep-research)**<br><sub>dzhng (Aomni) · 2025</sub> | ![](https://img.shields.io/github/stars/dzhng/deep-research?style=social) | Recursive depth/breadth search with Firecrawl + LLM extraction; <500 LoC reference scaffold | Most-forked deep-research scaffold; direct inspiration for Open Deep Research and DeerFlow | [📄](reports/deep-research.md) |
| 🏆 | **[STORM](https://github.com/stanford-oval/storm)**<br><sub>Stanford OVAL · NAACL 2024</sub> | ![](https://img.shields.io/github/stars/stanford-oval/storm?style=social) | Multi-perspective question asking + DSPy pipeline | Generates full Wikipedia-style articles with citations; Co-STORM for collaborative mode | [📄](reports/storm.md) |
| 🏆 | **[GPT Researcher](https://github.com/assafelovic/gpt-researcher)**<br><sub>assafelovic · 2023</sub> | ![](https://img.shields.io/github/stars/assafelovic/gpt-researcher?style=social) | Parallel web scraping agents + LangGraph orchestration | Outputs 5–6 page cited report (PDF / Docx / MD); MCP server support | [📄](reports/gpt-researcher.md) |
| 🏆 | **[MiroThinker](https://github.com/MiroMindAI/MiroThinker)**<br><sub>MiroMind AI · 2025</sub> | ![](https://img.shields.io/github/stars/MiroMindAI/MiroThinker?style=social) | RL-trained open-source agent (30B / 235B) with 256K context + 300 tool calls | SOTA on BrowseComp (88.2 H1, 74.0 open); step-verifiable long-chain reasoning | [📄](reports/mirothinker.md) |
| 🌟 | **[CognitiveKernel-Pro](https://github.com/Tencent/CognitiveKernel-Pro)**<br><sub>Tencent AI Lab · 2025</sub> | ![](https://img.shields.io/github/stars/Tencent/CognitiveKernel-Pro?style=social) | SFT-trained Qwen3-8B + Playwright web engine + multi-agent (web/file/main) | Outperforms RL-trained WebDancer/WebSailor on GAIA using SFT-only recipe; fully open model & data | [📄](reports/cognitivekernel-pro.md) |
| 🏆 | **[DeerFlow](https://github.com/bytedance/deer-flow)**<br><sub>ByteDance · 2025</sub> | ![](https://img.shields.io/github/stars/bytedance/deer-flow?style=social) | Sub-agent orchestration with persistent memory + InfoQuest + LangGraph | Uniquely combines deep research with code generation in one pipeline | [📄](reports/deerflow.md) |
| 🌟 | **[Deeper-Seeker](https://github.com/HarshJ23/Deeper-Seeker)**<br><sub>HarshJ23 · 2024</sub> | ![](https://img.shields.io/github/stars/HarshJ23/Deeper-Seeker?style=social) | Iterative research with follow-up questions + multi-step query generation + report synthesis | OSS alternative to OpenAI's Deep Research; Exa integration for web search | [📄](reports/deeper-seeker.md) |
| 🌟 | **[PaperQA2](https://github.com/Future-House/paper-qa)**<br><sub>Future House · ICLR 2024</sub> | ![](https://img.shields.io/github/stars/Future-House/paper-qa?style=social) | Iterative RAG over full-text PDFs using tantivy search index | Highest-accuracy Q&A from local scientific papers; outperforms Perplexity Pro | [📄](reports/paperqa2.md) |
| 🌟 | **[OpenScholar](https://github.com/AkariAsai/OpenScholar)**<br><sub>Asai et al. · Nature 2024</sub> | ![](https://img.shields.io/github/stars/AkariAsai/OpenScholar?style=social) | Dense retrieval (Contriever) over 45M open-access papers | Outperforms PaperQA2 on scientific Q&A; evidence-grounded answers | [📄](reports/openscholar.md) |
| 🌟 | **[Open Deep Research](https://github.com/langchain-ai/open_deep_research)**<br><sub>LangChain · 2025</sub> | ![](https://img.shields.io/github/stars/langchain-ai/open_deep_research?style=social) | LangGraph workflow + MCP tool plugins + LangSmith tracing | Reference implementation from LangChain; highly configurable | [📄](reports/open-deep-research.md) |
| 🌟 | **[ToolUniverse](https://github.com/mims-harvard/ToolUniverse)**<br><sub>Harvard Medical School · 2025</sub> | ![](https://img.shields.io/github/stars/mims-harvard/ToolUniverse?style=social) | AI-Tool Interaction Protocol; 1,000+ tools (ML models, datasets, APIs, packages) | Universal LLM support (Claude, GPT, Gemini, Qwen, Deepseek); 68+ pre-built research skills | [📄](reports/tooluniverse.md) |
| 🔬 | **[Tongyi DeepResearch](https://github.com/Alibaba-NLP/DeepResearch)**<br><sub>Alibaba NLP · 2025</sub> | ![](https://img.shields.io/github/stars/Alibaba-NLP/DeepResearch?style=social) | RL-trained agentic LLM (30.5B, GRPO) | SOTA on long-horizon information-seeking benchmarks; open-weight model | — |
| 🔬 | **[DeepResearchAgent](https://github.com/SkyworkAI/DeepResearchAgent)**<br><sub>Skywork AI</sub> | ![](https://img.shields.io/github/stars/SkyworkAI/DeepResearchAgent?style=social) | Hierarchical multi-agent + Autogenesis self-evolution | Planning agent coordinates specialized lower-level agents | — |
| 🔬 | **[II-Researcher](https://github.com/Intelligent-Internet/ii-researcher)**<br><sub>Intelligent Internet · 2025</sub> | ![](https://img.shields.io/github/stars/Intelligent-Internet/ii-researcher?style=social) | BAML-structured LLM functions + multi-provider web search + async reflection loop | 84.12% on Frames multi-hop benchmark; MCP server support; pip-installable | [📄](reports/ii-researcher.md) |

---

## ⚗️ Experiment Automation & Code Agents

> The "hands" of an autonomous research pipeline. These systems write, execute, debug, and iterate on code — essential when a hypothesis needs to become a running experiment.

| Tier | Project | Stars | Core Approach | Notes | Report |
|:----:|---------|-------|---------------|-------|:------:|
| 🏆 | **[OpenHands](https://github.com/All-Hands-AI/OpenHands)**<br><sub>All-Hands-AI · 2024</sub> | ![](https://img.shields.io/github/stars/All-Hands-AI/OpenHands?style=social) | Composable Python agent library; file editing + terminal + web browsing | **72% on SWE-Bench Verified** — best-in-class; production-ready UI | [📄](reports/openhands.md) |
| 🌟 | **[SWE-agent](https://github.com/SWE-agent/SWE-agent)**<br><sub>Princeton NLP · 2024</sub> | ![](https://img.shields.io/github/stars/SWE-agent/SWE-agent?style=social) | Agent-Computer Interface (ACI) giving structured file/bash/edit access | ~19% on SWE-Bench (full); widely used as research baseline | [📄](reports/swe-agent.md) |
| 🌟 | **[Aider](https://github.com/Aider-AI/aider)**<br><sub>Aider-AI · 2023</sub> | ![](https://img.shields.io/github/stars/Aider-AI/aider?style=social) | AI pair programming in terminal with native Git integration | ~18% on SWE-Bench; fastest daily iteration loop; supports 60+ models | — |
| 🔬 | **[AutoGPT](https://github.com/Significant-Gravitas/AutoGPT)**<br><sub>Significant Gravitas · 2023</sub> | ![](https://img.shields.io/github/stars/Significant-Gravitas/AutoGPT?style=social) | Plugin-based autonomous agent platform + Forge builder framework | Historically seminal; sparked the autonomous agent movement | [📄](reports/autogpt.md) |
| 🔬 | **[AIDE](https://github.com/WecoAI/aideml)**<br><sub>WecoAI · 2024</sub> | ![](https://img.shields.io/github/stars/WecoAI/aideml?style=social) | Tree-search over ML solution space with iterative code refinement | ML-experiment-specific; used internally by AI-Scientist-v2 | — |
| 🔬 | **[AutoDidact](https://github.com/dCaples/AutoDidact)**<br><sub>dCaples · 2025</sub> | ![](https://img.shields.io/github/stars/dCaples/AutoDidact?style=social) | GRPO RL + self-generated Q&A pairs to bootstrap research-agent LLMs on custom corpora | Doubles Llama-8B accuracy in 1 hr on single RTX 4090; fully local open-source pipeline | [📄](reports/autodidact.md) |

---

## ✍️ Idea Generation & Writing Assistants

> Systems focused on the **creative and communicative** ends of research: surfacing novel hypotheses, structuring arguments, and drafting manuscripts.

| Tier | Project | Stars | Core Approach | Notes | Report |
|:----:|---------|-------|---------------|-------|:------:|
| 🔬 | **[Idea2Paper](https://github.com/AgentAlphaAGI/Idea2Paper)**<br><sub>AgentAlphaAGI</sub> | ![](https://img.shields.io/github/stars/AgentAlphaAGI/Idea2Paper?style=social) | Multi-agent pipeline with Knowledge Graph novelty alignment | Semantic Scholar + arXiv grounding; raw idea → structured research proposal | — |
| 🔬 | **[SciAgents](https://github.com/lamm-mit/SciAgents)**<br><sub>MIT · 2024</sub> | ![](https://img.shields.io/github/stars/lamm-mit/SciAgents?style=social) | Multi-agent system with ontology graph for scientific reasoning | Generates multi-step reasoning chains grounded in domain ontologies | — |
| 🔬 | **[ResearchAgent](https://github.com/JeongminChoi6749/ResearchAgent)**<br><sub>Jeongmin Choi · 2024</sub> | ![](https://img.shields.io/github/stars/JeongminChoi6749/ResearchAgent?style=social) | Iterative idea refinement using academic concept databases | Interleaves idea generation with literature-grounded critique loops | — |
| 🔬 | **[ARIS](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep)**<br><sub>wanshuiyin</sub> | ![](https://img.shields.io/github/stars/wanshuiyin/Auto-claude-code-research-in-sleep?style=social) | Claude Code + MCP servers running overnight without supervision | Cross-model review loop; integrates Zotero, Obsidian, Kimi, DeepSeek | — |

---

## 📐 Benchmarks & Evaluation Suites

> Principled evaluation frameworks for measuring the capabilities of autonomous research systems.

| Benchmark | Maintained By | What It Measures | Link |
|-----------|--------------|------------------|------|
| **SWE-Bench** | Princeton NLP | Software engineering task resolution on real GitHub issues | [github.com/princeton-nlp/SWE-bench](https://github.com/princeton-nlp/SWE-bench) |
| **SWE-Bench Verified** | OpenAI | Human-verified subset of SWE-Bench (cleaner signal) | [openai.com/research](https://openai.com/research/swe-bench-verified) |
| **MLE-Bench** | OpenAI | ML engineering quality on Kaggle competition tasks | [github.com/openai/mle-bench](https://github.com/openai/mle-bench) |
| **CORE-Bench** | — | Computational reproducibility of published research | — |
| **AI-Scientist Eval** | SakanaAI | Paper quality via automated + human review | [AI-Scientist](https://github.com/SakanaAI/AI-Scientist) |
| **MLGym** | Meta AI Research | 13 open-ended AI research tasks (CV, NLP, RL, game theory) for benchmarking research agents | [github.com/facebookresearch/MLGym](https://github.com/facebookresearch/MLGym) · [arXiv:2502.14499](https://arxiv.org/abs/2502.14499) |
| **DeepResearch Bench** | Ayanami et al. | Comprehensive multi-domain benchmark for deep research agent quality | [github.com/Ayanami0730/deep_research_bench](https://github.com/Ayanami0730/deep_research_bench) |

> 💡 Contributions to this section are especially welcome — if you know of additional evaluation suites for research agents, please [open an issue](../../issues) or submit a PR.

---

## 🎓 Academic Surveys & Papers

| Year | Title | Venue | Authors | Link |
|------|-------|-------|---------|------|
| 2024 | The AI Scientist: Towards Fully Automated Open-Ended Scientific Discovery | arXiv | Lu et al. (SakanaAI) | [arXiv:2408.06292](https://arxiv.org/abs/2408.06292) |
| 2024 | From Copilot to Pilot: Towards AI-Driven Autonomous Scientific Research | arXiv | Guo et al. | [arXiv:2409.14526](https://arxiv.org/abs/2409.14526) |
| 2024 | Agent Laboratory: Using LLM Agents as Research Assistants | arXiv | Schmidgall et al. | [arXiv:2501.04227](https://arxiv.org/abs/2501.04227) |
| 2024 | STORM: Assisting in Writing Wikipedia-like Articles From Scratch | NAACL | Shao et al. (Stanford) | [arXiv:2402.14207](https://arxiv.org/abs/2402.14207) |
| 2024 | OpenScholar: Synthesizing Scientific Literature with Retrieval-Augmented LMs | Nature | Asai et al. | [Nature](https://www.nature.com/articles/s41586-024-08366-w) |
| 2024 | PaperQA2: Accurate Scientific QA through Iterative Literature Search | ICLR | Skarlinski et al. | [arXiv:2312.07559](https://arxiv.org/abs/2312.07559) |
| 2025 | Towards Automated Research: A Survey of AI Agents for Scientific Discovery | arXiv | Various | — |

---

## 🧾 In-Depth Analysis Reports

The `reports/` folder is the core value of this repository. Each file contains a structured 10-section analysis: architecture internals, component breakdowns, benchmark context, and honest assessment of strengths and limitations.

📁 **[Browse all reports →](reports/)**

| Tier | Report | System | Category | Key Topics Covered |
|:----:|--------|--------|----------|--------------------|
| 🏆 | [ai-scientist.md](reports/ai-scientist.md) | AI-Scientist | End-to-End | LaTeX pipeline, template-driven idea gen, agentic review loop |
| 🏆 | [ai-scientist-v2.md](reports/ai-scientist-v2.md) | AI-Scientist v2 | End-to-End | BFTS tree search, AIDE integration, peer review milestone |
| 🌟 | [ai-researcher.md](reports/ai-researcher.md) | AI-Researcher | End-to-End | LiteLLM multi-provider, Docker sandbox, NeurIPS 2025 |
| 🌟 | [agent-laboratory.md](reports/agent-laboratory.md) | Agent Laboratory | End-to-End | Role-specialized agents, arXiv + HuggingFace integration |
| 🔬 | [biomni.md](reports/biomni.md) | Biomni | End-to-End | Biomedical datalake, know-how library, multimodal inputs |
| 🔬 | [bioagents.md](reports/bioagents.md) | BioAgents | End-to-End | Specialized literature + analysis agents, BixBench SOTA (48.78%) |
| 🏆 | [storm.md](reports/storm.md) | STORM | Literature | DSPy pipeline, multi-perspective QA, Co-STORM |
| 🏆 | [gpt-researcher.md](reports/gpt-researcher.md) | GPT Researcher | Literature | Parallel scraping, LangGraph orchestration, MCP |
| 🏆 | [deerflow.md](reports/deerflow.md) | DeerFlow | Literature | ByteDance InfoQuest, sub-agent memory, code execution |
| 🌟 | [paperqa2.md](reports/paperqa2.md) | PaperQA2 | Literature | Iterative retrieval, tantivy indexing, ICLR results |
| 🌟 | [openscholar.md](reports/openscholar.md) | OpenScholar | Literature | 45M paper index, Contriever dense retrieval, Nature paper |
| 🌟 | [open-deep-research.md](reports/open-deep-research.md) | Open Deep Research | Literature | LangChain MCP integration, LangSmith tracing |
| 🏆 | [openhands.md](reports/openhands.md) | OpenHands | Code Agent | 72% SWE-Bench Verified, composable agent architecture |
| 🌟 | [swe-agent.md](reports/swe-agent.md) | SWE-agent | Code Agent | Agent-Computer Interface (ACI), Princeton NLP design |
| 🔬 | [autogpt.md](reports/autogpt.md) | AutoGPT | Code Agent | Historical context, Forge platform, Agent Protocol |
| 🏆 | [autoresearch.md](reports/autoresearch.md) | autoresearch | End-to-End | 630-line self-referential experiment loop, Karpathy design philosophy |
| 🏆 | [deep-research.md](reports/deep-research.md) | deep-research | Literature | Recursive depth/breadth scaffold, Firecrawl+Exa, TypeScript reference |
| 🌟 | [cognitivekernel-pro.md](reports/cognitivekernel-pro.md) | CognitiveKernel-Pro | Literature | SFT-trained Qwen3-8B, Playwright web engine, Tencent AI Lab |
| 🏆 | [datagen.md](reports/datagen.md) | DATAGEN | End-to-End | Multi-agent hypothesis gen, data analysis pipeline, state tracking |
| 🔬 | [medresearcher-r1.md](reports/medresearcher-r1.md) | MedResearcher-R1 | End-to-End | Medical KG-grounded trajectory synthesis, 32B model, MedBrowseComp SOTA |
| 🏆 | [mirothinker.md](reports/mirothinker.md) | MiroThinker | Literature | RL-trained 30B/235B open models, 88.2 BrowseComp, interactive scaling |
| 🌟 | [deeper-seeker.md](reports/deeper-seeker.md) | Deeper-Seeker | Literature | Iterative research, follow-up questions, multi-step synthesis |
| 🔬 | [autodidact.md](reports/autodidact.md) | AutoDidact | Code Agent | GRPO self-bootstrapping, Llama-8B, single-GPU research agent training |
| 🔬 | [ii-researcher.md](reports/ii-researcher.md) | II-Researcher | Literature | BAML structured LLM functions, 84.12% Frames, async multi-provider search |

---

## 🧭 How to Choose the Right Tool

Answer the questions below in order — each branch ends at a concrete recommendation.

```
── START HERE ────────────────────────────────────────────────────────────────

 Q1: What is your end goal?
 │
 ├─ (A) Produce a full research paper / manuscript
 │       └─ go to Q2
 │
 ├─ (B) Survey a topic, synthesize literature, or generate a research report
 │       └─ go to Q5
 │
 ├─ (C) Run, debug, or automate code / ML experiments
 │       └─ go to Q8
 │
 └─ (D) Generate or refine novel research ideas
         └─ go to Q11

───────────────────────────────────────────────────────────────────────────────
 A: FULL PAPER / MANUSCRIPT
───────────────────────────────────────────────────────────────────────────────

 Q2: What research domain are you in?
 │
 ├─ General ML / Computer Science
 │       └─ go to Q3
 │
 ├─ Biomedical / Life Sciences
 │       └─ ✅  Biomni  (Stanford SNAP; biomedical datalake + know-how library)
 │
 └─ Other / interdisciplinary
         └─ go to Q3  (general systems are still useful starting points)

 Q3: How much control / human involvement do you want?
 │
 ├─ Fully autonomous — I want to set it running overnight
 │       └─ go to Q4
 │
 └─ Semi-autonomous — I want to steer hypothesis and review results
         └─ ✅  Agent Laboratory  (role-based: Professor → PhD Student → Reviewer;
                                    human can intervene at each stage)

 Q4: Do you prioritize pipeline maturity or LLM flexibility?
 │
 ├─ Mature pipeline, proven end-to-end results
 │       └─ ✅  AI-Scientist v1 / v2  (SakanaAI; produced first peer-reviewed AI paper)
 │
 └─ Broadest LLM provider support + reproducible Docker environment
         └─ ✅  AI-Researcher  (HKUDS; LiteLLM + Docker; NeurIPS 2025 Spotlight)

───────────────────────────────────────────────────────────────────────────────
 B: LITERATURE SURVEY / RESEARCH REPORT
───────────────────────────────────────────────────────────────────────────────

 Q5: Where does your source material come from?
 │
 ├─ The open web (news, blogs, general knowledge)
 │       └─ go to Q6
 │
 ├─ My own PDF collection (papers I've already downloaded)
 │       └─ ✅  PaperQA2  (iterative full-text RAG; highest accuracy on local PDFs)
 │
 └─ Academic papers at large scale (no local download needed)
         └─ ✅  OpenScholar  (45M open-access papers; Contriever dense retrieval;
                                Nature 2024; outperforms Perplexity Pro on sci Q&A)

 Q6: What output format do you need?
 │
 ├─ A structured, Wikipedia-style article with cited sections
 │       └─ ✅  STORM  (Stanford OVAL; DSPy pipeline; Co-STORM for collaboration;
                          NAACL 2024)
 │
 ├─ A concise 5–6 page factual report (PDF / Word / Markdown)
 │       └─ ✅  GPT Researcher  (parallel web agents + LangGraph; MCP support;
                                   fastest route to a cited report)
 │
 └─ A report that also includes runnable code or data analysis
         └─ go to Q7

 Q7: Do you need a production-grade, configurable pipeline?
 │
 ├─ Yes — I'm building this into a product or workflow
 │       └─ ✅  Open Deep Research  (LangChain; MCP tool plugins; LangSmith
                                       tracing; designed as a reference implementation)
 │
 └─ No — I need something working quickly out of the box
         └─ ✅  DeerFlow  (ByteDance; LangGraph + memory + code execution;
                             research + code in one pipeline)

───────────────────────────────────────────────────────────────────────────────
 C: CODE / EXPERIMENT AUTOMATION
───────────────────────────────────────────────────────────────────────────────

 Q8: What is your primary metric for choosing?
 │
 ├─ Raw benchmark performance on software engineering tasks
 │       └─ ✅  OpenHands  (72% on SWE-Bench Verified; best-in-class;
                               composable Python library + Web UI)
 │
 ├─ Structured, auditable, research-friendly interface
 │       └─ ✅  SWE-agent  (Princeton NLP; Agent-Computer Interface (ACI);
                               widely used as research baseline)
 │
 ├─ Daily pair-programming with Git integration (low overhead)
 │       └─ ✅  Aider  (terminal-native; Git-native commits; supports 60+ models)
 │
 └─ ML-experiment-specific iteration (Kaggle / benchmark tasks)
         └─ go to Q9

 Q9: Is your task similar to Kaggle-style ML competitions?
 │
 ├─ Yes
 │       └─ ✅  AIDE  (WecoAI; tree-search over solution space;
                          used internally by AI-Scientist-v2)
 │
 └─ No — I just want a pioneer framework to understand the space
         └─ ✅  AutoGPT  (historically seminal; Forge builder; broad plugin ecosystem)

───────────────────────────────────────────────────────────────────────────────
 D: NOVEL IDEA GENERATION
───────────────────────────────────────────────────────────────────────────────

 Q10: What kind of grounding do you need for the ideas?
 │
 ├─ Literature-grounded novelty checking (Semantic Scholar + arXiv KG)
 │       └─ ✅  Idea2Paper  (KG alignment; raw idea → structured proposal)
 │
 ├─ Domain ontology-based scientific reasoning
 │       └─ ✅  SciAgents  (MIT; multi-agent + ontology graphs)
 │
 ├─ Iterative critique loops against academic concept databases
 │       └─ ✅  ResearchAgent  (light-weight; good for early-stage idea exploration)
 │
 └─ Fully autonomous overnight ideation with cross-model review
         └─ ✅  ARIS  (Claude Code + MCP; runs unattended; Zotero + Obsidian)

── STILL UNSURE? ─────────────────────────────────────────────────────────────
 → Check the Capability Matrix above to compare any two systems side-by-side
 → Read the in-depth reports in reports/ for architecture and limitation details
──────────────────────────────────────────────────────────────────────────────
```

---

## 🤝 Contributing

- **Add a project** — [open an issue](../../issues/new?template=add-project.md) or submit a PR to the appropriate section table
- **Write an analysis report** — see the [report template](reports/README.md), create `reports/<slug>.md`, update the Reports table above
- **Fix outdated info** — broken links, stale star counts, new benchmark scores
- **Suggest new sections** — open a Discussion

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting.

---

## 📈 Star History

Star growth of the leading research-specific tools since their respective launch dates.  
*AutoGPT (170k+ ⭐) is excluded from the chart to keep the research tools readable — [view full comparison including AutoGPT →](https://star-history.com/#Significant-Gravitas/AutoGPT&All-Hands-AI/OpenHands&Aider-AI/aider&assafelovic/gpt-researcher&stanford-oval/storm&SWE-agent/SWE-agent&SakanaAI/AI-Scientist&bytedance/deer-flow&Future-House/paper-qa&karpathy/autoresearch&Date)*

[![Star History Chart](https://api.star-history.com/svg?repos=All-Hands-AI/OpenHands,Aider-AI/aider,assafelovic/gpt-researcher,stanford-oval/storm,SWE-agent/SWE-agent,SakanaAI/AI-Scientist,bytedance/deer-flow,Future-House/paper-qa&type=Date)](https://star-history.com/#All-Hands-AI/OpenHands&Aider-AI/aider&assafelovic/gpt-researcher&stanford-oval/storm&SWE-agent/SWE-agent&SakanaAI/AI-Scientist&bytedance/deer-flow&Future-House/paper-qa&Date)

---

<div align="center">

Maintained by **[Peizheng Li](https://github.com/EdwardLeeLPZ)** · Licensed under [MIT](LICENSE)

*If this repository helped your research, please consider giving it a ⭐*

</div>
