# OpenHands (formerly OpenDevin)
> An AI-driven software development platform providing composable autonomous coding agents that can edit files, execute terminal commands, browse the web, and interact with external services — achieving 72% on SWE-Bench Verified.

---

## 📌 Project Overview

**Repository:** https://github.com/All-Hands-AI/OpenHands  
**Organization:** All-Hands AI  
**License:** MIT  
**Language:** Python (backend), TypeScript/React (frontend)  
**First Release:** March 2024 (as OpenDevin); rebranded to OpenHands in August 2024

OpenHands is one of the most capable and widely deployed open-source autonomous software engineering platforms available. Originally launched under the name **OpenDevin** by a community of researchers, the project was quickly adopted by All-Hands AI, which now maintains and develops it as a full product. The platform provides a composable Python library of autonomous coding agents, backed by a rich runtime environment, a sandboxed Docker-based execution layer, and a polished web UI.

At its core, OpenHands enables LLM-powered agents to act like human software developers: reading and writing files, running shell commands, executing Python scripts, navigating web pages, and interacting with GitHub and other services. The flagship agent — **CodeActAgent** — has achieved **72% on SWE-Bench Verified**, placing it among the highest-performing systems on this authoritative benchmark for autonomous bug fixing.

Unlike narrow code-generation tools, OpenHands is designed for **long-horizon agentic tasks** — tasks that require multiple interleaved planning, execution, and correction steps over minutes or hours, not just single-shot code completions.

---

## 🎯 Project Positioning

OpenHands targets three distinct audiences:

1. **Researchers** building new agent architectures or benchmarking autonomous coding systems. The modular agent API makes it easy to swap planners, tools, and runtimes.
2. **Developers** who want AI assistance for complex, multi-file software engineering tasks — beyond what autocomplete or chat-based tools offer.
3. **Organizations** looking to automate routine software tasks like PR triage, bug fixing, dependency upgrades, and test generation via its REST API and GitHub integration.

**Compared to competing systems:**
- vs. **SWE-agent**: OpenHands is more flexible (multiple agent types, richer tool ecosystem) but less "controlled" — the ACI philosophy of SWE-agent enforces stricter interface discipline.
- vs. **Aider**: Aider is a developer-facing CLI tool optimized for human-in-the-loop coding; OpenHands is built for fully autonomous, unattended operation.
- vs. **Devin (Cognition AI)**: Devin is closed-source and proprietary; OpenHands is the closest open-source equivalent, often described as "the open-source Devin."
- vs. **GitHub Copilot Workspace**: OpenHands operates with greater autonomy and can run arbitrary code, whereas Copilot Workspace is more tightly scoped to GitHub repository changes.

---

## 🏗️ System Architecture

OpenHands is built around a central **event stream** paradigm. All interactions between the agent, the user, and the runtime are expressed as typed events that flow through a shared bus.

```
┌─────────────────────────────────────────────────────────────┐
│                        OpenHands Platform                   │
│                                                             │
│  ┌──────────┐    ┌─────────────┐    ┌──────────────────┐  │
│  │  Web UI  │    │  REST API   │    │   CLI Interface  │  │
│  └────┬─────┘    └──────┬──────┘    └────────┬─────────┘  │
│       └─────────────────┼─────────────────────┘            │
│                         │                                   │
│                   ┌─────▼──────┐                           │
│                   │  Controller │  (orchestrates events)   │
│                   └─────┬──────┘                           │
│                         │  EventStream                      │
│          ┌──────────────┼──────────────┐                   │
│          │              │              │                    │
│    ┌─────▼─────┐  ┌─────▼─────┐  ┌───▼──────┐           │
│    │   Agent   │  │  Runtime  │  │  Memory  │            │
│    │(CodeAct,  │  │ (Docker)  │  │  Store   │            │
│    │ Browser,  │  │           │  │          │            │
│    │  etc.)    │  │ - bash    │  │ - files  │            │
│    └───────────┘  │ - Python  │  │ - history│            │
│                   │ - browser │  └──────────┘            │
│                   └───────────┘                           │
└─────────────────────────────────────────────────────────────┘
```

### Event Stream Model

The **EventStream** is the architectural heart of OpenHands. Every action taken by the agent and every observation received from the environment is logged as a structured event on this stream.

**Action events** (agent → runtime):
```python
class CmdRunAction(Action):
    command: str          # e.g. "pytest tests/ -v"
    timeout: int          # seconds before kill
    thought: str          # agent's reasoning (optional)

class FileWriteAction(Action):
    path: str
    content: str
    thought: str

class BrowseURLAction(Action):
    url: str

class AgentFinishAction(Action):
    outputs: dict
    thought: str
```

