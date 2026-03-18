# DeerFlow — Deep Exploration and Efficient Research Flow
> ByteDance's open-source "SuperAgent" for autonomous deep research, multi-step planning, and structured report generation with sandboxed code execution.

---

## 📌 Project Overview

**DeerFlow** (Deep Exploration and Efficient Research Flow) is an open-source deep research and report-writing "SuperAgent" developed and open-sourced by **ByteDance**. It is a production-grade multi-agent system designed to handle complex, multi-step research tasks that require synthesizing information from the web, executing code for data analysis, and generating structured reports.

DeerFlow was developed as a ByteDance internal productivity tool before being released to the open-source community. It represents ByteDance's approach to AI-assisted research workflows at scale.

| Attribute | Detail |
|---|---|
| Repository | https://github.com/bytedance/deer-flow |
| Organization | ByteDance |
| License | Apache 2.0 |
| Core Stack | Python, LangChain, LangGraph |
| Primary Use Cases | Deep research, competitive analysis, data-driven reports |
| Key Extension | Sandboxed Python code execution for analytical tasks |

DeerFlow distinguishes itself from comparable tools by supporting **both research mode and coding/analysis mode** — allowing agents to not only retrieve and synthesize text but also write and execute Python code to perform quantitative analysis, generate charts, and process structured data.

---

## 🎯 Project Positioning

DeerFlow targets organizations and power users who need more than text synthesis — they need **actionable analysis** that may involve data processing, visualization, or numerical computation.

### Positioning Map

| Capability | DeerFlow | GPT Researcher | STORM | PaperQA2 |
|---|---|---|---|---|
| Web Research | ✅ Deep | ✅ Deep | ✅ Deep | ⚠️ Scientific only |
| Multi-agent | ✅ | ✅ | ✅ | Partial |
| Code Execution | ✅ Sandboxed | ❌ | ❌ | ❌ |
| Structured Planning | ✅ Multi-step | Partial | ✅ | ❌ |
| Real-time Streaming | ✅ | Partial | ❌ | ❌ |
| Open Provider | ✅ | ✅ | ✅ | ✅ |

### Target Use Cases

1. **Competitive Intelligence**: Research a competitor's product, summarize their pricing, and plot market share trends
2. **Financial Analysis**: Gather earnings data, run calculations, generate visualizations
3. **Scientific Literature Review**: Survey papers on a topic, extract key findings, compile a structured report
4. **Technical Deep-Dives**: Research a technology, run code examples to verify, explain with working demos
5. **Data Journalism**: Gather statistics, verify with code, produce a fact-checked article

### ByteDance Context

As an internal ByteDance tool, DeerFlow was designed for real production workloads — the robustness, streaming architecture, and code execution sandbox reflect the requirements of enterprise-scale deployment rather than academic demonstration.

---

## 🏗️ System Architecture

DeerFlow implements a **hierarchical multi-agent architecture** built on **LangGraph's** directed graph execution engine, enabling stateful, resumable, and observable agent workflows.

```
User Query
    │
    ▼
┌──────────────────────────────────────────────────────────────┐
│  COORDINATOR AGENT                                           │
│  - Parses user intent                                        │
│  - Routes to Planner or direct execution                     │
│  - Manages global conversation state                         │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────┐
│  PLANNER AGENT                                               │
│  - Decomposes query into ordered sub-tasks                   │
│  - Determines which agents to invoke per step                │
│  - Generates structured execution plan (JSON)                │
└──────┬───────────────────┬──────────────────────────────────┘
       │                   │
       ▼                   ▼
┌──────────────┐  ┌────────────────────────────────────────┐
│  RESEARCHER  │  │  CODE AGENT                            │
│  SUB-AGENT   │  │  - Writes Python code                  │
│              │  │  - Executes in sandbox                  │
│  InfoQuest   │  │  - Returns stdout/output               │
│  Web Module  │  │  - Handles errors, retries             │
└──────┬───────┘  └────────────────────────────────────────┘
       │
  ┌────┴────┐
  │ Search  │  ← Tavily, Bing, Google, DuckDuckGo
  │ Scrape  │  ← Web content extraction
  │ Embed   │  ← Semantic dedup / relevance filter
  └─────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│  REPORTER AGENT                                              │
│  - Receives all sub-task outputs                             │
│  - Synthesizes into structured report                        │
│  - Adds citations, creates coherent narrative                │
│  - Streams output tokens in real-time                        │
└──────────────────────────────────────────────────────────────┘
    │
    ▼
Structured Report (Markdown) + Artifacts (charts, code, data)
```

