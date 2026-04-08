# Aider

> AI pair programming in the terminal with native Git integration, supporting 60+ LLM backends and delivering ~18% on SWE-Bench full.

## Overview

Aider is an open-source, command-line AI pair programming tool created by Paul Gauthier and maintained by Aider-AI since 2023.
With over 43,000 GitHub stars it is the most widely adopted AI coding CLI in the world.
Unlike IDE plugins, Aider runs entirely in the terminal and integrates directly with Git: every accepted change is committed atomically, preserving a clean repository history.
Users describe their intent in natural language; Aider calls the chosen LLM, receives proposed edits, and applies them using one of several edit formats.

Aider is not a research automation framework in the traditional sense.
It is a code agent that researchers use to run experiments, iterate on implementations, and maintain reproducible codebases.
Several research automation systems — including AI-Scientist-v2 (via AIDE) and Agent Laboratory — delegate code generation sub-tasks to Aider-like architectures.
Understanding Aider is therefore essential context for the broader ecosystem.

The tool is designed for developers who want to stay in a terminal workflow.
It works with any programming language (Python, TypeScript, Go, Rust, Java, C/C++, and more) and any Git repository.
The repository map feature uses tree-sitter parsing to give the LLM a compact, navigable view of the entire codebase.

## Architecture

Aider follows a single-session chat architecture layered over any LLM API.
The key components work together to maintain context, apply edits, and commit changes:

```
User (terminal) ──► Aider CLI
                        │
                        ├─ Chat history manager
                        ├─ Repository map (tree-sitter based symbol extraction)
                        ├─ Context window optimizer (PageRank-like ranking)
                        ├─ Edit format selector
                        │       ├─ whole  (replace entire file)
                        │       ├─ diff   (unified diff patches)
                        │       ├─ udiff  (improved diff format)
                        │       └─ architect (high-level plan → diff, two models)
                        ├─ LLM client (litellm router supporting 60+ providers)
                        └─ Git integration (gitpython, atomic commits)
```

The **repository map** is the architectural centrepiece of Aider.
Aider uses tree-sitter to parse every file in the repository, extract all symbols (function names, class definitions, type signatures), and build a compact map that fits within the context window.
This lets the model reason about the whole codebase without ingesting every line, which is critical for large repositories.

The **architect mode** introduces a two-model pipeline where a reasoning-capable "architect" model designs the solution at a high level, and a cheaper "editor" model applies the resulting diff.
This separation reduces cost while preserving quality for complex refactors.

## Core Workflow

1. **Session start** — user runs `aider` or `aider <files>` in their project directory.
2. **File selection** — user adds specific files to the editing context with `/add path/to/file.py`.
3. **Natural language request** — user describes what to change in plain English.
4. **Repository map injection** — Aider injects a token-efficient outline of all symbols plus the full text of added files into the prompt.
5. **LLM call** — Aider sends the prompt to the configured model via LiteLLM.
6. **Response parsing** — Aider parses the response using the configured edit format's parser.
7. **Diff preview** — proposed changes are shown to the user as a coloured diff.
8. **Confirmation** — user accepts (or use `--yes` for automatic acceptance).
9. **Git commit** — accepted changes are committed with an AI-generated commit message.
10. **Iterate** — user continues the conversation, asking for refinements or new features.
11. **Test/lint loop** — optionally, Aider runs tests or linters and feeds failures back to the model.

## Key Features

### Multi-model Support
Aider supports over 60 LLM backends via LiteLLM.
Supported providers include OpenAI (GPT-4o, o1, o3), Anthropic (Claude 3.5 / 3.7 Sonnet, Opus), Google Gemini (1.5 Pro, 2.0 Flash), DeepSeek, Mistral, Groq, Ollama (local), Azure OpenAI, AWS Bedrock, and any OpenAI-compatible endpoint.
A simple `--model` flag switches the entire pipeline with no code changes.

### Voice Coding
The `--voice` flag enables speech-to-text input via faster-whisper or OpenAI Whisper.
Users can dictate code changes hands-free while looking at the screen — useful during long debugging sessions.

### Auto-commit with AI Messages
Every accepted change creates a Git commit with a descriptive AI-generated message following conventional commit style.
This preserves an auditable history and enables easy rollback with `git revert`.

### Linter and Test Integration
Aider can be configured to run your test suite or linter after each change.
If tests fail, the output is automatically fed back to the model as context for a correction loop.
This implements a lightweight version of TDD without external tooling.

### Browser GUI
`aider --browser` opens a web interface served locally.
This is useful for remote SSH sessions where terminal colour support may be limited.

### Scripting and Automation
`aider --yes --message "add unit tests for auth module"` runs headlessly.
This enables integration into CI/CD pipelines and automated research loops where Aider handles implementation while another system handles orchestration.

## Technical Implementation

### Repository Map (tree-sitter)

The repo map uses tree-sitter grammars for 60+ languages to extract symbol tables.
Extracted symbols include function signatures, class definitions, constants, and type aliases.
It then applies a PageRank-style ranking to prioritise symbols most relevant to the current conversation.
The result is a compact, navigable outline that fits within the context window even for repositories with thousands of files.
The map is regenerated for every message so it remains accurate after edits.

### Edit Formats

Aider supports four edit formats that trade off reliability against token efficiency:

| Format | Description | Best for |
|--------|-------------|----------|
| `whole` | LLM returns entire file content | High reliability, small files |
| `diff` | Unified diff hunks | Balanced; default for most models |
| `udiff` | Extended unified diff | Models with strong diff adherence |
| `architect` | Two-step: plan + apply | Large refactors, complex changes |

