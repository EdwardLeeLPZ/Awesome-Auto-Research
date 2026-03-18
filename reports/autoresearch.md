# autoresearch

> A minimal, self-contained autonomous ML research agent that runs a hypothesis-experiment-evaluate loop overnight, modifying a GPT training script, running 5-minute experiments, and iterating hundreds of times while you sleep.

---

## 📌 Project Overview

**autoresearch** is an open-source autonomous ML research framework developed by Andrej Karpathy (former Tesla AI Director, OpenAI co-founder, currently independent researcher) and released in early 2026. The project's core premise is deceptively simple: give an LLM agent a real, runnable language model training script, let it autonomously modify the script, run experiments on a fixed time budget, observe the results, and iterate — indefinitely and without human supervision.

The repository is deliberately minimal. Only three files constitute the entire research environment:

- **`prepare.py`** — Fixed, read-only utilities: BPE tokenizer training, dataset downloading, data loading, and validation evaluation. The agent never touches this file.
- **`train.py`** — The single editable file. It contains the full GPT model (architecture, attention, optimizer, training loop, hyperparameters). This is the only file the agent modifies.
- **`program.md`** — A Markdown instruction document that programs the agent's research strategy. Humans edit this to guide research direction; the agent reads it as context at the start of each session.

The system is not a framework, not a library, and contains no orchestration infrastructure. It is closer in spirit to an instruction manual handed to an LLM coding agent (Claude, Codex, or any other capable model) that instructs the agent to run an infinite experiment loop. Each experiment takes exactly 5 minutes of wall-clock training time, yielding roughly 12 experiments per hour and approximately 100 experiments during an 8-hour sleep cycle.

The performance metric is **`val_bpb`** (validation bits per byte) — lower is better, and deliberately vocab-size-independent, so that architectural changes (including changes to vocabulary size) are fairly comparable across experiments.