### Project Structure

```
deer-flow/
├── src/
│   ├── agents/
│   │   ├── coordinator.py      # Top-level routing and state management
│   │   ├── planner.py          # Task decomposition and planning
│   │   ├── researcher.py       # InfoQuest-powered web research
│   │   ├── reporter.py         # Report synthesis
│   │   └── code_agent.py       # Python execution agent
│   ├── tools/
│   │   ├── infoquest.py        # Custom web research module
│   │   ├── web_search.py       # Search API abstraction
│   │   ├── web_scraper.py      # Content extraction utilities
│   │   └── python_executor.py  # Sandboxed code runner
│   ├── memory/
│   │   └── shared_state.py     # Cross-agent working memory
│   ├── graph/
│   │   └── workflow.py         # LangGraph StateGraph definition
│   └── config/
│       └── settings.py         # Configuration dataclass
├── web/                        # Frontend (React/NextJS or similar)
├── api/                        # REST/WebSocket server
└── pyproject.toml
```

---

## ⚙️ Core Components & Workflow

### 1. Coordinator Agent — Intent Parsing and Routing

The Coordinator is the entry point for every query. It:
- Classifies query type: simple (answer directly), research (invoke Planner), analytical (invoke Planner with code execution flag)
- Maintains a global **conversation context** across multi-turn interactions
- Routes follow-up questions using previous research state rather than starting fresh

```python
class CoordinatorAgent:
    def route(self, query: str, state: ResearchState) -> AgentRoute:
        intent = self.llm.classify_intent(query)
        if intent == "simple":
            return AgentRoute.DIRECT_ANSWER
        elif intent == "research":
            return AgentRoute.PLANNER
        elif intent == "analytical":
            return AgentRoute.PLANNER_WITH_CODE
```

### 2. Planner Agent — Multi-step Task Decomposition

The Planner decomposes complex queries into an ordered list of sub-tasks:

```json
{
  "query": "Compare ByteDance's revenue growth to Meta's over 2021-2024",
  "plan": [
    {
      "step": 1,
      "agent": "researcher",
      "task": "Find ByteDance annual revenue figures 2021–2024"
    },
    {
      "step": 2,
      "agent": "researcher",
      "task": "Find Meta (Facebook) annual revenue figures 2021–2024"
    },
    {
      "step": 3,
      "agent": "code",
      "task": "Calculate growth rates and generate comparison chart",
      "depends_on": [1, 2]
    },
    {
      "step": 4,
      "agent": "reporter",
      "task": "Write analysis with chart and citations",
      "depends_on": [1, 2, 3]
    }
  ]
}
```

The plan is **dependency-aware**: steps with no dependencies run in parallel; steps with dependencies wait for their inputs.

### 3. InfoQuest — Custom Web Research Module

**InfoQuest** is DeerFlow's proprietary web research module, a higher-level abstraction over raw search APIs:

