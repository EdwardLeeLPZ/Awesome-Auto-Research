# SWE-agent
> A structured autonomous software engineering agent from Princeton NLP that introduces the Agent-Computer Interface (ACI) — a carefully designed set of tools that gives LLMs efficient, error-resistant access to codebases for resolving real GitHub issues.

---

## 📌 Project Overview

**Repository:** https://github.com/SWE-agent/SWE-agent  
**Organization:** Princeton NLP (Princeton University)  
**License:** MIT  
**Language:** Python  
**Paper:** "SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering" (Yang et al., NeurIPS 2024)

SWE-agent is a research-grade autonomous software engineering framework developed at Princeton NLP. Its central contribution is the concept of the **Agent-Computer Interface (ACI)** — the idea that the interface through which an LLM agent interacts with a codebase is just as important as the LLM itself. By designing a purpose-built interface that prevents common agent failure modes (losing context, corrupting files, getting stuck in loops), SWE-agent enables LLMs to solve real-world GitHub issues with significantly higher success rates than giving agents raw terminal access.

The system was published at **NeurIPS 2024** and serves as one of the most widely used research baselines in autonomous software engineering. GPT-4o combined with SWE-agent achieves **12–18% on SWE-Bench**, which was state-of-the-art at the time of publication and remains a strong competitive baseline.

SWE-agent records full **trajectories** — complete logs of agent reasoning, tool calls, and outputs — making it exceptionally useful for research into agent behavior, failure modes, and improvement strategies.

---

## 🎯 Project Positioning

SWE-agent is primarily positioned as a **research tool and baseline**, though it is capable of solving real software engineering tasks. Its design philosophy prioritizes:

1. **Rigor**: Every interaction is logged as a trajectory for analysis.
2. **Controlled interface**: The ACI constrains the agent's action space to prevent catastrophic failures.
3. **Reproducibility**: YAML-based configuration makes experiments fully reproducible.
4. **Extensibility**: Custom tools, models, and task formats can be added via configuration.

**Compared to competing systems:**
- vs. **OpenHands**: OpenHands is more open-ended (code-as-action, any Python expressible operation); SWE-agent is more structured with a fixed, well-designed toolset. OpenHands scores higher on SWE-Bench (72% vs ~18%) but is harder to analyze scientifically.
- vs. **Aider**: Aider targets human-in-the-loop workflows; SWE-agent is designed for fully autonomous operation and research benchmarking.
- vs. **Agentless**: Agentless avoids agent loops entirely; SWE-agent embraces the loop but tightly controls it via the ACI.
- vs. **AutoCodeRover**: AutoCodeRover uses program analysis (AST, call graphs) for code navigation; SWE-agent uses the ACI's file viewer and search tools.

