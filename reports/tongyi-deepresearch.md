# Tongyi DeepResearch

> An RL-trained open-weight agentic LLM (30.5B parameters, GRPO) from Alibaba NLP that achieves state-of-the-art performance on long-horizon information-seeking benchmarks.

## Overview

Tongyi DeepResearch is an open-weight research agent developed by Alibaba NLP and released in 2025.
With over 18,600 GitHub stars it is one of the most popular research-automation LLMs in the open-source ecosystem.
The system combines a 30.5B parameter base model trained with Group Relative Policy Optimisation (GRPO) reinforcement learning with an agentic inference framework that enables multi-step web search, reasoning, and report synthesis.

The project represents Alibaba's contribution to the growing class of RL-trained open-weight research agents.
Tongyi DeepResearch is positioned alongside systems like MiroThinker (30B/235B RL-trained), but with a focus on information-seeking benchmarks rather than interactive scaling.
The model weights are released publicly, making it suitable for self-hosted, privacy-sensitive research deployments.

The key innovation is applying GRPO reinforcement learning directly to an agentic web-research task.
Rather than training a language model and wrapping it with agentic scaffolding post-hoc, the model is trained end-to-end to issue search queries, evaluate retrieved evidence, and synthesise multi-step answers.
This makes the model's reasoning and tool-use strategies tightly coupled to the task distribution.

## Architecture

Tongyi DeepResearch consists of two primary components: the trained model and the inference-time agentic framework.

```
┌────────────────────────────────────────────────────────┐
│              Tongyi DeepResearch System                 │
│                                                         │
│  ┌─────────────────────────────────────┐               │
│  │     30.5B GRPO-trained model        │               │
│  │   (Qwen base, RL-specialised)       │               │
│  └─────────────────┬───────────────────┘               │
│                    │                                    │
│  ┌─────────────────▼───────────────────┐               │
│  │     Agentic Inference Framework     │               │
│  │   - Query planning & decomposition  │               │
│  │   - Tool call generation            │               │
│  │   - Search result evaluation        │               │
│  │   - Multi-step reasoning chains     │               │
│  │   - Report generation               │               │
│  └─────────────────┬───────────────────┘               │
│                    │                                    │
│  ┌─────────────────▼───────────────────┐               │
│  │         Tool Interface              │               │
│  │   - Web search APIs                 │               │
│  │   - Document retrieval              │               │
│  │   - Calculator / code exec          │               │
│  └─────────────────────────────────────┘               │
└────────────────────────────────────────────────────────┘
```

The model is based on the Qwen architecture and trained with GRPO, a variant of PPO that uses group-level reward normalisation to improve training stability for long-context reasoning tasks.
The agentic framework wraps the model with tool-call parsing, search API clients, and a multi-step reasoning loop that iterates until the model produces a final answer token.

## Core Workflow

1. **Query intake** — user provides a research question or topic.
2. **Query decomposition** — model generates sub-questions that decompose the original query.
3. **Search plan** — model determines which search queries to issue and in what order.
4. **Web retrieval** — search APIs return results; model evaluates relevance and selects evidence.
5. **Iterative deepening** — model identifies gaps in current evidence and issues follow-up queries.
6. **Reasoning synthesis** — model chains together evidence across multiple retrieved documents.
7. **Report generation** — model writes a structured, cited report summarising its findings.
8. **Answer extraction** — a final concise answer is extracted for QA-style benchmarks.

## Key Features

- **Open-weight model** — 30.5B parameters available for self-hosting, enabling privacy-preserving research in regulated environments.
- **GRPO training** — Group Relative Policy Optimisation provides stable RL training for long-horizon tasks where rewards are sparse.
- **End-to-end RL training** — model is optimised directly on the research agent task, not just on language modelling.
- **Multi-step search** — generates multiple rounds of search queries with evidence integration between rounds.
- **Benchmark-optimised** — specifically evaluated on long-horizon information-seeking benchmarks (FRAMES, BrowseComp, etc.).
- **Open training recipe** — Alibaba releases training methodology, enabling the research community to build on the approach.

## Technical Implementation

### GRPO Reinforcement Learning

Group Relative Policy Optimisation is the training signal for Tongyi DeepResearch.
GRPO improves on standard PPO by normalising rewards at the group level rather than globally, reducing variance in reward estimates for diverse tasks.
For research agent training, rewards are derived from answer correctness on held-out information-seeking benchmarks.
The training procedure alternates between rollout generation (the model performs multi-step research) and policy updates (GRPO gradient steps).

### Query Decomposition

The model was trained to decompose complex questions into atomic sub-questions before retrieving evidence.
This decomposition strategy improves answer accuracy on multi-hop questions where a single search cannot retrieve all necessary information.
The decomposition is implicit in the model's chain-of-thought, not a hard-coded module.

### Evidence Evaluation

After each search round, the model evaluates the relevance and trustworthiness of retrieved content.
Low-relevance results are discarded; high-relevance snippets are retained in the context window for synthesis.
This evidence filtering reduces noise and keeps the context focused as the research depth increases.

### Multi-Step Reasoning

The model generates explicit reasoning chains before synthesising retrieved evidence into a final answer.
These chains are formatted as step-by-step logic traces, making the reasoning process auditable.
For longer research tasks, the chains can span dozens of steps across multiple search rounds.

## Evaluation & Benchmarks

Tongyi DeepResearch achieves state-of-the-art results on long-horizon information-seeking benchmarks.

### FRAMES Benchmark
- FRAMES tests multi-hop reasoning over Wikipedia-style documents.
- Tongyi DeepResearch achieves top-tier performance in the open-weight model category.
- Multi-step decomposition is particularly effective on FRAMES queries requiring 3+ hops.