**Observation events** (runtime → agent):
```python
class CmdOutputObservation(Observation):
    command: str
    content: str          # stdout + stderr
    exit_code: int

class FileReadObservation(Observation):
    path: str
    content: str

class BrowserOutputObservation(Observation):
    url: str
    screenshot: str       # base64 PNG
    dom: str              # accessibility tree
```

Events are stored in an append-only log, giving the system full replay capability. The Controller reads from this stream and dispatches to the appropriate handler — either the Agent (for observations) or the Runtime (for actions).

---

## ⚙️ Core Components & Workflow

### Agent Types

OpenHands ships with several agent implementations, each optimized for different tasks:

| Agent | Primary Use | Action Space |
|-------|------------|--------------|
| `CodeActAgent` | General software engineering | Code execution (Python + bash via subprocess) |
| `BrowserAgent` | Web-based tasks | Browser actions (click, type, navigate) |
| `DelegatorAgent` | Multi-agent orchestration | Spawning and directing sub-agents |
| `ManagerAgent` | Long-horizon planning | Task decomposition + delegation |

### CodeActAgent Deep Dive

CodeActAgent is the flagship agent and the one responsible for the 72% SWE-Bench score. Its key insight is **code-as-action**: instead of having specialized tools for file editing, bash execution, etc., the agent writes Python code that performs those operations, and the runtime executes it.

**Why code-as-action?**
- Python is expressive: any file operation, API call, or system interaction can be expressed as Python.
- The agent already "speaks" Python fluently from pretraining.
- Error messages from failed code give the agent rich feedback for self-correction.
- It avoids the need to define a fixed tool schema — the tool space is essentially infinite.

**CodeActAgent inner loop:**
```
1. Receive observations (initial task + any runtime output)
2. Build prompt: system prompt + conversation history + current observations
3. Call LLM → get response containing:
   a. <thought> block: agent's reasoning
   b. <execute_ipython> block: Python code to run, OR
   c. <execute_bash> block: bash command to run, OR
   d. <finish> signal: task complete
4. Parse response → create Action event
5. Runtime executes action → creates Observation event
6. Loop until finish or max_iterations
```

The agent can perform multi-step plans: write a script, run it, check output, fix errors, re-run, and ultimately produce a working solution — all autonomously.

### Runtime & Sandbox

The Runtime is an isolated execution environment backed by **Docker**. Each session gets a fresh container with:
- A Debian-based OS image
- Python, Node.js, and common development tools pre-installed
- The user's repository mounted (or cloned) into the container
- Restricted network access (configurable)
- A persistent IPython kernel for stateful code execution

The IPython kernel is particularly important: unlike running bare Python scripts, the kernel preserves state between executions. Variables, imports, and file handles persist across multiple `<execute_ipython>` blocks, allowing the agent to build up context incrementally.

**Runtime lifecycle:**
```
Session start → Docker container created
    → IPython kernel started inside container
    → Git repo cloned or mounted
    → Agent begins task
        → Actions dispatched to container via API
        → Observations returned to agent
    → Session end → Container destroyed (ephemeral)
```

For persistent deployments, container state can be checkpointed and resumed.

### Microagent System

The **microagent** system injects specialized knowledge into the agent's context based on what it detects in the repository. Microagents are small knowledge units — essentially structured prompts — that get activated when certain triggers are detected:

```yaml
# Example microagent: knows how to use pytest
name: pytest_expert
triggers:
  - file_pattern: "pytest.ini"
  - file_pattern: "conftest.py"
  - import_detected: "pytest"
knowledge: |
  This project uses pytest. When running tests:
  - Use `pytest tests/ -v` for verbose output
  - Use `-x` to stop on first failure
  - Check `conftest.py` for fixtures
  - Coverage: `pytest --cov=src tests/`
```

When the agent's working repository contains a `pytest.ini`, the pytest microagent's knowledge is injected into the system prompt. This prevents the agent from wasting tokens on trial-and-error discovery of project conventions.

Built-in microagents cover: React/Next.js, Django, Flask, Docker, GitHub Actions, TypeScript/ESLint, Poetry/pip, and more. Users can define custom microagents for their specific tech stack.

---

## 🔧 Technical Details

### LLM Integration via LiteLLM