The SWE-agent paper's core argument: **a well-designed interface can dramatically improve agent capability without changing the underlying LLM.** The same GPT-4 that struggles to edit files reliably via raw bash access performs significantly better when given the ACI's structured file editor.

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         SWE-agent                           │
│                                                             │
│  ┌───────────────┐    ┌──────────────────────────────────┐ │
│  │  Task Config  │    │         Agent Config             │ │
│  │  (YAML)       │    │         (YAML)                   │ │
│  │               │    │  - model: gpt-4o                 │ │
│  │  - repo URL   │    │  - system_template               │ │
│  │  - issue text │    │  - tools: [editor, bash, search] │ │
│  │  - test cmd   │    │  - max_iterations: 30            │ │
│  └───────┬───────┘    └──────────────┬───────────────────┘ │
│          └──────────────┬────────────┘                      │
│                         ▼                                   │
│              ┌──────────────────────┐                       │
│              │      Agent Loop      │                       │
│              │  1. Build context    │                       │
│              │  2. Call LLM         │                       │
│              │  3. Parse action     │                       │
│              │  4. Execute via ACI  │                       │
│              │  5. Get observation  │                       │
│              │  6. Loop / Finish    │                       │
│              └──────────┬───────────┘                       │
│                         │                                   │
│          ┌──────────────▼──────────────────┐               │
│          │    Agent-Computer Interface      │               │
│          │  ┌──────────┐  ┌─────────────┐  │               │
│          │  │  File    │  │    Bash     │  │               │
│          │  │  Viewer  │  │  Executor   │  │               │
│          │  └──────────┘  └─────────────┘  │               │
│          │  ┌──────────┐  ┌─────────────┐  │               │
│          │  │  File    │  │   Search    │  │               │
│          │  │  Editor  │  │   Tools     │  │               │
│          │  └──────────┘  └─────────────┘  │               │
│          └─────────────────────────────────┘               │
│                         │                                   │
│              ┌──────────▼───────────┐                       │
│              │   Docker Container   │                       │
│              │   (isolated env)     │                       │
│              └──────────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
```

All agent interactions are captured in **trajectory files** — JSON/YAML logs that record every thought, action, and observation. These trajectories are the primary artifact for research analysis.

---

## ⚙️ Core Components & Workflow

### The Agent-Computer Interface (ACI)

The ACI is the defining contribution of SWE-agent. It is a set of purpose-built tools designed specifically for the task of software engineering in a repository. The key insight is that giving an agent **raw bash access is suboptimal** — agents frequently:
- Overwrite files accidentally with `echo` redirections
- Get lost navigating large codebases without line numbers
- Lose track of their position after `cd` commands
- Produce malformed patches that fail to apply
- Run into truncated output from `cat` on large files

The ACI solves each of these failure modes with targeted design decisions.

#### 1. File Viewer

The file viewer displays files with **line numbers** and enforces a **window size** (default 100 lines):

```
[File: /repo/src/parser.py (312 lines total)]
(100 more lines above)
101│ def parse_expression(self, tokens):
102│     """Parse a mathematical expression."""
103│     if not tokens:
104│         raise ParseError("Empty expression")
105│     left = self.parse_term(tokens)
106│     while tokens and tokens[0] in ('+', '-'):
107│         op = tokens.pop(0)
108│         right = self.parse_term(tokens)
...
200│     return result
(112 more lines below)
```

Key design choices:
- **Line numbers**: Agent can reference specific lines in edits and thoughts
- **Window size**: Prevents context overflow on large files; agent scrolls with `scroll_down`/`scroll_up`
- **Truncation indicators**: Explicit `(N more lines above/below)` prevents the agent from thinking it has seen the whole file when it hasn't
- **Current file tracking**: The system always displays what file is currently open and at what line

#### 2. File Editor

The file editor provides surgical, line-based editing instead of full file replacement:

```
edit 103:104
        if not tokens:
            raise ValueError("Empty token list: cannot parse expression")
end_of_edit
```

This replaces lines 103–104 with the specified content. The editor:
- Requires explicit line ranges (prevents accidental overwrites)
- Shows the edited result with surrounding context for verification
- Maintains proper indentation tracking
- Supports `insert` for adding lines without replacing
- Provides `apply_patch` for standard unified diff format

After every edit, the file viewer automatically shows the modified region with context, allowing the agent to verify the change was applied correctly before proceeding.

#### 3. Search Tools

```bash
search_file "parse_expression" /repo/src/parser.py
# → Shows all occurrences with line numbers

search_dir "ParseError" /repo/src
# → Shows all files containing the string

find_file "test_parser.py" /repo
# → Locates files by name pattern
```

These tools prevent the agent from having to pipe `grep` through complex shell commands and handle the output formatting consistently.

#### 4. Bash Executor

The bash executor provides controlled shell access. Key constraints:
- **Timeout**: Commands are killed after a configurable timeout (default 30s)
- **Output truncation**: Long outputs are truncated with a clear message showing byte count
- **State preservation**: Working directory and environment variables persist between commands
- **Exit code reporting**: Always shows the exit code, helping the agent detect failures

### Agent Loop

The SWE-agent agent loop follows a strict **observe → think → act** cycle:

```
1. OBSERVE: Receive the issue description + repository information
   → Construct initial context: system prompt + ACI documentation + issue