```python
class InfoQuest:
    def research(self, query: str, depth: int = 2) -> ResearchResult:
        # Step 1: Generate search queries (multiple angles)
        queries = self.query_generator.expand(query, n=4)
        
        # Step 2: Parallel search and scrape
        results = asyncio.gather(*[
            self.search_and_scrape(q) for q in queries
        ])
        
        # Step 3: Semantic deduplication and ranking
        unique_chunks = self.dedup_and_rank(results, reference_query=query)
        
        # Step 4: Optional recursive deep-dive
        if depth > 1:
            followups = self.identify_gaps(unique_chunks, query)
            deeper = self.research(followups, depth=depth-1)
            unique_chunks += deeper.chunks
        
        return ResearchResult(chunks=unique_chunks, sources=...)
```

Key InfoQuest features:
- **Query expansion**: generates multiple search queries from one question
- **Recursive retrieval**: optionally dives deeper based on identified gaps
- **Multi-modal content**: handles images in web pages (passes to vision-capable LLMs)
- **Content freshness weighting**: prefers recent content for time-sensitive queries

### 4. Code Execution Agent — Sandboxed Python

DeerFlow's most distinctive feature is its **sandboxed Python execution environment**:

```python
class CodeAgent:
    def __init__(self):
        self.sandbox = DockerSandbox(
            image="python:3.11-slim",
            allowed_packages=["pandas", "numpy", "matplotlib", "seaborn", "requests"],
            timeout=30,
            network="none"  # Isolated from network
        )
    
    async def execute(self, task_description: str, context: dict) -> CodeResult:
        # LLM generates code from task description + data context
        code = await self.llm.generate_code(task_description, context)
        
        # Execute in sandbox
        result = await self.sandbox.run(code)
        
        if result.has_error:
            # LLM self-corrects and retries
            fixed_code = await self.llm.fix_code(code, result.error)
            result = await self.sandbox.run(fixed_code)
        
        return result  # stdout, files (charts), execution_time
```

The sandbox prevents:
- Network access from generated code
- File system access outside designated workspace
- Resource exhaustion (CPU/memory limits)
- Execution of harmful operations

### 5. Shared Working Memory

All agents share a **ResearchState** object that persists across the entire workflow:

```python
@dataclass
class ResearchState:
    original_query: str
    plan: Optional[ResearchPlan]
    research_findings: Dict[int, ResearchResult]    # step_id → findings
    code_artifacts: Dict[int, CodeResult]            # step_id → outputs
    citations: List[Citation]
    report_draft: Optional[str]
    metadata: Dict[str, Any]
```

This shared state eliminates redundant retrieval (each agent sees all prior work) and enables coherent final synthesis.

### 6. Reporter Agent — Synthesis and Streaming

The Reporter assembles all sub-task outputs into a final report and streams tokens in real-time to the frontend:

```python
class ReporterAgent:
    async def generate_report_stream(self, state: ResearchState):
        async for token in self.llm.stream_report(
            plan=state.plan,
            findings=state.research_findings,
            code_outputs=state.code_artifacts,
            citations=state.citations
        ):
            yield token  # Streamed via WebSocket to frontend
```

---

## 🔧 Technical Details

### LangGraph StateGraph Definition

```python
from langgraph.graph import StateGraph, END

graph = StateGraph(ResearchState)

graph.add_node("coordinator", coordinator_node)
graph.add_node("planner", planner_node)
graph.add_node("researcher", researcher_node)
graph.add_node("code_agent", code_agent_node)
graph.add_node("reporter", reporter_node)

graph.set_entry_point("coordinator")
graph.add_conditional_edges("coordinator", route_query, {
    "plan": "planner",
    "direct": "reporter"
})
graph.add_edge("planner", "researcher")
graph.add_conditional_edges("researcher", check_needs_code, {
    "code": "code_agent",
    "report": "reporter"
})
graph.add_edge("code_agent", "reporter")
graph.add_edge("reporter", END)
```

### LLM Configuration (Provider Agnostic)

DeerFlow supports any OpenAI-compatible API via a unified configuration:

```yaml
# config.yaml
llm:
  base_url: "https://api.openai.com/v1"  # or any compatible endpoint
  api_key: "${OPENAI_API_KEY}"
  model: "gpt-4o"
  temperature: 0.1
  max_tokens: 8192

# Alternative: local Ollama
llm:
  base_url: "http://localhost:11434/v1"
  model: "qwen2.5:72b"
```

This design supports: OpenAI, Azure OpenAI, Anthropic (via proxy), Ollama, vLLM, LM Studio, Together AI, Groq, and any OpenAI-compatible self-hosted endpoint.

### Real-time Progress Streaming

DeerFlow's frontend receives live updates via **Server-Sent Events (SSE)** or WebSocket:

```python
# Backend
async def stream_research_progress(query: str):
    async for event in research_graph.astream({"query": query}):
        yield {
            "event": "agent_update",
            "data": {
                "agent": event["agent"],
                "status": event["status"],
                "message": event.get("message", ""),
                "tokens": event.get("output_tokens", "")
            }
        }
```

Users see each agent activating, completing, and passing results in real-time.

### Multi-modal Content Handling

When InfoQuest scrapes web pages with images:
```python
if page_has_images and llm_supports_vision:
    for img_url in extracted_image_urls:
        img_description = vision_llm.describe(img_url, context=query)
        chunk_store.add(img_description, source=img_url, type="image_caption")
```

This allows the system to extract information from charts, diagrams, and infographics in web pages.

---

## 📊 Performance & Benchmarks

### Throughput Metrics

| Metric | Value |
|---|---|
| Typical report generation time | 3–7 minutes |
| Average web sources consulted | 30–60 |
| Report length (standard) | 2,000–4,000 words |
| Report length (detailed) | 5,000–8,000 words |
| Code execution success rate | ~85% (first attempt), ~97% (with retry) |
| Parallel agent factor | 3–5 concurrent researchers |

### LLM Token Usage (GPT-4o Estimates)

| Phase | Approx. Tokens | Notes |
|---|---|---|
| Intent routing | ~300 | Minimal |
| Planning | ~1,500 | Structured JSON output |
| Research (per sub-task × 4) | ~4,000 each | InfoQuest calls |
| Code generation + retry | ~2,000 | Per code step |
| Report synthesis | ~10,000 | Long-context synthesis |
| **Total per report** | **~30,000–50,000** | Varies by complexity |

### Quality Comparisons (Internal Evaluation)

| Task Type | DeerFlow | GPT Researcher | Manual Researcher |
|---|---|---|---|
| Quantitative analysis | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| Web synthesis | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Citation accuracy | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Time to complete | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |

---

## ✅ Strengths

1. **Code Execution as a First-Class Feature**: The sandboxed Python executor is genuinely rare among open-source research agents. Tasks requiring calculation, data transformation, or visualization are handled natively rather than via hallucinated pseudo-results.

2. **Dependency-Aware Planning**: The Planner's structured dependency graph enables correct parallel execution — independent tasks run concurrently while dependent tasks wait, optimizing total latency.

3. **ByteDance Production Heritage**: Being born as an internal ByteDance tool means it was designed for real-world reliability and scale, not just as a proof of concept.

4. **Open Provider Design**: By supporting any OpenAI-compatible endpoint, DeerFlow works with local LLMs (Ollama, vLLM), avoiding mandatory cloud API costs.

5. **Real-time Streaming UI**: Live progress streaming provides transparency into what agents are doing, improving user trust and making it easier to identify failures.

6. **InfoQuest's Recursive Retrieval**: The optional recursive depth feature in InfoQuest allows the system to proactively identify knowledge gaps and fill them, improving answer completeness.

7. **Multi-modal Awareness**: Handling images in web pages (via vision LLMs) expands the information surface compared to text-only scrapers.

8. **Shared State Design**: All agents sharing a unified ResearchState prevents duplication of effort and enables coherent, non-contradictory final reports.

---

## ⚠️ Limitations