OpenHands uses [LiteLLM](https://github.com/BerriAI/litellm) as a universal LLM adapter, enabling support for nearly any language model:

| Provider | Models |
|----------|--------|
| Anthropic | Claude 3.5 Sonnet, Claude 3 Opus (primary recommended) |
| OpenAI | GPT-4o, GPT-4 Turbo, o1/o3 |
| MiniMax | abab6.5s |
| Google | Gemini 1.5 Pro/Flash |
| Ollama | Any local model |
| Azure OpenAI | Any Azure-deployed model |
| AWS Bedrock | Claude via Bedrock |

The primary recommended model is **Anthropic Claude 3.5 Sonnet**, which offers the best balance of code quality, instruction following, and context length for long agentic tasks. The SWE-Bench 72% result was achieved with Claude.

### GitHub Integration

OpenHands can be deployed as a **GitHub App** that responds to issue comments and pull request events:

```
User comments on GitHub Issue:
  "@openhands-agent Fix the failing tests in test_parser.py"

OpenHands receives webhook → creates agent session → clones repo
    → agent fixes tests → opens Pull Request
    → links PR to original issue
```

The GitHub integration supports:
- Cloning repositories (public + private with token)
- Creating branches
- Committing changes
- Opening pull requests with descriptive messages
- Posting status updates back to issues/PRs

### REST API

The OpenHands REST API allows programmatic control:

```http
POST /api/conversations
{
  "github_token": "...",
  "selected_repository": "owner/repo"
}
→ { "conversation_id": "conv_abc123" }

POST /api/conversations/{id}/messages
{
  "content": "Fix the bug in src/parser.py line 42",
  "image_urls": []
}

GET /api/conversations/{id}/events
→ Stream of SSE events (actions + observations in real-time)
```

### Web UI Features

The OpenHands web UI provides:
- **Chat interface**: Natural language task specification
- **File browser**: Live view of files the agent creates/modifies
- **Terminal output**: Real-time stream of bash/Python execution output
- **Browser view**: Live screenshot stream when the agent browses the web
- **Settings panel**: LLM selection, API key management, agent type selection
- **Session history**: Browse and replay past agent sessions

---

## 📊 Performance & Benchmarks

### SWE-Bench Verified (Primary Benchmark)

SWE-Bench Verified is a curated subset of 500 real GitHub issues from popular Python repositories (Django, scikit-learn, sympy, etc.), verified by human annotators to be solvable from the issue description alone.

| System | Score | Notes |
|--------|-------|-------|
| **OpenHands + Claude 3.5 Sonnet** | **72.0%** | State-of-the-art open-source |
| Devin 2.0 (Cognition, proprietary) | ~55% | Closed-source |
| SWE-agent + GPT-4o | ~18% | Research baseline |
| AutoCodeRover + GPT-4o | ~22% | Research system |
| Aider + Claude 3.5 Sonnet | ~18% | Developer tool |

The 72% result places OpenHands at or near the top of all published systems, open or closed source, as of 2024.

**Key factors enabling high performance:**
1. **Claude 3.5 Sonnet**: Excellent at following complex multi-step instructions and generating correct Python code
2. **CodeActAgent's iterative execution**: The agent can run tests, see failures, and fix them — mimicking a real developer's workflow
3. **IPython kernel persistence**: State accumulates across steps, enabling complex multi-file refactoring
4. **Microagent knowledge**: Correct pytest/unittest invocations without trial-and-error

### SWE-Bench Full (Harder)

The full SWE-Bench dataset contains 2,294 tasks without human verification. OpenHands scores approximately **40-45%** on this set, still highly competitive.

### Resource Usage

Typical task resource consumption:
- **Average task duration**: 5–25 minutes (depends on complexity)
- **Average LLM calls per task**: 15–40 turns
- **Average tokens per task**: 80K–300K input + 10K–50K output
- **Docker memory**: ~2–4 GB per container
- **Concurrent sessions**: Limited by available Docker resources

---

## ✅ Strengths

1. **State-of-the-art benchmark performance**: 72% on SWE-Bench Verified is the highest published score for an open-source system, validating the approach.

2. **Code-as-action generality**: The CodeActAgent paradigm avoids the need for brittle tool schemas — any operation expressible in Python is available to the agent.

3. **Rich observability**: The event stream architecture makes it easy to inspect exactly what the agent did and why, enabling debugging and analysis.

4. **Extensible agent framework**: New agent types can be created by implementing a small Python interface. The Controller, Runtime, and EventStream are reusable infrastructure.

5. **Microagent knowledge injection**: Project-specific knowledge is automatically injected based on detected tech stack, reducing hallucination and improving task success rates.

6. **Production-ready features**: Web UI, REST API, GitHub App integration, and Docker sandboxing make OpenHands suitable for real-world deployment, not just research.

7. **Multi-LLM support**: LiteLLM integration means organizations can use their preferred LLM provider without forking the codebase.

8. **Active development and community**: Backed by All-Hands AI with a large open-source community contributing new features, agents, and microagents.

9. **Full isolation**: Docker-based sandboxing ensures agent actions cannot affect the host system, making it safe to run untrusted agent-generated code.

10. **Replay capability**: The append-only event log enables full session replay for debugging and research.

---

## ⚠️ Limitations

1. **Cost**: Long agentic tasks with Claude 3.5 Sonnet can cost $1–$10+ per task in API fees, making large-scale deployment expensive.

2. **Latency**: Average task duration of 5–25 minutes is too slow for interactive development workflows. OpenHands is better suited for background/async tasks.

3. **Docker dependency**: The runtime requires Docker, which adds operational complexity and may not be available in all deployment environments (e.g., some cloud functions, restricted environments).

4. **Context window limitations**: Very large codebases can exhaust the LLM's context window. The agent must summarize or selectively load files, which can lead to missing relevant code.

5. **Non-determinism**: Agent behavior is stochastic. The same task may succeed in one run and fail in another, depending on LLM sampling randomness.

6. **Limited multi-repository support**: Tasks that require coordinating changes across multiple repositories are not natively supported.

7. **No formal verification**: The agent cannot formally verify its solutions — it can run tests but cannot prove correctness in a mathematical sense.

8. **Browser automation fragility**: Web browsing via screenshot analysis is slow and fragile compared to structured APIs. JavaScript-heavy sites may cause failures.

9. **Security surface**: While Docker provides isolation, container escape vulnerabilities or misconfiguration could expose the host. Careful configuration is required for multi-tenant deployments.

10. **Benchmark vs. real-world gap**: SWE-Bench tasks are well-specified GitHub issues with clear acceptance criteria. Real-world tasks are often under-specified, requiring more human interaction.

---

## 🔗 Related Work

- **SWE-agent** (Princeton NLP, 2024): Introduced the Agent-Computer Interface (ACI) concept; strong research baseline; more controlled than OpenHands.
- **Aider** (Paul Gauthier): Developer-facing CLI tool for code editing; less autonomous but faster for interactive use.
- **Devin** (Cognition AI, 2024): Proprietary autonomous software engineer; inspired OpenHands' development.
- **AgentCoder** (Huang et al., 2023): Early work on using LLMs as coding agents with execution feedback.
- **InterCode** (Yang et al., 2023): Benchmark for interactive code generation with execution feedback.
- **CodeR** (Chen et al., 2024): Agent system combining issue reproduction with code fixing.
- **AutoCodeRover** (Zhang et al., 2024): Uses program analysis to identify relevant code before LLM-based fixing.
- **Agentless** (Xia et al., 2024): Surprisingly competitive system that avoids complex agent loops; demonstrates the value of careful prompt engineering.
- **LangChain/LangGraph**: Infrastructure for building LLM pipelines; OpenHands uses neither, preferring its own event stream architecture.
- **OpenAI Codex/GPT-4**: The foundation LLMs powering many of these systems.

---

## 📎 References

1. Wang, X., et al. (2024). "OpenDevin: An Open Platform for AI Software Developers as Generalist Agents." *arXiv preprint arXiv:2407.16741*.
2. Jimenez, C. E., et al. (2024). "SWE-bench: Can Language Models Resolve Real-World GitHub Issues?" *ICLR 2024*.
3. Jimenez, C. E., et al. (2024). "SWE-bench Verified." OpenAI Blog Post.
4. Yang, J., et al. (2024). "SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering." *NeurIPS 2024*.
5. Xia, C. S., et al. (2024). "Agentless: Demystifying LLM-based Software Engineering Agents." *arXiv preprint arXiv:2407.01489*.
6. Zhang, Y., et al. (2024). "AutoCodeRover: Autonomous Program Improvement." *arXiv preprint arXiv:2404.05427*.
7. All-Hands AI. (2024). "OpenHands Documentation." https://docs.all-hands.dev/
8. BerriAI. (2023). "LiteLLM: Call 100+ LLMs using OpenAI format." https://github.com/BerriAI/litellm
9. Anthropic. (2024). "Claude 3.5 Sonnet Model Card." https://www.anthropic.com/
10. Chen, J., et al. (2024). "CodeR: Issue Resolving with Multi-Agent and Task Graphs." *arXiv preprint arXiv:2406.01304*.