2. THINK (LLM call): Model generates a response containing:
   - Reasoning in natural language (the "thought")
   - A structured action call: `tool_name argument`

3. ACT: Parse the action and execute via ACI
   → Get observation (tool output)
   → Append thought + action + observation to trajectory

4. LOOP: Construct next prompt from full trajectory history
   → Go to step 2

5. FINISH: Agent calls `submit` action
   → Collect modified files as a unified diff patch
   → Apply patch to evaluate against test suite
```

The trajectory history grows with each step, eventually hitting the model's context limit. SWE-agent handles this by summarizing older history when the context window approaches capacity.

### Task & Agent Configuration (YAML)

SWE-agent uses a YAML-based configuration system that separates **task specification** from **agent behavior**:

**Task config** (`task_config.yaml`):
```yaml
env:
  repo: "django/django"
  base_commit: "a4bf6f56"
  
task:
  problem_statement: |
    The QuerySet.annotate() method incorrectly handles...
  hints_text: ""
  
eval:
  test_cmd: "python -m pytest tests/annotations/ -x"
  reset_commands:
    - "git clean -fdxq"
```

**Agent config** (`agent_config.yaml`):
```yaml
agent:
  model:
    model_name: gpt-4o
    temperature: 0.0
    top_p: 0.95
    
  templates:
    system_template: "sweagent/agent/templates/system_default.txt"
    instance_template: "sweagent/agent/templates/issue.txt"
    
  tools:
    bundles:
      - path: tools/registry/defaults/submit.yaml
      - path: tools/registry/defaults/bash.yaml
      - path: tools/registry/defaults/editor.yaml
      - path: tools/registry/defaults/search.yaml
    
  max_requeries: 3
  max_iterations: 30