**Repository:** [https://github.com/karpathy/autoresearch](https://github.com/karpathy/autoresearch)  
**Author:** Andrej Karpathy  
**Language:** Python 3.10+  
**License:** MIT  
**Hardware:** Single NVIDIA GPU (tested on H100)  

---

## 🎯 Project Positioning

autoresearch is positioned as the **radical minimum** of autonomous research tooling: prove that meaningful ML research automation requires almost nothing beyond an LLM, a training script, and an instruction file. Its philosophy is in sharp contrast to elaborate multi-agent systems with tool-use frameworks, literature review pipelines, and paper-writing modules.

### Target Audience

- **ML researchers** who want to run automated ablation studies, hyperparameter sweeps, and architecture experiments overnight on a single GPU
- **Research engineers** exploring automated optimization of training infrastructure (optimizer design, learning rate schedules, batching strategies)
- **AI systems researchers** studying the limits of LLM-driven autonomous code modification
- **Hobbyists and students** with access to a single GPU who want to explore what a self-directed research agent looks like at minimal complexity

### Project Positioning in the Landscape

autoresearch occupies a specific and narrow niche. It does **not** write papers, does **not** perform literature review, does **not** search the web, and does **not** generalize across research domains. What it does, it does in the most direct possible way: the agent is given a training script, told the goal (minimize `val_bpb`), and left to iterate.

Karpathy's satirical framing in the repository README captures the spirit well: the repo's header describes a fictional 2026 where autonomous agent swarms have taken over research entirely, suggesting that autoresearch is the deliberate "Year Zero" of that trajectory — the simplest possible demonstration that it is technically feasible.

| Dimension | autoresearch | AI-Scientist | Agent Laboratory |
|---|---|---|---|
| Paper writing | ❌ | ✅ | ✅ |
| Literature review | ❌ | ✅ | ✅ |
| Experiment automation | ✅ (core) | ✅ | ✅ |
| Domain | Fixed (GPT training) | Narrow ML | Broader ML |
| Complexity | ~3 files | Large framework | Large framework |
| Time budget per run | Fixed 5 min | Variable | Variable |
| Target metric | val\_bpb | NeurIPS-style paper score | Task performance |

---

## 🏗️ System Architecture

The architecture of autoresearch is intentionally anti-architecture — there is no orchestration layer, no agent runtime, no tool-calling scaffold. The system's structure emerges from the interaction between three components:

```
┌────────────────────────────────────────────────────────────┐
│                        Human Layer                         │
│   edits program.md  ◄──────────────────────────────────    │
└──────────────────────────────┬─────────────────────────────┘
                               │ reads
┌──────────────────────────────▼─────────────────────────────┐
│                       LLM Agent Layer                       │
│  (Claude / Codex / any capable model in agentic mode)      │
│                                                             │
│  reads program.md → reads train.py → proposes hypothesis   │
│  → edits train.py → runs experiment → reads results        │
│  → logs to results.tsv → advances or reverts git state     │
│  → loops forever                                           │
└──────────────────────────────┬─────────────────────────────┘
                               │ edits / runs
┌──────────────────────────────▼─────────────────────────────┐
│                   Experiment Layer (train.py)               │
│                                                             │
│   GPT model definition (GQA, RoPE, SSSL attention, VE)    │
│   MuonAdamW optimizer (Muon + AdamW, torch.compile)        │
│   Training loop (fixed 5-minute wall-clock budget)         │
│   Final eval → prints val_bpb summary                      │
└──────────────────────────────┬─────────────────────────────┘
                               │ fixed utilities
┌──────────────────────────────▼─────────────────────────────┐
│                      Support Layer (prepare.py)             │
│                                                             │
│  Dataset: karpathy/climbmix-400b-shuffle (HuggingFace)    │
│  Tokenizer: rustbpe BPE, vocab_size=8192                   │
│  Dataloader, evaluate_bpb(), constants (TIME_BUDGET=300s)  │
└────────────────────────────────────────────────────────────┘
```

The key architectural insight is that the "agent" is not code in the repository — it is an externally-run LLM coding assistant (e.g., Claude running in a terminal with file access enabled). The repository merely provides the environment the agent operates in: a clean git branch, a runnable training script, and `program.md` as the instruction set.

Git is used as the experiment ledger. The agent creates a branch (`autoresearch/<tag>`), commits each proposed modification, runs it, and either keeps the commit (if `val_bpb` improved) or resets to the previous HEAD (if not). This produces a clean, auditable git history of only the improvements.

---

## ⚙️ Core Components & Workflow

### The Experiment Loop

The agent's workflow, as specified in `program.md`, is a strict infinite loop with no stop conditions except manual interruption:

1. **Read context** — The agent reads `README.md`, `prepare.py`, and `train.py` in full at session start to understand the codebase.
2. **Establish baseline** — The very first run always executes the unmodified `train.py` to record the baseline `val_bpb`.
3. **Propose hypothesis** — The LLM proposes a specific, targeted change (e.g., "switch activation from `relu²` to `SiLU`", "increase DEPTH from 8 to 10", "tune WARMDOWN_RATIO").
4. **Edit `train.py`** — The agent directly modifies the hyperparameter section or model code, using `git commit` to record the change.
5. **Run experiment** — `uv run train.py > run.log 2>&1` — output is redirected to avoid flooding the agent's context window.
6. **Read results** — `grep "^val_bpb:\|^peak_vram_mb:" run.log` extracts the key metrics.
7. **Handle crashes** — If the grep is empty, the run crashed. The agent inspects `tail -n 50 run.log` and decides whether to fix or discard.
8. **Log to TSV** — Results are appended to `results.tsv` (5 columns: `commit`, `val_bpb`, `memory_gb`, `status`, `description`). This file is deliberately not tracked by git.
9. **Advance or revert** — If `val_bpb` improved: keep the commit and advance. If not: `git reset --hard HEAD~1` to discard.
10. **Repeat forever** — No pausing, no asking the user for permission, no stopping for "is this a good time?". The loop runs until the human manually interrupts.

The fixed 5-minute time budget is a crucial design decision. It ensures all experiments are directly comparable regardless of what the agent changes: if the agent increases model depth, it doesn't run for longer — it simply completes fewer gradient steps in the same wall-clock time. This is both a fairness mechanism and a practical one: the researcher wakes up knowing exactly how many experiments completed.

### `program.md`: The Human's Research Interface

The most underappreciated component is `program.md`. This file is not executed by any software — it is text that the LLM agent reads as context. The human edits it to guide research strategy (e.g., "focus on optimizer changes", "prioritize architectural simplifications", "we've found that DEPTH=10 works well, explore further"). Over time, `program.md` becomes the accumulated "research org knowledge" — a kind of evolving strategy document. Karpathy notes that iterating on `program.md` itself is a meta-research activity: "it's obvious how one would iterate on it over time to find the 'research org code' that achieves the fastest research progress."

### The Simplicity Criterion

`program.md` includes an explicit and nuanced **simplicity criterion** that the agent must apply when deciding whether to keep a change:

> *A small improvement that adds ugly complexity is not worth it. Conversely, removing something and getting equal or better results is a great outcome — that's a simplification win.*

This prevents the agent from accumulating technical debt through micro-improvements. A change must justify its complexity overhead. A deletion that maintains performance is explicitly preferred over an addition that marginally improves it. This judgment criterion is arguably one of the most sophisticated aspects of the system's design, encoding a principle that many human researchers fail to apply consistently.

---

## 🔧 Technical Details

### Model Architecture (`train.py`)

The base model in `train.py` is a modern, research-grade GPT implementation derived from Karpathy's `nanochat` project. It is not a minimal toy — it incorporates several state-of-the-art components:

**Configuration defaults** (all modifiable by the agent):
```python
DEPTH = 8                   # number of transformer layers
ASPECT_RATIO = 64           # model_dim = depth * ASPECT_RATIO → 512 at depth=8
HEAD_DIM = 128              # attention head dimension
WINDOW_PATTERN = "SSSL"     # alternating short/long attention windows
TOTAL_BATCH_SIZE = 2**19    # ~524K tokens per optimizer step
DEVICE_BATCH_SIZE = 128     # microbatch size (reduce for OOM)
```

**Attention mechanism:**
- **Grouped Query Attention (GQA)** — `n_head` query heads, `n_kv_head` key/value heads
- **Rotary Position Embeddings (RoPE)** — pre-computed `cos`/`sin` buffers with 10× sequence length for extended context
- **Flash Attention 3** — Hardware-specific kernel dispatch: `varunneal/flash-attn3` for Hopper GPUs (H100), `kernels-community/flash-attn3` otherwise
- **Sliding Window Attention** — Pattern `"SSSL"` cycles per layer: `S`=half-context window, `L`=full-context window. Last layer always forced to full context. Window size computation ensures the final layer captures global dependencies.
- **QK-Norm** — RMSNorm applied to queries and keys before attention (stabilizes training at scale)

**Value Embeddings (ResFormer-style):**
Every other layer (alternating, last layer always included) has a dedicated `value_embeds` embedding matrix. These are mixed into the value stream with a learnable per-head gate: `v = v + sigmoid(gate(x[:, :32])) * 2 * ve`. The gate uses only the first 32 channels of the residual stream as input. This implements a form of input-dependent value residual connection drawn from the ResFormer literature.

**Residual stream control:**
Each layer applies learned per-layer scalars: `x = resid_lambdas[i] * x + x0_lambdas[i] * x0`, where `x0` is the normalized embedding at layer 0. This allows the model to learn how much to rely on the original token embedding versus the accumulated residual at each layer.

**Logit soft-capping:** `logits = 15 * tanh(logits / 15)` — bounds logits to `[-15, 15]` for training stability, a technique from Gemma 2.

**MLP:** Standard `4×` expansion with `relu²` (squared ReLU) activation — a smooth, sparsity-promoting activation with favorable gradient properties.

**Weight initialization:**
- Token embeddings: `N(0, 1)` (large, for stable normalized training)
- LM head: `N(0, 0.001)` (small, to start near uniform logits)
- Q/K/V/FC weights: Uniform `±√3 / √d_model` (symmetric around zero)
- All projection outputs (c_proj, c_proj for MLP): zero-initialized (pre-residual zeroing)
- Value embed gate: zero-initialized (neutral at start: sigmoid(0)×2 = 1.0)

### Optimizer: MuonAdamW

The optimizer is a hand-rolled `MuonAdamW` class that applies two different update rules to different parameter groups:

**Muon** (for all 2D matrix parameters — attention and MLP weights):
- Nesterov momentum update followed by **Polar Express orthogonalization** — a Newton-Schulz-style matrix polynomial that approximates the orthogonal polar factor of the gradient matrix
- The coefficients (`polar_express_coeffs`) are numerically optimized to converge in 5 Newton-Schulz steps
- **NorMuon variance reduction**: a second momentum buffer tracks per-row (or per-column) gradient variance, normalizing the Muon update for more uniform learning rates across parameters
- **Cautious weight decay**: weight decay is applied only along dimensions where the update and parameter have the same sign (`mask = (g * p) >= 0`) — preventing decay from counteracting the learning direction
- Learning rate scaled as `lr × max(1, rows/cols)^0.5` for non-square matrices

**AdamW** (for embeddings, LM head, value embeddings, scalars):
- Standard fused AdamW with bias correction
- Separate learning rates per group: `EMBEDDING_LR=0.6`, `UNEMBEDDING_LR=0.004`, `MATRIX_LR=0.04`, `SCALAR_LR=0.5`
- All LRs scaled by `(d_model / 768)^{-0.5}` for µP-style dimension-aware scaling

Both step kernels are `torch.compile`d with `dynamic=False, fullgraph=True` for maximum throughput.

**Learning rate schedule:** Flat-then-cosine-warmdown. Progress is measured as wall-clock training time divided by `TIME_BUDGET`. A configurable warmdown phase (default 50% of budget) linearly decays LR from 1.0× to `FINAL_LR_FRAC` (default 0.0). Weight decay also decays with training progress: `wd × (1 - progress)`.

### Dataset and Tokenizer

**Dataset:** `karpathy/climbmix-400b-shuffle` on HuggingFace — a large, diverse pre-training corpus in Parquet format (~6,542 shards). Training and validation splits are determined by shard index; the validation shard (`shard_06542`) is pinned.

**Tokenizer:** Custom BPE trained using `rustbpe` (a Rust-backed BPE library) with GPT-4-style split patterns. Vocabulary size: 8,192 tokens. Serialized as a `tiktoken` encoding for fast inference. A companion `token_bytes.pt` tensor stores the UTF-8 byte count of each token, enabling the bits-per-byte metric.

**Validation metric — `val_bpb`:** Computes cross-entropy loss over `EVAL_TOKENS = 40 × 524288 ≈ 20.9M` validation tokens, then converts to bits per byte: `bpb = loss_nats / log(2) × avg_bytes_per_token`. Because this normalizes by raw byte count rather than token count, it is invariant to tokenizer vocabulary size, making it a fair metric even if the agent changes `vocab_size`.

### Training Loop Details

The training loop is a standard gradient accumulation loop with a wall-clock termination condition. Key implementation details:

- **GC management:** Python's garbage collector is frozen after step 0 (`gc.freeze(); gc.disable()`) to eliminate ~500 ms stalls from GC pauses during training. Manual `gc.collect()` is called every 5,000 steps.
- **Fast-fail on divergence:** If training loss exceeds 100.0 or becomes NaN, the script immediately prints `FAIL` and exits with code 1. The agent's crash detection handles this as a failed experiment.
- **Warmup exclusion:** The first 10 steps are excluded from the `total_training_time` counter. This prevents startup overhead (JIT compilation via `torch.compile`, CUDA kernel initialization) from contaminating the time budget.
- **Muon momentum warmup:** Muon momentum is ramped from 0.85 to 0.95 over the first 300 steps (`get_muon_momentum`), following the standard practice of using lower momentum early in training for stability.
- **EMA loss logging:** Training loss is logged as an exponential moving average (`β=0.9`) with bias correction, providing a smooth, readable progress signal during the run.

### Compute Profile (H100, default config, DEPTH=8)

Based on reported baseline values from the repository:
- **Model size:** ~50M parameters
- **val_bpb baseline:** ~0.998 (from example output in `program.md`)
- **Peak VRAM:** ~45 GB (on H100 with DEPTH=8)
- **MFU:** ~39–40% of H100 BF16 peak
- **Tokens processed:** ~500M tokens per 5-minute run
- **Gradient steps:** ~950 steps

---

## 📊 Performance & Benchmarks

Karpathy did not publish formal benchmark comparisons for autoresearch. The project's value is demonstrated through the structure of the experiment loop rather than through published ablation tables. Several observations can be made from the system design:

**Throughput:**
- ~12 experiments/hour on H100 hardware
- ~100 experiments per overnight session (8 hours)
- Each experiment processes ~500M training tokens in a fixed 5-minute window

**Metric:** `val_bpb` on a pinned validation shard of `climbmix-400b-shuffle`. The baseline (unmodified `train.py`) achieves approximately 0.998 val\_bpb from the example output shown in `program.md`. Any improvement the agent discovers represents a reproducible improvement in language modeling quality per byte.

**Compute efficiency:** The reported ~40% MFU on H100 indicates the training setup is relatively well-optimized at the baseline. Flash Attention 3, `torch.compile`, and the fused MuonAdamW kernels collectively contribute to this efficiency. The agent can potentially discover changes that improve MFU further (e.g., changing model depth/width to better utilize tensor cores).

**Platform dependency:** Results are explicitly **not** comparable across hardware platforms. The fixed 5-minute wall-clock budget means an H100 processes ~500M tokens per run while a consumer GPU would process far fewer. This is an intentional design choice: the system finds the best model *for your hardware in that time budget*, not an absolute best model.

**No formal comparisons:** The repository does not include comparisons to other automated research systems (AI-Scientist, Agent Laboratory, etc.). The project is not claiming to be more capable in an end-to-end sense — it is claiming to be more minimal.

---

## ✅ Strengths

**1. Radical simplicity with real research power.**  
The entire research environment fits in three files. There are no agent frameworks to configure, no tool-calling APIs to wire up, no paper-writing pipelines to maintain. Yet the output is real: the agent discovers genuinely useful training improvements on a real GPT training setup with modern components. The simplicity is not a toy limitation — it is a demonstration that meaningful automation does not require complexity.

**2. Fixed time budget enables fair apples-to-apples comparison.**  
The 5-minute wall-clock constraint is one of the most elegant design decisions in the system. It makes every experiment directly comparable regardless of what the agent changes: increasing model depth, changing batch size, switching activation functions, modifying the attention pattern — all are evaluated on exactly the same computational budget. This is a property that human-run hyperparameter searches often lack.

**3. `val_bpb` is a vocabulary-size-independent metric.**  
Measuring in bits-per-byte rather than perplexity or cross-entropy decouples the metric from tokenizer choices. An agent that discovers that a different vocabulary size improves efficiency gets credit for the actual information-theoretic improvement, not an artifact of token granularity. This makes the search space genuinely open: the agent can modify the tokenizer configuration in `prepare.py`... wait, no — `prepare.py` is read-only. But the agent can change vocabulary handling in `train.py`, and the metric remains fair.

**4. Git-based experiment ledger is clean and auditable.**  
Using git commits as the experiment record means the full history of what was tried is preserved, reviewable, and reproducible. A researcher can inspect the exact diff of each kept change. The TSV log provides a summary view while the git history provides the detailed view. This is better than many research codebases where experiment configurations are tracked in ad-hoc configuration files or not at all.

**5. Simplicity criterion encodes good research hygiene.**  
The explicit instruction to prefer deletions over additions, and to value simplicity as an independent criterion alongside metric improvement, is an unusual and valuable feature. Many optimization processes (including human researchers) suffer from complexity creep. By instructing the agent to actively prefer simpler code at equivalent performance, autoresearch tends to produce cleaner, more interpretable training scripts over time.

**6. Modern, research-grade training substrate.**  
`train.py` is not a toy. It implements Flash Attention 3, GQA, RoPE, SSSL sliding window patterns, Value Embeddings, per-layer learnable residual scalars, and the Muon optimizer with Polar Express orthogonalization and NorMuon variance reduction. This gives the agent meaningful, complex material to work with — the kind of material where non-obvious improvements are actually discoverable.

**7. `program.md` as a meta-research interface.**  
The human's role is to curate `program.md` over time, encoding accumulated knowledge: which directions have been explored, which seem promising, what constraints apply. This creates a feedback loop between the human's research intuition and the agent's computational throughput. The human does strategy; the agent does iteration.

**8. Notable community forks demonstrate portability.**  
Within a short period of release, community forks appeared for macOS (MLX), Windows (RTX), and AMD GPUs, demonstrating the simplicity of the approach: the core idea is hardware-agnostic even if the original implementation requires NVIDIA CUDA.

---

## ⚠️ Limitations

**1. Strictly domain-restricted.**  
autoresearch operates exclusively on `train.py`. The agent cannot generalize to other research domains, other model families, other tasks, or other codebases without a completely different setup. There is no mechanism for the agent to decide "I should look at a different training paradigm" — it operates within the confines of a single Python file training a language model on a fixed dataset.

**2. No literature awareness.**  
The agent has no access to papers, no web search, and no knowledge of recent ML research beyond what is encoded in its pre-training weights. It cannot discover that a paper published last month proposes a better optimizer, nor can it reference implementation details from published work. This is by design, but it means the agent's hypothesis space is bounded by its training-time knowledge.

**3. Hardware requirements are non-trivial.**  
The default configuration requires a single high-end NVIDIA GPU (H100 or equivalent). The ~45 GB VRAM usage at the baseline DEPTH=8 configuration is out of reach for most researchers outside well-funded labs. While community forks address this partially, using smaller models on consumer hardware reduces the research value (discoveries are less generalizable).

**4. Metric is hardware-platform-dependent.**  
Because the time budget is fixed at 5 minutes wall-clock, results are fundamentally non-comparable across platforms. Findings on an H100 (which processes ~500M tokens per run) cannot be directly compared to findings on a 3090 (which might process ~100M tokens). This limits the scientific value of the discoveries for the broader community — though Karpathy acknowledges this explicitly as a known trade-off.

**5. No long-horizon memory or meta-learning.**  
Each agent session starts from reading `program.md` and `train.py`. There is no persistent agent memory beyond what the human encodes in `program.md`. The agent cannot learn from patterns across sessions, cannot identify systematic biases in its own hypotheses, and cannot apply meta-level reasoning ("the last 10 optimizer changes all failed — perhaps I should try architecture changes"). This limits the efficiency of the search over multi-day research campaigns.

**6. Context window exhaustion over long runs.**  
As the experiment loop continues, the LLM's context window accumulates the conversation history of all previous hypotheses, experiments, and results. Eventually — for long-running sessions — the context fills, degrading hypothesis quality or requiring the session to be restarted. `program.md` instructs the agent to redirect `train.py` output to `run.log` to mitigate this, but the conversation history itself grows unboundedly.

**7. No formal experiment design or hypothesis tracking.**  
The agent does not maintain a structured hypothesis space, does not perform designed experiments (e.g., factorial ablations), and does not reason about interaction effects between modifications. Each hypothesis is generated independently. This may lead to the agent repeatedly exploring nearby local optima rather than systematically mapping the search space. `results.tsv` provides a flat log but no structured analysis.

**8. Single-metric optimization may miss multi-objective trade-offs.**  
The sole objective is minimizing `val_bpb`. Efficiency metrics like VRAM usage, tokens-per-second, or FLOPs-per-step are tracked and logged but are not part of the optimization criterion. An agent might discover a configuration that marginally improves `val_bpb` while dramatically increasing VRAM usage, making it impractical for real deployment. `program.md` includes a soft "VRAM is a soft constraint" instruction, but this is not enforced.

**9. Relies on LLM code editing quality.**  
The agent's success depends entirely on the quality of LLM-generated code modifications. Bugs introduced by the agent — subtle numerical errors, incorrect shape manipulations, inadvertent behavior changes — may produce misleading results. The crash detection (checking for empty grep output) catches obvious failures but not silent regressions where the code runs but no longer trains the intended model.

---

## 🔗 Related Work

**[AI-Scientist (SakanaAI, 2024)](https://github.com/SakanaAI/AI-Scientist)**  
The most direct successor in spirit. AI-Scientist builds substantially on the experiment-loop concept but adds literature review via Semantic Scholar, LaTeX paper writing, and automated peer review. Where autoresearch is a pure experiment loop (~3 files), AI-Scientist is a full research pipeline (~dozens of files). AI-Scientist uses autoresearch-style code modification as one component within a larger system. The relationship is foundational: autoresearch demonstrates the core loop works; AI-Scientist demonstrates it can be embedded in an end-to-end research automation pipeline.

**[NanoGPT / nanochat (Karpathy)](https://github.com/karpathy/nanochat)**  
The direct parent codebase. `train.py` in autoresearch is described as "cherry-picked and simplified from nanochat." nanochat is the research-grade single-GPU GPT implementation Karpathy developed for his own research; autoresearch wraps it in an agent loop. For users who want to understand the model architecture in more depth, or who need multi-GPU or non-NVIDIA support, nanochat is the reference.

**[Muon Optimizer (Kosson et al. / Jordan et al.)](https://github.com/KellerJordan/modded-nanogpt)**  
The Muon optimizer implemented in `train.py` (including the Polar Express orthogonalization and NorMuon variance reduction) is derived from the modded-nanogpt line of research. autoresearch is itself a downstream consumer of this research, and ironically is positioned to discover further improvements to optimizer design autonomously.

**[OpenAI Codex / Anthropic Claude](https://anthropic.com)**  
autoresearch is agent-agnostic — it works with "Claude/Codex or whatever you want." In practice, capable code-editing models are essential for the experiment quality. The system's performance ceiling is directly coupled to the code generation and reasoning quality of the underlying LLM.

**[Agent Laboratory](https://github.com/SamuelSchmidgall/AgentLaboratory)**  
A related autonomous research framework that positions itself as a full research assistant for ML. Compared to autoresearch, Agent Laboratory is more elaborate (multi-agent, tool-use, literature review) but operates on a more diverse range of tasks. The contrast illustrates the autoresearch philosophy: do one thing (train-script optimization) with zero unnecessary complexity.

**[AI-Scientist-v2 (SakanaAI, 2025)](https://github.com/SakanaAI/AI-Scientist-v2)**  
Extended version of AI-Scientist with improved paper quality, more templates, and better review processes. Represents the "full pipeline" direction, in contrast to autoresearch's "pure loop" direction.

**[Modded-NanoGPT (Speed Records Project)](https://github.com/KellerJordan/modded-nanogpt)**  
A community benchmark for maximally fast NanoGPT training, exploring similar territory (architecture and optimizer improvements) but driven by human researchers competing for speed records rather than an autonomous agent. autoresearch can be seen as an automated version of this community research activity.

---

## 📎 References

1. Karpathy, A. (2026). *autoresearch*. GitHub Repository. [https://github.com/karpathy/autoresearch](https://github.com/karpathy/autoresearch)

2. Karpathy, A. (2026). Tweet/announcement. [https://x.com/karpathy/status/2029701092347630069](https://x.com/karpathy/status/2029701092347630069)

3. Lu, C., Lu, C., Lange, R. T., Foerster, J., Clune, J., & Ha, D. (2024). *The AI Scientist: Towards Fully Automated Open-Ended Scientific Discovery*. arXiv:2408.06292. [https://arxiv.org/abs/2408.06292](https://arxiv.org/abs/2408.06292)

4. Jordan, K. (2024). *modded-nanogpt*. GitHub Repository. [https://github.com/KellerJordan/modded-nanogpt](https://github.com/KellerJordan/modded-nanogpt) — Source of the Muon optimizer and Polar Express orthogonalization coefficients used in `train.py`.

5. Kosson, A., Wortsman, M., Mishra, S., & Schmidt, L. (2024). *NorMuon: Normalizing the Muon Optimizer*. — Referenced for the NorMuon variance reduction technique in the MuonAdamW implementation.

6. Karpathy, A. (2023+). *nanochat*. GitHub Repository. [https://github.com/karpathy/nanochat](https://github.com/karpathy/nanochat) — Parent codebase from which `train.py` is derived.

7. Dao, T. (2023). *FlashAttention-2: Faster Attention with Better Parallelism and Work Partitioning*. arXiv:2307.08691. [https://arxiv.org/abs/2307.08691](https://arxiv.org/abs/2307.08691) — Predecessor to Flash Attention 3 used in the attention kernel.

8. Su, J., Lu, Y., Pan, S., Murtadha, A., Wen, B., & Liu, Y. (2021). *RoFormer: Enhanced Transformer with Rotary Position Embedding*. arXiv:2104.09864. — RoPE implementation in the attention module.

9. Schmidt, L., & Wortsman, M. (2024). *Scaling up muP*. — Background for the muP-style learning rate scaling (`dmodel_lr_scale = (model_dim / 768) ** -0.5`) in `setup_optimizer`.

10. Team, G. (2024). *Gemma 2: Improving Open Language Models at a Practical Size*. Google DeepMind. — Source of the logit soft-capping technique (`15 * tanh(logits / 15)`) used in `GPT.forward()`.

11. Schmidgall, S., et al. (2025). *Agent Laboratory: Using LLM Agents as Research Assistants*. arXiv:2501.04227. [https://arxiv.org/abs/2501.04227](https://arxiv.org/abs/2501.04227) — Related autonomous research system for comparison.

12. miolini. (2026). *autoresearch-macos*. [https://github.com/miolini/autoresearch-macos](https://github.com/miolini/autoresearch-macos) — Notable community fork for macOS/Apple Silicon.
