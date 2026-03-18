# AutoDidact — Self-Bootstrapping Research Agent Training via RL
> Autonomously trains research LLMs on custom corpora using GRPO reinforcement learning and self-verification — runs on a single consumer GPU.

---

## 📌 Project Overview

**AutoDidact** (full name: *AutoDidact: Bootstrapping Search Through Self-Verification*) is an open-source framework by [Dan Caples (dCaples)](https://github.com/dCaples) that enables small language models to autonomously train themselves to search and reason over custom document corpora — without any human annotation.

| Attribute        | Detail                                                                 |
|------------------|------------------------------------------------------------------------|
| **Repository**   | https://github.com/dCaples/AutoDidact                                  |
| **Author**       | dCaples (Dan Caples)                                                   |
| **Stars**        | 684                                                                    |
| **Base Model**   | Llama-3 8B                                                             |
| **RL Algorithm** | GRPO (Group Relative Policy Optimization)                              |
| **Hardware**     | Single NVIDIA RTX 4090 (24 GB VRAM)                                   |
| **License**      | Open-source                                                            |

The core insight is a **self-bootstrapping loop**: the same model that will be trained is first used to generate its own question-answer training pairs from raw documents, then trained via reinforcement learning (RL) to correctly answer those questions through agentic search — with itself acting as verifier.

- No human-labeled data required at any stage
- Fully local: every component (embedding, generation, RL) runs on open-source models
- Demonstrated on the Apollo 13 mission report: accuracy improved from **23% → 59%** in ~1 hour of training

---

## 🎯 Project Positioning

AutoDidact occupies a unique niche at the intersection of **retrieval-augmented generation (RAG)**, **reinforcement learning from self-play**, and **autonomous agent training**.

### Problem it Solves

Traditional approaches to training research agents require:
1. Large, human-annotated QA datasets aligned to the target corpus
2. Expensive proprietary model APIs for data generation or reward modeling
3. Multi-GPU clusters for RL fine-tuning

AutoDidact eliminates all three requirements.

### Target Use Cases

- **Domain adaptation**: Train a research agent on proprietary or niche corpora (legal docs, internal wikis, scientific papers) without external data
- **Education / personal knowledge bases**: Build a self-improving Q&A agent over personal document collections
- **RL research**: Cheap, reproducible testbed for studying agentic RL on information retrieval tasks
- **Low-resource deployment**: Organizations lacking annotation budgets or GPU clusters

### Differentiation from Related Systems

| System | Annotation | Hardware | Self-bootstrapped |
|--------|-----------|----------|-------------------|
| RAG pipelines | ✗ needed | CPU/GPU | ✗ |
| RLHF fine-tuning | ✅ human labels | Multi-GPU | ✗ |
| Self-play RL (games) | ✗ | Varies | ✅ |
| **AutoDidact** | ✗ | Single RTX 4090 | ✅ |

AutoDidact's self-verification reward signal removes the need for a separate, stronger "teacher" model, distinguishing it from distillation-based pipelines.

---

## 🏗️ System Architecture

AutoDidact follows a **closed-loop architecture** where a single model family handles all stages: question generation, retrieval, self-verification, and RL training.

```
┌─────────────────────────────────────────────────────────────┐
│                     Raw Document Corpus                     │
└──────────────────────────┬──────────────────────────────────┘
                           │  Chunking & Embedding
                           ▼
┌─────────────────────────────────────────────────────────────┐
│               Vector Store (FAISS / similar)                │
└──────────┬──────────────────────────────────────────────────┘
           │                              ▲  Search Queries
           │  Context chunks              │
           ▼                              │
┌──────────────────────┐       ┌──────────────────────────────┐
│  Llama-8B (Generator)│──────▶│  Agentic Search Loop (ReAct) │
│  QA Pair Generation  │       │  Tool calls + reasoning      │
└──────────────────────┘       └──────────────┬───────────────┘
           │                                  │
           │  (question, gold_answer) pairs    │  Predicted answers
           ▼                                  ▼
┌──────────────────────────────────────────────────────────────┐
│              Llama-8B (Self-Verifier)                        │
│     Compares predicted answer to gold → binary reward        │
└──────────────────────────┬───────────────────────────────────┘
                           │  Reward signal
                           ▼
┌──────────────────────────────────────────────────────────────┐
│         GRPO Training Loop (Unsloth efficient GRPO)          │
│   Updates model weights to maximize self-verification reward │
└──────────────────────────────────────────────────────────────┘
```

All components share the same base model (Llama-3 8B), enabling single-GPU operation through sequential usage rather than simultaneous multi-model inference.

---

## ⚙️ Core Components & Workflow

The AutoDidact pipeline consists of six sequential, fully automated stages:

### Stage 1 — Document Ingestion & Chunking

- Load raw documents (PDF, text, HTML, etc.)
- Chunk documents into overlapping passages for granular retrieval
- Preserve source metadata for attribution

### Stage 2 — Embedding & Vector Index Creation

- Encode all chunks with an open-source embedding model
- Build a FAISS (or equivalent) vector index for fast approximate nearest-neighbor search
- Index is reused across training steps — built once, queried many times

### Stage 3 — Self-Generated Question-Answer Pair Creation

- Llama-8B reads sampled document chunks and generates plausible factual questions
- For each question, a reference answer is extracted from the source chunk
- No human review — the model autonomously creates its own training curriculum

```python
# Conceptual illustration of QA generation
for chunk in document_chunks:
    questions = llama8b.generate(
        f"Generate factual questions answerable from:\n{chunk}"
    )
    for q in questions:
        gold_answer = llama8b.generate(f"Answer: {q}\nContext: {chunk}")
        dataset.append({"question": q, "gold": gold_answer, "source": chunk})
```

### Stage 4 — Agentic Search Loop (ReAct-style)

- For each training question, the agent iteratively issues search queries to the vector store
- Uses a **ReAct** (Reasoning + Acting) loop: think → search → observe → refine → answer
- Tool calls are formatted as structured function calls; Unsloth's GRPO code is extended to support them
- Loop terminates when the model produces a final answer or a step limit is reached

### Stage 5 — Self-Verification Reward Signal

- Llama-8B (acting as verifier) compares the agent's final answer to the gold answer
- Outputs a binary or graded reward score
- No external judge, no GPT-4 calls — fully self-contained

### Stage 6 — GRPO Reinforcement Learning

- Uses **Group Relative Policy Optimization** (GRPO), a PPO-variant that avoids a separate value network
- Multiple rollouts per question are sampled; rewards are normalized within the group
- Unsloth's efficient GRPO implementation reduces VRAM usage, enabling single-GPU training
- Model weights updated to increase probability of search trajectories that led to correct answers

---

## 🔧 Technical Details

### Reinforcement Learning: GRPO

GRPO removes the critic network required by standard PPO, instead normalizing rewards across a group of sampled outputs for the same prompt:

```
Advantage_i = (r_i - mean(r)) / std(r)
```

This makes it more stable and memory-efficient than PPO for LLM fine-tuning, critical for fitting within 24 GB VRAM.

### Unsloth Integration & Function-Calling Support

AutoDidact builds on [Unsloth](https://github.com/unslothai/unsloth)'s efficient GRPO implementation and extends it with:

- **Structured tool-call parsing**: Enables the model to emit and parse function-call syntax during rollouts
- **Agentic loop scaffolding**: Multi-turn rollout support where the model alternates between reasoning and tool use
- **Gradient checkpointing**: Reduces activation memory at the cost of recomputation

### Vector Retrieval

- Embedding model: open-source (e.g., `sentence-transformers` family)
- Index: FAISS for approximate nearest-neighbor search
- Query: free-form natural language search queries emitted by the agent
- Top-k chunks returned as observation in the ReAct loop

### Model Configuration

| Parameter            | Value                          |
|----------------------|--------------------------------|
| Base model           | Llama-3 8B                     |
| LoRA rank            | Configurable (e.g., r=16)      |
| Training steps       | ~100 (Apollo 13 demo)          |
| Training time        | ~1 hour (single RTX 4090)      |
| Rollouts per prompt  | Multiple (GRPO group size)     |
| Context window       | Standard Llama-3 context       |

### Failure Modes Addressed by Training

Before GRPO training, the base model exhibited:
- Malformed tool-call syntax (invalid JSON / wrong schema)
- Hallucinated answers without searching the corpus
- Role-playing the search engine instead of calling it
- Non-terminating or circular search loops

After training, these failure modes are substantially reduced.

---

## 📊 Performance & Benchmarks

### Apollo 13 Mission Report — Primary Evaluation

The flagship demonstration uses the NASA Apollo 13 mission report as the target corpus.

| Metric                         | Before Training | After Training | Δ       |
|--------------------------------|-----------------|----------------|---------|
| Accuracy (68-question val set) | 23%             | 59%            | **+36 pp** |
| Training steps                 | —               | ~100           | —       |
| Training time                  | —               | ~1 hour        | —       |
| Hardware                       | RTX 4090        | RTX 4090       | —       |

- Accuracy **more than doubled** in a single hour of RL training
- Validation set: 68 held-out questions drawn from the same self-generated pool (not used during training)

### Behavioral Changes Observed

**Before training (base Llama-8B):**
- Issued vague or malformed search queries
- Often skipped search and hallucinated answers directly
- Confused its own role with the tool's role
- Produced inconsistently formatted responses

**After 100 GRPO steps:**
- Issues concise, well-formed search queries
- Iteratively refines queries based on retrieved context
- Maintains correct tool-call format throughout
- Produces grounded answers traceable to retrieved passages

### Generalization Expectation

While the Apollo 13 corpus is the demonstrated benchmark, the pipeline is corpus-agnostic. Performance on other domains is expected to follow a similar trajectory given sufficient document coverage and question diversity, though this has not yet been independently benchmarked.

---

## ✅ Strengths

### 1. Zero Human Annotation Required
The self-bootstrapping loop — generate questions, search, verify, train — requires no labeled data whatsoever. This is a significant practical advantage for organizations with proprietary or niche corpora.

### 2. Consumer GPU Accessibility
Running on a single RTX 4090 democratizes RL-based agent training. Previously, RLHF or PPO-style training required multi-GPU clusters; AutoDidact fits in 24 GB VRAM.

### 3. Fully Open-Source Stack
Every component uses open-source models and libraries:
- Llama-3 8B (Meta, Apache 2.0)
- Unsloth (efficient GRPO)
- FAISS (Facebook AI, MIT)
- Hugging Face Transformers / TRL

No API keys, no proprietary model calls, no data leaving the local machine.

### 4. Emergent Tool-Use Behavior
The model learns correct function-calling behavior purely from the RL reward signal, without explicit tool-use supervised fine-tuning (SFT). This demonstrates RL's power for shaping structured output formats.

### 5. Self-Contained Reward Signal
Using the same model family for verification avoids reward hacking by a weaker verifier and removes dependency on GPT-4 or Claude as judges — a common limitation in RLHF pipelines.

### 6. Modular Pipeline
Each stage (embedding, QA generation, agentic loop, GRPO) is independently replaceable. Users can swap in stronger embedding models, different RL algorithms, or alternative verifiers without redesigning the full system.

### 7. Impressive Speed of Improvement
Doubling accuracy (23% → 59%) in one hour of training on a single consumer GPU is a compelling proof-of-concept for fast domain adaptation.

---

## ⚠️ Limitations

### 1. Self-Verification Reliability
Llama-8B verifying its own answers introduces a **circularity risk**: if the model is confidently wrong, its verifier may agree, producing a misleading reward signal. No independent human evaluation of verifier accuracy is reported.

### 2. Question Quality Ceiling
Self-generated questions may be biased toward easily answerable, surface-level facts. Hard inferential or cross-document questions — which matter most for research tasks — may be underrepresented in the training curriculum.

### 3. Single-Corpus Evaluation
Only the Apollo 13 report has been publicly benchmarked. Generalization to other domains (scientific literature, legal documents, multilingual corpora) remains unvalidated.

### 4. Validation Set Contamination Risk
Since both training questions and validation questions are generated by the same model from the same corpus, there is a risk of distributional overlap that could inflate reported accuracy gains.

### 5. Compute Requirement Still Non-Trivial
An RTX 4090 (≈$1,600 MSRP) is a consumer card but not universally accessible. Cloud equivalents (A100/H100) are expensive. Scaling to larger models (70B) would require multi-GPU setups.

### 6. Limited Scalability Beyond 8B
The self-verification quality is bounded by Llama-8B's reasoning capability. For highly technical domains, a small model's judgment of answer correctness may be unreliable, degrading the reward signal.

### 7. No Comparison to Supervised Baselines
The paper/repo does not compare GRPO-trained AutoDidact against a supervised fine-tuned (SFT) baseline trained on the same self-generated QA pairs, making it unclear how much of the gain is due to RL specifically vs. domain exposure.

### 8. Reproducibility Across Corpora
The hyperparameters (GRPO group size, LoRA rank, learning rate, number of steps) were tuned for Apollo 13. Optimal settings for other corpora may differ substantially.

---

## 🔗 Related Work

AutoDidact draws on and relates to several active research threads:

### Retrieval-Augmented Generation (RAG)
- **Lewis et al. (2020)** — Original RAG paper combining dense retrieval with seq2seq generation
- **Self-RAG (Asai et al., 2023)** — Trains models to reflect on and critique their own retrievals; conceptually adjacent to AutoDidact's self-verification
- AutoDidact extends RAG by *training* the retrieval policy rather than using a frozen retriever

### Reinforcement Learning for LLMs
- **PPO for RLHF (Ouyang et al., 2022 — InstructGPT)** — Established RL as a fine-tuning paradigm for LLMs
- **GRPO (DeepSeek-R1, 2024)** — The specific RL algorithm AutoDidact adopts; eliminates critic network
- **RLVR (RL with Verifiable Rewards)** — AutoDidact's self-verification can be seen as a form of verifiable reward

### Agentic / Tool-Use LLMs
- **ReAct (Yao et al., 2022)** — Interleaving reasoning traces and actions; AutoDidact's search loop follows this pattern
- **Toolformer (Schick et al., 2023)** — Self-supervised learning of tool use; AutoDidact uses RL instead of SFT
- **WebGPT (Nakano et al., 2021)** — Human-supervised web search training; AutoDidact removes human labels

### Self-Play and Self-Improvement
- **STaR (Zelikman et al., 2022)** — Self-taught reasoning via iterative bootstrapping; philosophically similar
- **ReST (Gulcehre et al., 2023)** — Reinforced self-training via iterative data generation and fine-tuning
- AutoDidact combines the self-generation spirit of STaR with the RL refinement of ReST in an agentic search setting

### Efficient LLM Training
- **Unsloth** — Memory-efficient LoRA + GRPO training library that makes single-GPU RL viable
- **QLoRA (Dettmers et al., 2023)** — 4-bit quantized fine-tuning; complementary to AutoDidact's approach

---

## 📎 References

1. **AutoDidact Repository** — dCaples (Dan Caples). *AutoDidact: Bootstrapping Search Through Self-Verification*. GitHub, 2024. https://github.com/dCaples/AutoDidact

2. **GRPO** — DeepSeek-AI. *DeepSeek-R1: Incentivizing Reasoning Capability in LLMs via Reinforcement Learning*. 2025. https://arxiv.org/abs/2501.12948

3. **Unsloth** — Efficient GRPO and LoRA training library. https://github.com/unslothai/unsloth

4. **ReAct** — Yao, S. et al. *ReAct: Synergizing Reasoning and Acting in Language Models*. ICLR 2023. https://arxiv.org/abs/2210.03629

5. **RAG** — Lewis, P. et al. *Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks*. NeurIPS 2020. https://arxiv.org/abs/2005.11401

6. **Self-RAG** — Asai, A. et al. *Self-RAG: Learning to Retrieve, Generate, and Critique through Self-Reflection*. ICLR 2024. https://arxiv.org/abs/2310.11511

7. **InstructGPT / RLHF** — Ouyang, L. et al. *Training language models to follow instructions with human feedback*. NeurIPS 2022. https://arxiv.org/abs/2203.02155

8. **Toolformer** — Schick, T. et al. *Toolformer: Language Models Can Teach Themselves to Use Tools*. NeurIPS 2023. https://arxiv.org/abs/2302.04761

9. **STaR** — Zelikman, E. et al. *STaR: Bootstrapping Reasoning With Reasoning*. NeurIPS 2022. https://arxiv.org/abs/2203.14465

10. **ReST** — Gulcehre, C. et al. *Reinforced Self-Training (ReST) for Language Modeling*. 2023. https://arxiv.org/abs/2308.08998

11. **Llama 3** — Meta AI. *Meta Llama 3*. 2024. https://ai.meta.com/blog/meta-llama-3/

12. **FAISS** — Johnson, J., Douze, M., Jégou, H. *Billion-scale similarity search with GPUs*. IEEE Transactions on Big Data, 2019. https://github.com/facebookresearch/faiss

---

*Report generated for the [Awesome-Auto-Research](https://github.com/EdwardLeeLPZ/Awesome-Auto-Research) repository.*