### BrowseComp
- BrowseComp measures the ability to synthesise information from multiple web pages.
- Tongyi DeepResearch scores competitively among open-weight models on this benchmark.
- Performance approaches closed-source models like GPT-4o on standard subtasks.

### Long-Horizon Information-Seeking
- Custom benchmarks designed by Alibaba NLP for multi-round research synthesis.
- SOTA reported among open-weight models at time of release.
- Directly comparable to MiroThinker (which uses larger 30B/235B variants with different training).

## Strengths

- **Open-weight + open training recipe** — enables the research community to reproduce, adapt, and extend the system.
- **RL-trained end-to-end** — tight coupling between model training and agentic task distribution improves generalisation.
- **SOTA on long-horizon tasks** — outperforms earlier open-weight models on information-seeking benchmarks.
- **Self-hostable** — 30.5B parameters can run on consumer-grade multi-GPU setups (e.g., 2×A100).
- **Alibaba ecosystem integration** — connects naturally with Alibaba Cloud services and Qwen model family.

## Limitations

- **Scale vs. closed models** — 30.5B parameters lags behind GPT-4o and Claude Sonnet at complex reasoning despite RL training.
- **English-centric benchmarks** — primary evaluation on English-language benchmarks; multilingual performance less characterised.
- **Web search dependency** — the agent requires live web access; offline research corpus scenarios are not natively supported.
- **Context length constraints** — 30.5B models have more limited context windows than frontier closed models for very long documents.
- **Tooling ecosystem** — less extensive plugin and MCP ecosystem than Python-native systems like GPT Researcher or DeerFlow.

## Related Work

- **MiroThinker** — RL-trained 30B/235B open models; different architecture but similar training philosophy; achieves 88.2 on BrowseComp.
- **GPT Researcher** — prompt-based multi-agent web research; no RL training; higher accessibility.
- **DeerFlow** — ByteDance pipeline combining literature and code research; complementary rather than competing.
- **Open Deep Research** — LangChain reference implementation; modular but not end-to-end trained.
- **CognitiveKernel-Pro** — SFT-trained (not RL) Qwen3-8B from Tencent; different training approach.

## References

1. Alibaba NLP. (2025). *Tongyi DeepResearch*. https://github.com/Alibaba-NLP/DeepResearch
2. DeepSeek-AI et al. (2024). *DeepSeek-R1: Incentivizing Reasoning Capability in LLMs via RL*. arXiv:2501.12948.
3. Shao, Z. et al. (2024). *DeepSeekMath: Pushing the Limits of Mathematical Reasoning in Open Language Models*. arXiv:2402.03300.
4. Asai, A. et al. (2024). *OpenScholar: Synthesizing Scientific Literature with Retrieval-Augmented LMs*. Nature.
5. Yao, S. et al. (2022). *ReAct: Synergizing Reasoning and Acting in Language Models*. ICLR 2023.
6. Qwen Team. (2024). *Qwen2.5 Technical Report*. arXiv:2412.15115.

---

### Practitioner Notes

**Model access:** The 30.5B weights are available on HuggingFace under the Alibaba-NLP organisation.
A 4-bit quantised version (approximately 18GB VRAM) can run on a single A100 GPU.
Inference requires the Qwen2.5 tokeniser and model configuration.

**Deployment options:**
- vLLM inference server for high-throughput API serving.
- Text Generation Inference (TGI) for HuggingFace native deployment.
- Ollama for local desktop use (quantised version).

**Benchmarking context:**
Comparing Tongyi DeepResearch against proprietary systems requires careful normalisation.
The model was trained with GRPO specifically for information-seeking tasks, so it should be evaluated on those benchmarks (FRAMES, BrowseComp, long-horizon QA) rather than general instruction-following benchmarks where it may underperform.

**Best use cases:**
- Multi-hop factual question answering requiring 3+ search rounds.
- Research synthesis tasks where web access is available.
- Organisations needing a fully self-hosted research agent without API dependency on OpenAI or Anthropic.
- Low-cost deployment: the 30.5B model costs significantly less per token than GPT-4o or Claude claude-sonnet-4.

**Limitations in practice:**
The model requires a live web search API (Bing, Google, or Serper); offline research corpora are not natively supported.
For very long documents (>32K tokens), the context window may be a bottleneck.
Multilingual performance is less characterised than English performance; testing is recommended before deploying in non-English contexts.

**Integration with other tools:**
Tongyi DeepResearch can serve as a drop-in replacement for the LLM backbone in systems like GPT Researcher or DeerFlow.
Since it is Qwen-based, it integrates well with the Qwen ecosystem of tools and adapters.

**GRPO training details:**
GRPO (Group Relative Policy Optimisation) computes reward advantages relative to the mean reward within a group of rollouts for the same input.
This normalisation reduces variance and improves training stability compared to standard PPO for tasks with diverse reward distributions.
The training data consists of complex multi-hop questions with verified answers, where rewards are binary (correct/incorrect) with optional partial credit for correct reasoning steps.

**Research contributions and academic impact:**
Tongyi DeepResearch contributes to the growing literature on RL-trained agents for information-seeking tasks.
The GRPO training approach provides a reproducible recipe for the research community.
The model's release alongside training methodology enables independent replication and extension.
Academic groups working on RL for LLMs can use the Tongyi DeepResearch training pipeline as a baseline for information-seeking agent research.
Comparison with MiroThinker (RL-trained, 30B/235B) and CognitiveKernel-Pro (SFT-trained, 8B) helps characterise the role of model scale, training method, and specialisation in web research agent performance.
These comparisons suggest that RL training at 30B+ scale is currently the most effective approach for top-tier long-horizon information-seeking performance among open-weight models.
Future work might explore whether smaller models (7B–13B) trained with GRPO can approach the performance of 30B+ RL models, which would significantly reduce deployment costs.
