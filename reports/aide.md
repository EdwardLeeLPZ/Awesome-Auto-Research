# AIDE (AI Development Environment)

> A machine learning research agent from WecoAI that implements tree-search over the ML solution space, using iterative code refinement to automatically improve model performance on ML tasks — and serves as the code execution backbone of AI-Scientist-v2.

## Overview

AIDE (AI Development Environment) is an open-source ML research automation system developed by WecoAI.
With over 1,200 GitHub stars, AIDE represents a focused approach to automating the code generation and iterative improvement loop in machine learning research.

Unlike general-purpose code agents (Aider, OpenHands), AIDE is specifically designed for the ML experiment workflow.
It understands the structure of an ML task (dataset, metric, baseline code) and uses a tree-search strategy to explore multiple solution variants, retaining and building on the best-performing ones.

AIDE became particularly prominent when it was adopted as the code execution layer in SakanaAI's AI-Scientist-v2.
In that context, AIDE handles the iterative code refinement sub-task while AI-Scientist-v2's BFTS (Beam-search agentic tree search) manages the higher-level research direction.
This integration demonstrates AIDE's suitability for research automation pipelines.

The tree-search approach fundamentally distinguishes AIDE from linear coding agents.
Rather than generating one solution and iterating on it until it works, AIDE explores a branching space of solution variants, backtracking from dead ends and advancing from promising branches.
This makes it more robust to local optima in the solution space.

## Architecture

AIDE's architecture centres on a solution tree with LLM-guided expansion:

```
┌─────────────────────────────────────────────────┐
│                  AIDE System                     │
│                                                  │
│  ┌─────────────────────────────────┐            │
│  │         Solution Tree           │            │
│  │                                 │            │
│  │     root (baseline code)        │            │
│  │      ├── variant_A (expand)     │            │
│  │      │    ├── A1 (best metric)  │            │
│  │      │    └── A2 (pruned)       │            │
│  │      └── variant_B              │            │
│  │           └── B1 (current best) │            │
│  └─────────────┬───────────────────┘            │
│                │                                 │
│  ┌─────────────▼───────────────────┐            │
│  │   LLM-guided Tree Operations    │            │
│  │   - Expand: generate child node │            │
│  │   - Evaluate: run code, score   │            │
│  │   - Prune: remove low performers│            │
│  │   - Backtrack: return to parent │            │
│  └─────────────┬───────────────────┘            │
│                │                                 │
│  ┌─────────────▼───────────────────┐            │
│  │   Execution Environment         │            │
│  │   - Subprocess / Docker         │            │
│  │   - Metric extraction           │            │
│  │   - Error capture + feedback    │            │
│  └─────────────────────────────────┘            │
└─────────────────────────────────────────────────┘
```

The solution tree is the central data structure.
Each node represents a version of the ML solution (a complete Python script).
Tree operations are guided by an LLM that reads the current node's code and execution output before proposing the next change.

## Core Workflow

1. **Task intake** — user provides a task specification: dataset path, metric to optimise, optional baseline code.
2. **Root initialisation** — if no baseline is provided, AIDE generates a minimal viable solution as the root node.
3. **Root evaluation** — root code is executed; metric score and any errors are captured.
4. **Tree expansion** — LLM proposes a code change (bugfix, architecture improvement, hyperparameter adjustment) to create a child node.
5. **Child evaluation** — child code is executed; metric compared to parent.
6. **Tree management** — nodes below a pruning threshold are removed; promising nodes are kept for further expansion.
7. **Backtracking** — if the current branch stagnates, AIDE backtracks to a higher-scoring ancestor.
8. **Iteration** — steps 4–7 repeat for a configured number of iterations or until a target metric is reached.
9. **Best solution extraction** — the highest-scoring leaf node in the tree is returned as the final solution.

## Key Features

- **Tree-search exploration** — systematic exploration of solution variants avoids local optima that linear iteration falls into.
- **ML-task-specific design** — understands dataset, metric, model, and training loop concepts natively.
- **Error-driven refinement** — execution errors are automatically fed back to the LLM with line-number context for targeted fixes.
- **Backtracking** — ability to return to better-performing ancestors when a branch stagnates.
- **Integration with AI-Scientist-v2** — used as the code execution engine in SakanaAI's peer-reviewed autonomous research system.
- **Metric-aware optimisation** — all refinement decisions are driven by concrete metric improvements, not LLM confidence.

## Technical Implementation

### Tree-Search Algorithm

AIDE implements a variant of Monte Carlo Tree Search (MCTS) adapted for code generation:
- **Selection** — choose a leaf node to expand using a UCB1-like formula balancing exploration (low visit count) and exploitation (high metric score).
- **Expansion** — generate child code by prompting the LLM with the parent code and a description of the desired improvement.
- **Simulation** — execute the child code and extract the metric score.
- **Backpropagation** — update all ancestor nodes' value estimates with the new result.

This principled exploration strategy is superior to greedy single-path iteration for complex ML tasks.

### Code Generation

AIDE uses a structured prompt format for code generation:
```
Current code: [full Python script]
Current metric: [score]
Execution output: [stdout/stderr, last N lines]
Task: [description of improvement to make]
Instruction: Produce the complete improved Python script.
```

Returning the complete script (not just a diff) ensures the LLM has full context and produces syntactically valid code.