The format is selected automatically based on the model being used, but can be overridden.
Models that are unreliable at generating valid diffs fall back to `whole` automatically.

### LLM Routing (LiteLLM)

Aider delegates all API calls to LiteLLM, which normalises provider-specific APIs into a single interface.
This means switching from GPT-4o to Claude 3.7 Sonnet to a local Llama model requires only a `--model` flag change.
LiteLLM handles authentication, retry logic, streaming, and cost estimation.

### Git Integration

Every change is committed via gitpython.
Aider tracks which files it modified and never touches files outside the declared context set.
The commit message is generated by the LLM using a short summarisation prompt.
Aider tags commits with `[aider]` in the message for easy filtering in `git log`.

### Context Management

Aider manages the conversation window carefully to avoid context overflow.
Old messages are summarised automatically when the window approaches the model's limit.
The repo map is regenerated at each turn to reflect the current state of the codebase.
Files added to the context are inlined in full; files in the repo map are shown as symbol outlines only.

## Evaluation & Benchmarks

Aider maintains a public **coding leaderboard** at `aider.chat/docs/leaderboards/` measuring edit quality across multiple models and tasks.

### SWE-Bench (Full)
- Aider with GPT-4o: ~18.9% task resolution on the full benchmark
- Aider with Claude 3.5 Sonnet: ~26% on SWE-Bench Verified subset
- Measured using the polyglot SWE-Bench subset (Python, JS, TypeScript, Ruby, Go, Java, C, C++)
- SWE-Bench full is harder than SWE-Bench Verified (which uses human-verified, unambiguous tasks)

### Polyglot Coding Benchmark
- Tests code editing ability across multi-language exercises
- Different from SWE-Bench: focuses on correct edit application rather than issue resolution end-to-end
- Results are published per model, enabling researchers to compare LLM code editing quality
- As of early 2025, Claude 3.7 Sonnet topped the leaderboard for most editing tasks

### Context
SWE-Bench performance reflects Aider's role as an interactive tool guided by human instructions.
Fully autonomous pipelines like SWE-agent use similar edit mechanisms but add planning layers.
Aider is competitive for interactive use cases and serves as a benchmark baseline for the community.

## Strengths

- **Broadest model compatibility** — 60+ LLM backends; one tool for all providers and use cases.
- **Git-native workflow** — atomic commits after every change maintain reproducible, auditable codebases critical for research.
- **Transparent edits** — diffs are always shown before application; no surprise code injection.
- **Speed of iteration** — sub-second response loops with streaming; faster than IDE plugins for expert users.
- **Local model support** — full Ollama integration enables offline operation for sensitive research environments.
- **Active maintenance** — daily releases from an active maintainer; extensive documentation; quick bug turnaround.
- **Scripting** — headless `--yes` mode enables integration into automated research experiment runners.
- **Voice coding** — unique dictation feature reduces cognitive load during long coding sessions.
- **Test/lint feedback loop** — automatic failure re-injection implements TDD without external tooling.

## Limitations

- **Not a research automation framework** — Aider does not manage experiment tracking, literature search, or paper generation. It is a coding substrate on which research agents may be built, not a full pipeline.
- **No built-in planning** — unlike SWE-agent or OpenHands, Aider does not decompose a high-level task into sub-steps autonomously. Users must direct the agent turn by turn.
- **No sandboxing** — code executes in the user's environment without containerisation. Destructive or network-calling experiments run with full user permissions.
- **Context window ceiling** — repo maps are effective but very large monorepos (>10k files) can still produce noisy or incomplete maps that confuse the model.
- **Edit format failures** — models sometimes produce malformed diffs, especially for complex multi-file changes. The retry logic helps but is not foolproof.
- **Cost accumulation** — architect mode doubles API calls per change; interactive sessions with frontier models accumulate cost quickly for large refactors.
- **Quality gap for local models** — Ollama integration is excellent but local model quality lags frontier models significantly for complex edits, limiting fully private deployments.

## Related Work

- **SWE-agent** (Princeton NLP) — structured agent-computer interface for repository-level issue resolution; more autonomous but less interactive than Aider.
- **OpenHands** (All-Hands-AI) — production-grade agent with Docker sandboxing; targets fully autonomous task completion with 72% SWE-Bench Verified.
- **AIDE (WecoAI)** — tree-search over ML solution space using Aider-like code editing; used internally by AI-Scientist-v2 for experiment generation.
- **GitHub Copilot / Cursor** — IDE-embedded code completion with different interaction model; not terminal-first or Git-commit-focused.
- **Devin** (Cognition) — fully autonomous software engineering agent with its own browser, terminal, and planning; higher autonomy, lower interactivity than Aider.

## References

1. Gauthier, P. (2023). *Aider: AI Pair Programming in Your Terminal*. https://github.com/Aider-AI/aider
2. Aider documentation. https://aider.chat/docs/
3. Aider Coding Leaderboards. https://aider.chat/docs/leaderboards/
4. Yang, J. et al. (2024). *SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering*. arXiv:2405.15793.
5. Jimenez, C. E. et al. (2024). *SWE-Bench: Can Language Models Resolve Real-World GitHub Issues?* ICLR 2024.
6. Chen, M. et al. (2024). *LiteLLM: Unified LLM API*. https://github.com/BerriAI/litellm
7. Wang, X. et al. (2024). *OpenHands: An Open Platform for AI Software Developers as Generalist Agents*. arXiv:2407.16741.
8. Aider GitHub star history: https://star-history.com/#Aider-AI/aider
9. faster-whisper: https://github.com/SYSTRAN/faster-whisper