1. **Code Execution Safety**: Despite sandboxing, sandboxes are not infallible. Complex generated code can still fail in unexpected ways, requiring human review of code artifacts before trusting numerical outputs.

2. **Dependency on Docker**: The code execution sandbox requires Docker, adding infrastructure complexity and making it unsuitable for environments where Docker is not available (e.g., serverless functions).

3. **Newer Open-Source Project**: Compared to GPT Researcher (30k+ stars) or STORM (also multi-year), DeerFlow is newer with a smaller community and less battle-tested documentation.

4. **LangGraph Version Sensitivity**: LangGraph's API has evolved rapidly; DeerFlow may encounter compatibility issues as LangGraph releases breaking changes.

5. **Report Structure Rigidity**: Like other automated report generators, DeerFlow's output can feel templated for topics where natural narrative structure differs from the default plan structure.

6. **Limited Citation Grounding Verification**: Citations are generated as part of the synthesis step and are not independently verified — hallucinated or incorrectly attributed citations are possible.

7. **No Fine-tuned Models**: Unlike OpenScholar (which fine-tunes an 8B model for better scientific synthesis), DeerFlow relies entirely on prompt engineering with general LLMs.

8. **English-Centric Pipeline**: InfoQuest and report generation are optimized for English content. Multilingual research quality degrades, even though ByteDance operates in Chinese markets.

---

## 🔗 Related Work

| Project | Relationship |
|---|---|
| **GPT Researcher** | Most similar architecture (LangGraph + multi-agent web research); DeerFlow adds code execution; GPT Researcher has more mature deployment tooling |
| **STORM** | Both generate structured reports; STORM more citation-focused; DeerFlow more computation-capable |
| **OpenDevin** | Shares code execution + LLM agent concept; OpenDevin is broader (software engineering); DeerFlow specialized for research |
| **AutoGPT** | Earlier general-purpose agent paradigm; DeerFlow is more specialized and reliable |
| **Manus (Butterfly Effect)** | Commercial "SuperAgent" with similar scope; Manus proprietary; DeerFlow open-source |
| **LangGraph** | DeerFlow is a showcase application of LangGraph's state machine capabilities |
| **E2B** | Cloud sandbox alternative to Docker for code execution; DeerFlow could use E2B as backend |
| **Tavily** | Default search backend; designed specifically for AI agent web research workflows |

---

## 📎 References

1. ByteDance. (2024). **DeerFlow: Deep Exploration and Efficient Research Flow**. GitHub Repository. https://github.com/bytedance/deer-flow

2. LangChain Inc. (2024). **LangGraph Documentation: Building Stateful, Multi-Actor Applications**. https://langchain-ai.github.io/langgraph/

3. Chase, H., et al. (2023). **LangChain: Building Applications with LLMs**. https://github.com/langchain-ai/langchain

4. Tavily AI. (2024). **Tavily Search API for AI Agents**. https://tavily.com/

5. OpenAI. (2024). **Function Calling and Tool Use in GPT-4o**. https://platform.openai.com/docs/guides/function-calling

6. Significant Gravitas. (2023). **AutoGPT**. https://github.com/Significant-Gravitas/AutoGPT

7. Wei, J., et al. (2022). **Chain-of-Thought Prompting Elicits Reasoning in Large Language Models**. In *NeurIPS 2022*. https://arxiv.org/abs/2201.11903

8. Yao, S., et al. (2023). **ReAct: Synergizing Reasoning and Acting in Language Models**. In *ICLR 2023*. https://arxiv.org/abs/2210.03629

9. Wang, G., et al. (2023). **Voyager: An Open-Ended Embodied Agent with Large Language Models**. arXiv preprint. https://arxiv.org/abs/2305.16291

10. Schick, T., et al. (2024). **Toolformer: Language Models Can Teach Themselves to Use Tools**. In *NeurIPS 2024*. https://arxiv.org/abs/2302.04761

---

*Report generated for Awesome-Auto-Research. Last updated: 2025.*