```

This separation allows mixing different task datasets with different agent configurations, enabling systematic ablation studies.

---

## 🔧 Technical Details

### Supported LLM Backends

| Provider | Configuration Key | Notes |
|----------|-------------------|-------|
| OpenAI | `gpt-4o`, `gpt-4-turbo` | Primary evaluation model |
| Anthropic | `claude-3-5-sonnet-20241022` | Strong alternative |
| Ollama | `ollama:llama3.1:8b` | Local, for research/privacy |
| AWS Bedrock | `bedrock:anthropic.claude-3-5-sonnet` | Enterprise deployment |
| Azure OpenAI | `azure:gpt-4o` | Enterprise deployment |
| OpenRouter | Any OpenRouter model | Access to diverse models |

Model selection is purely configuration-driven — no code changes required to switch models.

### Trajectory Format

Trajectories are the primary output artifact of SWE-agent runs. Each trajectory is a JSONL file:

```json
{
  "step": 0,
  "thought": "Let me start by understanding the repository structure...",
  "action": "find_file README.md /repo",
  "observation": "Found: /repo/README.md",
  "state": {
    "open_file": null,
    "working_dir": "/repo"
  }
}
{
  "step": 1,
  "thought": "Now I'll look at the failing test to understand what's expected...",
  "action": "open /repo/tests/test_parser.py 45",
  "observation": "[File: /repo/tests/test_parser.py (120 lines total)]\n45│ def test_empty_expression():\n...",
  "state": {
    "open_file": "/repo/tests/test_parser.py",
    "working_dir": "/repo"
  }
}
```

Trajectories support:
- Full replay of agent sessions
- Quantitative analysis of action distributions
- Identification of common failure patterns
- Comparative studies across agent configurations and models

The SWE-agent team has published large trajectory datasets for community research.

### SWE-agent++ Improvements

SWE-agent++ is an enhanced version that improves upon the baseline with:

1. **Better error recovery**: Automatic detection of common errors (syntax errors, import failures) with targeted recovery prompts
2. **Retry logic**: Failed tool calls are automatically retried with contextual hints
3. **Adaptive context management**: More aggressive summarization of older trajectory steps when approaching context limits
4. **Improved templates**: Refined system prompts based on trajectory analysis of common failure modes

### Docker Integration

Like OpenHands, SWE-agent runs all code in Docker containers. The container setup:

```
Image: sweagent/swe-agent:latest (or custom)
├── Python 3.10+
├── Git
├── Repository cloned at /repo
├── Test dependencies installed
└── ACI tools available as shell commands
```

Containers are ephemeral per task, ensuring clean state for each evaluation.

---

## 📊 Performance & Benchmarks

### SWE-Bench Results

| Configuration | SWE-Bench Lite (300) | SWE-Bench Full (2294) | SWE-Bench Verified (500) |
|---------------|---------------------|----------------------|--------------------------|
| SWE-agent + GPT-4 (original paper) | 15.0% | 12.5% | N/A |
| SWE-agent + GPT-4o | 18.3% | 15.2% | ~18% |
| SWE-agent + Claude 3.5 Sonnet | 21.0% | 17.8% | ~22% |
| SWE-agent++ + GPT-4o | 22.7% | 19.1% | ~24% |

These scores were competitive at the time of publication (early-mid 2024) but have since been surpassed by systems like OpenHands, AutoCodeRover, and Agentless that leverage more sophisticated strategies.

### Ablation Studies from the Paper

The NeurIPS 2024 paper includes extensive ablation studies demonstrating the value of ACI components:

| Configuration | SWE-Bench Lite Score |
|---------------|---------------------|
| Raw bash only (no ACI) | 3.8% |
| + Line-numbered file viewer | 8.2% |
| + File editor (vs raw write) | 12.1% |
| + Search tools | 14.3% |
| + State tracking | 15.0% |
| Full ACI (all components) | 15.0% |

This progression validates the paper's central thesis: each ACI component makes a measurable contribution.

### Trajectory Analysis Findings

Analysis of trajectory datasets reveals:
- **Average steps per task**: 16–24 steps
- **Most common failure mode**: Giving up after repeated test failures without trying alternative approaches
- **Most productive action type**: `search_dir` + targeted `edit` sequences
- **Context overflow frequency**: ~15% of tasks hit the context limit before solving

---

## ✅ Strengths

1. **Rigorous research methodology**: YAML-based reproducible configs, trajectory logging, and NeurIPS publication make SWE-agent a gold standard research baseline.

2. **ACI design principles**: The paper clearly articulates why each ACI component exists, providing a framework for thinking about agent-tool interface design applicable beyond just software engineering.

3. **Ablation evidence**: Unlike many agent systems, SWE-agent comes with careful ablation studies proving which components matter.

4. **Trajectory ecosystem**: The trajectory format and published datasets enable community research into agent behavior without re-running expensive evaluations.

5. **Configurability**: The YAML system allows systematic experiments — comparing models, prompt templates, tool subsets, and task formats without code changes.

6. **Low barrier to entry**: Relatively simple architecture makes it easier to understand, modify, and extend than more complex systems.

7. **Multi-LLM**: Works with any major LLM provider out of the box.

8. **Strong documentation**: Clear README, paper, and example configurations reduce time-to-first-run.

9. **Active maintenance**: Princeton NLP continues to develop the system with community contributions.

10. **Failure mode prevention**: The ACI's specific design choices (window size, line numbers, structured editor) demonstrably reduce the most common agent mistakes.

---

## ⚠️ Limitations

1. **Lower absolute performance**: At 18–22% on SWE-Bench, SWE-agent is significantly outperformed by OpenHands (72%), AutoCodeRover (~22%), and other systems. It excels as a research baseline, not a production coding assistant.

2. **Fixed action space**: The ACI's strength (controlled interface) is also a limitation — complex tasks may require operations outside the predefined toolset. Adding new tools requires configuration changes.

3. **No parallel execution**: SWE-agent operates sequentially — one action at a time. It cannot parallelize exploration of multiple solution hypotheses.

4. **Context window growth**: The trajectory-as-context approach means token costs grow linearly with task complexity. Very long tasks become expensive and may hit limits.

5. **Limited browser support**: Unlike OpenHands, SWE-agent does not natively support web browsing, limiting tasks that require downloading documentation or accessing external services.

6. **Research-oriented UX**: No polished web UI or production-ready API — primarily designed for research use via CLI.

7. **Single-agent only**: No native multi-agent orchestration; complex tasks requiring specialized sub-agents (e.g., a testing agent, a documentation agent) must be handled within a single agent session.

8. **No memory across sessions**: Each task starts fresh with no memory of previous runs or accumulated project knowledge.

9. **Benchmark-task bias**: SWE-agent is heavily optimized for SWE-Bench-style tasks (fix a bug given an issue). Real-world tasks may be more open-ended and less well-specified.

10. **Docker requirement**: As with OpenHands, Docker is required, adding operational overhead.

---

## 🔗 Related Work

- **OpenHands** (All-Hands AI, 2024): Broader platform with higher SWE-Bench scores; code-as-action approach vs. ACI's structured tools.
- **Agentless** (Xia et al., 2024): Demonstrates that simpler, non-agentic approaches can be competitive; useful foil for understanding when agent complexity is justified.
- **AutoCodeRover** (Zhang et al., 2024): Uses program analysis (ASTs, call graphs) for code navigation instead of ACI-style text search.
- **CodeR** (Chen et al., 2024): Multi-agent system with specialized roles; achieves higher scores by distributing the task.
- **Moatless Tools** (Community): Alternative ACI implementation with different tool design choices.
- **RepoGraph** (Ouyang et al., 2024): Augments SWE-agent with a graph-based code navigation tool.
- **ACI Design Paper** (Yang et al., 2024): The NeurIPS paper itself; contains the most comprehensive analysis of ACI design principles.
- **SWE-bench** (Jimenez et al., 2024): The benchmark that SWE-agent is designed to solve and is widely used to evaluate.
- **Aider** (Gauthier, 2023): Developer-facing coding assistant with different interface philosophy (human-in-the-loop vs autonomous).
- **LangChain Agents**: General-purpose agent framework; less specialized than SWE-agent's ACI for software engineering.

---

## 📎 References

1. Yang, J., et al. (2024). "SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering." *Advances in Neural Information Processing Systems (NeurIPS 2024)*.
2. Jimenez, C. E., et al. (2024). "SWE-bench: Can Language Models Resolve Real-World GitHub Issues?" *International Conference on Learning Representations (ICLR 2024)*.
3. Xia, C. S., et al. (2024). "Agentless: Demystifying LLM-based Software Engineering Agents." *arXiv preprint arXiv:2407.01489*.
4. Zhang, Y., et al. (2024). "AutoCodeRover: Autonomous Program Improvement." *Proceedings of the 33rd ACM SIGSOFT International Symposium on Software Testing and Analysis (ISSTA 2024)*.
5. Wang, X., et al. (2024). "OpenDevin: An Open Platform for AI Software Developers as Generalist Agents." *arXiv preprint arXiv:2407.16741*.
6. Chen, J., et al. (2024). "CodeR: Issue Resolving with Multi-Agent and Task Graphs." *arXiv preprint arXiv:2406.01304*.
7. Ouyang, S., et al. (2024). "RepoGraph: Enhancing AI Software Engineering with Repository-level Code Graph." *arXiv preprint arXiv:2410.14684*.
8. Princeton NLP. (2024). "SWE-agent Documentation and Trajectory Datasets." https://swe-agent.com/
9. OpenAI. (2024). "GPT-4o System Card." https://openai.com/index/gpt-4o-system-card/
10. Anthropic. (2024). "Claude 3.5 Sonnet Model Card." https://www.anthropic.com/claude/sonnet