### Execution Environment

Code runs in a subprocess with a configurable timeout.
Metric extraction uses a standardised pattern: the code is expected to print the metric score in a parseable format (e.g., `METRIC: 0.8732`).
Execution environments can be configured to use Docker for isolation in research pipeline integrations.

### Error Handling

When code fails:
1. AIDE captures the full traceback.
2. The LLM receives the error with line-number context.
3. A fix is requested rather than a new feature.
4. The fix is applied and the code is re-executed.
5. Persistent errors trigger backtracking to the parent node.

## Evaluation & Benchmarks

### Kaggle Competition Tasks
- AIDE was evaluated on Kaggle-style ML competition tasks (tabular data, time series, NLP).
- Achieves competitive performance compared to human participants on several benchmarks.
- Tree-search outperforms single-path iteration by a significant margin on multi-modal task types.

### MLE-Bench Integration
- AIDE aligns with the MLE-bench evaluation framework (OpenAI), which tests ML engineering on Kaggle tasks.
- WecoAI reports meaningful performance improvements over baseline LLM prompting.

### AI-Scientist-v2 Integration
- Used as the code execution layer in AI-Scientist-v2's BFTS pipeline.
- In this context, AIDE handles iterative ML code improvement while the BFTS layer manages research direction selection.
- The combination resulted in the first AI-written paper accepted through standard peer review.

## Strengths

- **Tree-search robustness** — systematically explores solution space; more reliable than linear iteration for complex tasks.
- **ML-specific design** — purpose-built for ML experiment automation, not a general code agent repurposed.
- **Proven integration** — used in AI-Scientist-v2, demonstrating real-world research automation utility.
- **Metric-driven** — all decisions are grounded in concrete metric measurements, not LLM confidence.
- **Error recovery** — robust error handling prevents single failures from halting the search.

## Limitations

- **ML experiment scope** — optimised for supervised ML tasks with clear metrics; less suited for open-ended research or NLP generation tasks.
- **Requires clear metric** — AIDE needs a well-defined, computable metric for the search to function; ambiguous quality measures are not supported.
- **Computational cost** — tree-search requires executing many code variants; each execution can take minutes for large models.
- **No literature integration** — AIDE operates on code alone; it has no mechanism to retrieve or incorporate research literature.
- **Limited to Python** — designed for Python ML code; other languages or frameworks require significant adaptation.

## Related Work

- **Aider** — general-purpose code editing CLI; interactive, not tree-search-based.
- **SWE-agent** — repository-level issue resolution with ACI; different task scope (bugs vs. metric optimisation).
- **AI-Scientist-v2** — uses AIDE as a component in a broader autonomous research pipeline.
- **OpenHands** — broader autonomous coding agent; more task types but less ML-specific optimisation.
- **RD-Agent** — Microsoft's R&D automation framework; similar focus on quantitative research tasks.

## References

1. WecoAI. (2024). *AIDE: AI Development Environment*. https://github.com/WecoAI/aideml
2. Lu, C. et al. (2025). *The AI Scientist-v2: Workshop-Level AI Research Automation*. arXiv:2504.08066.
3. Chan, J. et al. (2024). *MLE-bench: Evaluating Machine Learning Agents on Machine Learning Engineering*. arXiv:2410.07095.
4. Coulom, R. (2006). *Efficient Selectivity and Backup Operators in Monte-Carlo Tree Search*. CG 2006.
5. Chen, M. et al. (2021). *Evaluating Large Language Models Trained on Code*. arXiv:2107.03374.
6. Yang, J. et al. (2024). *SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering*. arXiv:2405.15793.

---

### Practitioner Notes

**Task setup:** AIDE requires a task description file (task.md) and optionally a baseline Python script.
The task description should specify the dataset location, the metric to optimise, and any constraints (runtime budget, memory limits).
Including a simple baseline script significantly accelerates the tree search by providing a starting point.

**Resource management:**
- Each tree node evaluation runs the full training/evaluation loop; budget accordingly.
- Use `--timeout 300` to prevent individual evaluations from running indefinitely.
- For GPU-intensive tasks, AIDE supports parallel evaluation of sibling nodes across multiple GPUs.

**Integration with AI-Scientist-v2:**
AIDE is used as the code execution layer in AI-Scientist-v2's BFTS pipeline.
In this integration, AIDE's tree-search operates within a single "code improvement" phase directed by the BFTS outer loop.
The BFTS layer makes high-level research direction decisions; AIDE executes and improves the corresponding code.
This separation of strategic planning (BFTS) from tactical code improvement (AIDE) is the key architectural innovation of AI-Scientist-v2.

**Comparison with competitors:**
On Kaggle-style tabular ML tasks, AIDE outperforms single-path LLM coding agents (Aider, OpenHands) by 15–25% on final metric score, primarily due to the backtracking capability.
For NLP generation tasks without a clear scalar metric, AIDE is less well-suited; using a proxy metric (ROUGE, BLEU) is possible but less reliable than direct task metrics.

**Cost profile:**
Tree-search with depth=5 and branching=3 requires running up to 15 code variants.
For small ML models (<1 minute per run), total cost is manageable.
For large models (>1 hour per run), limit tree depth to 2–3 or use AIDE's early stopping heuristics.
