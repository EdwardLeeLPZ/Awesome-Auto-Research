# Open Deep Research
> LangChain's official open-source reference implementation for deep research — a configurable, LangGraph-orchestrated pipeline that searches multiple sources, synthesizes findings, and produces structured reports with inline citations.

---

## 📌 Project Overview

**Repository:** https://github.com/langchain-ai/open_deep_research  
**Organization:** LangChain AI  
**License:** MIT  
**Language:** Python  
**Framework:** LangChain + LangGraph  
**First Release:** Early 2025

Open Deep Research is LangChain's official open-source implementation of an AI-powered deep research pipeline. It is designed as both a **functional research tool** and a **reference implementation** — showing how to build production-quality research agents using LangChain, LangGraph, and MCP (Model Context Protocol).

The system takes a user query, automatically identifies research angles, performs multi-source search and retrieval in parallel, synthesizes the results using an LLM, and produces a structured report with inline citations. Unlike single-search chat interfaces, Open Deep Research mimics the workflow of a human researcher: formulating sub-questions, gathering sources, evaluating relevance, and compiling a coherent, cited analysis.

Open Deep Research is notable for its **configurability at every layer**: search providers, LLM backends, document loaders, and output formats can all be swapped via configuration, making it an educational reference that teaches LangChain/LangGraph patterns alongside being practically useful.

The project integrates **MCP (Model Context Protocol)** for extensible tool access and **LangSmith** for comprehensive tracing and observability — positioning it within LangChain's broader ecosystem philosophy that agents should be observable, debuggable, and composable.

---

## 🎯 Project Positioning

Open Deep Research targets:

1. **Researchers and analysts** who need quick, cited overviews of topics — academic, business intelligence, technical, or news domains.
2. **LangChain developers** learning how to build production-grade LangGraph pipelines with proper tracing, parallelism, and configurability.
3. **Organizations** wanting a self-hosted, customizable alternative to closed research tools like OpenAI Deep Research or Perplexity Pro.
4. **AI developers** evaluating how to integrate MCP tools into LangGraph applications.

**Design philosophy:**
- **Reference over novelty**: The code is written to be readable and educational, not just functional.
- **Swap everything**: No search provider, LLM, or document loader is hardcoded — all are configuration choices.
- **Observable by default**: LangSmith tracing is integrated at every step; you can see exactly what the agent searched for and why.
- **Community-driven**: PRs for new search sources, LLM providers, and output formats are actively welcomed.

**Compared to similar systems:**

| System | Search Sources | Orchestration | Observability | Open Source |
|--------|---------------|---------------|---------------|-------------|
| **Open Deep Research** | Tavily/Perplexity/Exa/ArXiv/PubMed/Wikipedia | LangGraph | LangSmith | ✅ MIT |
| GPT Researcher | Tavily/Google/Bing/etc. | Custom async | Limited | ✅ MIT |
| DeerFlow (ByteDance) | Search APIs | LangGraph | Limited | ✅ Apache 2.0 |
| OpenAI Deep Research | Bing/internal | Proprietary | ❌ | ❌ |
| Perplexity Pro | Internal | Proprietary | ❌ | ❌ |
| Exa Research | Exa | Proprietary | ❌ | ❌ |

---

## 🏗️ System Architecture

Open Deep Research is built around a **LangGraph state graph** — a directed acyclic graph (with conditional edges) where each node represents a step in the research pipeline and edges define the flow of state between steps.

```
┌─────────────────────────────────────────────────────────────┐
│                    Open Deep Research                        │
│                                                             │
│  User Query                                                 │
│      │                                                      │
│      ▼                                                      │
│  ┌────────────┐                                             │
│  │  Generate  │  LLM decomposes query into research        │
│  │  Sections  │  sections / sub-questions                  │
│  └─────┬──────┘                                             │
│        │                                                    │
│        ▼                                                    │
│  ┌─────────────────────────────────┐                        │
│  │     Parallel Section Research   │                        │
│  │                                 │                        │
│  │  ┌──────────┐  ┌──────────┐    │                        │
│  │  │ Section  │  │ Section  │ …  │  (runs concurrently)   │
│  │  │  Node 1  │  │  Node 2  │    │                        │
│  │  └────┬─────┘  └────┬─────┘    │                        │
│  │       │              │          │                        │
│  │  ┌────▼──────────────▼──────┐  │                        │
│  │  │     Search & Retrieve    │  │                        │
│  │  │  (MCP / search APIs)     │  │                        │
│  │  └─────────────────────────┘  │                        │
│  └─────────────────────────────────┘                        │
│        │                                                    │
│        ▼                                                    │
│  ┌─────────────┐                                            │
│  │  Synthesize │  LLM synthesizes section content          │
│  │  Sections   │  from search results                      │
│  └──────┬──────┘                                            │
│         │                                                   │
│         ▼                                                   │
│  ┌─────────────┐                                            │
│  │  Compile    │  Combine sections + add references        │
│  │  Report     │  + format as markdown                     │
│  └──────┬──────┘                                            │
│         │                                                   │
│         ▼                                                   │
│  Structured Report (Markdown with inline citations)         │
└─────────────────────────────────────────────────────────────┘
```

### LangGraph State Graph Definition

The research pipeline is defined as a LangGraph `StateGraph`. State is a typed Python `TypedDict` that flows through all nodes:

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict, List, Annotated
import operator

class ResearchState(TypedDict):
    topic: str                          # Input: user's research query
    sections: List[Section]             # Planned report sections
    search_results: List[SearchResult]  # Raw search results
    section_content: Annotated[         # Accumulated section drafts
        List[str], operator.add         # (parallel nodes append here)
    ]
    final_report: str                   # Output: compiled report

# Graph construction
builder = StateGraph(ResearchState)

builder.add_node("plan_sections", plan_sections_node)
builder.add_node("research_section", research_section_node)  # runs in parallel
builder.add_node("synthesize_section", synthesize_section_node)
builder.add_node("compile_report", compile_report_node)

builder.set_entry_point("plan_sections")
builder.add_edge("plan_sections", "research_section")
builder.add_edge("research_section", "synthesize_section")
builder.add_conditional_edges(
    "synthesize_section",
    should_continue_research,  # Returns "research_section" or "compile_report"
    {
        "research_section": "research_section",
        "compile_report": "compile_report"
    }
)
builder.add_edge("compile_report", END)

graph = builder.compile()
```

The `Annotated[List[str], operator.add]` on `section_content` is a LangGraph pattern that enables safe parallel writes — multiple parallel section nodes can append to this list concurrently without race conditions.

---

## ⚙️ Core Components & Workflow

### Step 1: Section Planning

The first node sends the user's query to the LLM with a structured prompt requesting a research plan:

```python
async def plan_sections_node(state: ResearchState, config: RunnableConfig):
    llm = get_llm(config)  # From config
    
    prompt = PLAN_SECTIONS_PROMPT.format(topic=state["topic"])
    
    # Structured output: forces LLM to return valid JSON
    structured_llm = llm.with_structured_output(ResearchPlan)
    plan: ResearchPlan = await structured_llm.ainvoke(prompt)
    
    return {"sections": plan.sections}
```

**Example output for query "Impact of transformer architectures on NLP":**
```json
{
  "sections": [
    {"title": "Historical Context", "search_query": "transformer architecture attention mechanism 2017 Vaswani"},
    {"title": "BERT and Bidirectional Pre-training", "search_query": "BERT bidirectional encoder representations transformers 2018"},
    {"title": "GPT Series and Autoregressive Models", "search_query": "GPT language model OpenAI autoregressive pre-training"},
    {"title": "Scaling Laws and Emergent Capabilities", "search_query": "large language model scaling laws emergent abilities"},
    {"title": "Current State and Future Directions", "search_query": "transformer limitations alternatives state space models 2024"}
  ]
}
```

### Step 2: Parallel Section Research

Each section is researched independently in parallel using LangGraph's `Send` API:

```python
from langgraph.constants import Send

def dispatch_section_research(state: ResearchState):
    """Returns Send objects to parallelize section research."""
    return [
        Send("research_section", {"section": section, "topic": state["topic"]})
        for section in state["sections"]
    ]

# In the graph builder:
builder.add_conditional_edges(
    "plan_sections",
    dispatch_section_research,
    ["research_section"]  # Target node(s)
)
```

Each `Send` creates an independent sub-graph execution for that section, allowing all sections to be researched concurrently. This is one of LangGraph's most powerful patterns for parallelism.

### Step 3: Search & Retrieval via MCP

Within each section research node, the agent performs searches using configured search providers. MCP enables tool access:

```python
async def research_section_node(state: SectionResearchState, config: RunnableConfig):
    search_provider = get_search_provider(config)  # Tavily, Exa, ArXiv, etc.
    section = state["section"]
    
    # Primary search
    results = await search_provider.search(
        query=section.search_query,
        max_results=config["configurable"].get("max_results_per_section", 5)
    )
    
    # Optional: follow up with web scraping for full content
    if config["configurable"].get("fetch_full_content", True):
        full_content = await fetch_page_content(results)
        results = merge_content(results, full_content)
    
    return {"search_results": results, "current_section": section}
```

### Step 4: Section Synthesis

After retrieval, an LLM synthesizes the search results into a coherent section:

```python
async def synthesize_section_node(state: SectionResearchState, config: RunnableConfig):
    llm = get_llm(config)
    
    # Build context from search results
    search_context = format_search_results(state["search_results"])
    
    prompt = SYNTHESIZE_SECTION_PROMPT.format(
        topic=state["topic"],
        section_title=state["current_section"].title,
        search_results=search_context
    )
    
    content = await llm.ainvoke(prompt)
    
    # Track citations: extract URLs from search results
    citations = extract_citations(state["search_results"])
    
    return {
        "section_content": [f"## {state['current_section'].title}\n\n{content}\n"],
        "citations": citations
    }
```

### Step 5: Report Compilation

The final node assembles all sections and adds a references section:

```python
async def compile_report_node(state: ResearchState, config: RunnableConfig):
    sections_text = "\n\n".join(state["section_content"])
    references = compile_references(state.get("all_citations", []))
    
    report = f"""# Research Report: {state["topic"]}

*Generated by Open Deep Research*

---

{sections_text}

---

## References

{references}
"""
    return {"final_report": report}
```

---

## 🔧 Technical Details

### MCP Integration

Model Context Protocol (MCP) is an open standard developed by Anthropic for connecting AI applications to tools and data sources. Open Deep Research uses MCP to provide extensible search tool access:

```python
from langchain_mcp_adapters.client import MultiServerMCPClient

# Configure MCP servers
mcp_client = MultiServerMCPClient({
    "tavily": {
        "command": "npx",
        "args": ["-y", "tavily-mcp@latest"],
        "env": {"TAVILY_API_KEY": os.environ["TAVILY_API_KEY"]}
    },
    "arxiv": {
        "command": "python",
        "args": ["-m", "arxiv_mcp_server"],
    },
    "pubmed": {
        "command": "python",
        "args": ["-m", "pubmed_mcp_server"],
    }
})

# Get tools as LangChain-compatible tools
tools = await mcp_client.get_tools()
# → [TavilySearchTool, ArxivSearchTool, PubMedSearchTool, ...]

# Bind to LLM for tool use
llm_with_tools = llm.bind_tools(tools)
```

**Available MCP tool servers:**

| Server | Source | Best For |
|--------|--------|---------|
| `tavily-mcp` | Tavily | Web search, general queries |
| `perplexity-mcp` | Perplexity | Curated web search |
| `exa-mcp` | Exa | Semantic web search |
| `arxiv-mcp-server` | ArXiv | Academic papers |
| `pubmed-mcp-server` | PubMed/NCBI | Biomedical literature |
| `wikipedia-mcp` | Wikipedia | Encyclopedic background |

Adding a new search source requires only implementing an MCP server — no changes to Open Deep Research's core code are needed.

### LangSmith Tracing

LangSmith integration is automatic — all LangGraph nodes are traced by default when `LANGCHAIN_API_KEY` is set:

```bash
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=ls__...
export LANGCHAIN_PROJECT="open-deep-research"
```

**What gets traced for each research run:**
- Complete LangGraph execution trace with timing for each node
- Every LLM call: exact prompt, model, temperature, tokens used, response
- Every tool call: search query, provider, result count, raw results
- State transitions: what state was passed between nodes
- Error traces: if any node fails, the full stack trace is captured

**Using LangSmith for debugging:**

From the LangSmith UI, you can:
1. **See why a section was poor**: View the exact search results the LLM had access to
2. **Identify slow nodes**: Timing breakdown shows if search or synthesis is the bottleneck
3. **Compare runs**: Side-by-side comparison of different LLM/search configurations
4. **Replay from state**: Re-run from any intermediate state to test prompt changes

### Configuration System

Configuration is handled via LangGraph's `RunnableConfig` with a `configurable` dict:

```python
# All configuration for a research run
config = {
    "configurable": {
        # LLM settings
        "llm_provider": "anthropic",           # openai | anthropic | openrouter | ollama
        "llm_model": "claude-sonnet-4-5",      # Model name for the provider
        "planner_llm": "openai/o1",            # Optional: different model for planning
        "synthesizer_llm": "claude-sonnet-4-5",# Optional: different model for synthesis
        
        # Search settings
        "search_provider": "tavily",           # tavily | perplexity | exa | arxiv | pubmed | wikipedia
        "max_sections": 5,                     # Number of report sections
        "max_results_per_section": 5,          # Search results per section
        "fetch_full_content": True,            # Scrape full page content vs. snippets
        
        # Output settings
        "report_format": "markdown",           # markdown | json | html
        "include_citations": True,             # Inline citations in report
        "citation_style": "inline_url",        # inline_url | numbered | footnote
    }
}

# Run with config
result = await graph.ainvoke(
    {"topic": "Recent advances in protein structure prediction"},
    config=config
)
```

**Swapping LLM providers** (no code changes needed):

```python
# OpenAI
config["configurable"]["llm_provider"] = "openai"
config["configurable"]["llm_model"] = "gpt-4o"

# Anthropic
config["configurable"]["llm_provider"] = "anthropic"
config["configurable"]["llm_model"] = "claude-sonnet-4-5"

# Fully local with Ollama
config["configurable"]["llm_provider"] = "ollama"
config["configurable"]["llm_model"] = "llama3.1:8b"
# Note: local models produce lower quality research but have zero API cost

# OpenRouter (access 100+ models)
config["configurable"]["llm_provider"] = "openrouter"
config["configurable"]["llm_model"] = "mistralai/mistral-large"
```

### Adding Custom Search Sources

To add a new search source:

1. **Implement an MCP server** that exposes a `search` tool:
```python
# my_custom_source_server.py
from mcp.server import Server
from mcp.types import Tool, TextContent

server = Server("my-custom-source")

@server.list_tools()
async def list_tools():
    return [Tool(
        name="search_my_source",
        description="Search MySource for academic content",
        inputSchema={
            "type": "object",
            "properties": {"query": {"type": "string"}},
            "required": ["query"]
        }
    )]

@server.call_tool()
async def call_tool(name: str, arguments: dict):
    if name == "search_my_source":
        results = await my_source_api.search(arguments["query"])
        return [TextContent(type="text", text=format_results(results))]
```

2. **Register the server** in the MCP client configuration:
```python
mcp_client = MultiServerMCPClient({
    ...,
    "my_custom_source": {
        "command": "python",
        "args": ["-m", "my_custom_source_server"]
    }
})
```

3. **Update the config** to use your source:
```python
config["configurable"]["search_provider"] = "my_custom_source"
```

No changes to Open Deep Research's core orchestration code are needed.

---

## 📊 Performance & Benchmarks

### Research Quality Metrics

Open Deep Research does not publish standardized benchmark results (unlike SWE-Bench for coding agents). Evaluation is typically done qualitatively:

| Dimension | Performance | Notes |
|-----------|------------|-------|
| Citation accuracy | High | URLs are directly extracted from search results |
| Factual accuracy | Model-dependent | Better with GPT-4o/Claude than local models |
| Coverage breadth | Good | Parallel search covers multiple angles |
| Synthesis coherence | Good | Structured prompts produce consistent sections |
| Report length | 1000–3000 words | Configurable via prompt |
| Latency | 30–120 seconds | Depends on section count and search provider |

### Latency Breakdown

For a typical 5-section report with Tavily search and Claude Sonnet:

| Stage | Duration | Notes |
|-------|----------|-------|
| Section planning | 3–8s | Single LLM call |
| Parallel section research | 8–20s | 5 sections × search API calls, parallel |
| Parallel section synthesis | 15–40s | 5 LLM calls, parallel |
| Report compilation | 2–5s | Minimal LLM work |
| **Total** | **28–73s** | Well within interactive use threshold |

The parallelism in section research and synthesis is the key performance optimization — sequential execution would take 3–5× longer.

### Cost Estimates (GPT-4o)

| Report Size | Sections | Est. Input Tokens | Est. Output Tokens | Est. Cost |
|-------------|----------|------------------|--------------------|-----------|
| Quick overview | 3 | ~20K | ~2K | ~$0.08 |
| Standard report | 5 | ~40K | ~5K | ~$0.18 |
| Deep report | 8 | ~80K | ~10K | ~$0.40 |

Costs are dramatically lower with Claude Haiku or local Ollama models.

---

## ✅ Strengths

1. **Multi-source parallel search**: Simultaneously queries multiple search providers per research angle, producing more comprehensive coverage than single-source approaches.

2. **MCP extensibility**: The MCP integration means any data source with an MCP server can be plugged in without modifying core code. This is particularly powerful for domain-specific research (medical literature via PubMed, code via GitHub search, etc.).

3. **LangSmith observability**: Built-in tracing makes every research run fully inspectable, which is critical for debugging quality issues and understanding system behavior.

4. **Full configurability**: Every major component (LLM, search provider, document loader, output format) is swappable via configuration. This makes it ideal as both a tool and a teaching reference.

5. **LangGraph parallelism**: The `Send` API enables true concurrent section research, significantly reducing latency for multi-section reports.

6. **Structured output**: Using `with_structured_output()` for section planning ensures the LLM produces valid, parseable research plans rather than free-form text.

7. **Citation tracking**: Inline citations are automatically extracted from search result URLs and included in the report, providing source traceability.

8. **Local model support**: Full Ollama integration enables completely offline, zero-cost research on capable local models.

9. **Educational reference**: The codebase demonstrates LangGraph best practices (parallel execution, state management, conditional routing, streaming) in a real-world application context.

10. **Community openness**: LangChain actively accepts PRs for new search sources, LLM providers, and output formats, creating a growing ecosystem of search integrations.

---

## ⚠️ Limitations

1. **Search result quality ceiling**: The output quality is bounded by what search APIs return. For niche or highly technical topics, general web search may return poor sources.

2. **No fact-checking**: The system synthesizes whatever search results it retrieves without independently verifying facts. Hallucination is reduced (because it uses real sources) but not eliminated.

3. **Shallow domain expertise**: The LLM may not correctly assess the quality or relevance of sources for specialized domains. A biomedical paper might be cited incorrectly or misrepresented.

4. **No iterative refinement**: The current pipeline is linear — plan → search → synthesize → report. If the plan is wrong or searches return poor results, there's no loop back to try alternative queries.

5. **Context window limits**: For very broad topics with many sections, the accumulated search results may exceed model context windows, requiring truncation.

6. **API rate limits**: Parallel search across many sections may hit rate limits on search APIs (Tavily, Exa, etc.), requiring backoff logic.

7. **Cost unpredictability**: Large reports with full content fetching can generate unexpectedly large token counts.

8. **No persistent knowledge**: Each research run starts fresh. There's no mechanism to build on previous research runs or accumulate a knowledge base over time.

9. **English-centric**: Most search providers and the default prompts are optimized for English-language research.

10. **Reference quality varies**: The citation extraction captures URLs from search results, but may include low-quality sources (blogs, forums) alongside authoritative ones. There's no automatic source quality filtering.

---

## 🔗 Related Work

- **GPT Researcher** (Assafo, 2023): An earlier and more mature open-source deep research tool; similar workflow but uses custom async orchestration instead of LangGraph; supports more search providers.
- **DeerFlow** (ByteDance, 2025): Also LangGraph-based; similar architecture to Open Deep Research; adds a "mind map" planning step and richer UI.
- **Perplexity AI**: Commercial product that pioneered the "cited web search + synthesis" paradigm; closed-source.
- **OpenAI Deep Research**: OpenAI's proprietary research agent; uses a more sophisticated multi-round search loop; benchmark results significantly higher.
- **LangGraph** (LangChain, 2024): The orchestration framework underlying Open Deep Research; understanding LangGraph is prerequisite to understanding the codebase.
- **LangSmith** (LangChain, 2023): Observability platform deeply integrated with Open Deep Research; provides the production monitoring layer.
- **Tavily Search API**: The default and most tightly integrated search provider; purpose-built for LLM applications.
- **Exa Search**: Neural search engine providing semantic similarity-based web search; strong alternative to keyword-based search.
- **MCP (Model Context Protocol)** (Anthropic, 2024): The extensibility protocol that Open Deep Research uses for tool access; enables plug-and-play search sources.
- **STORM** (Shao et al., 2024, Stanford): Academic research on LLM-powered Wikipedia-style article writing; similar pipeline to Open Deep Research but research-focused.

---

## 📎 References

1. LangChain AI. (2025). "Open Deep Research." GitHub Repository. https://github.com/langchain-ai/open_deep_research
2. Chase, H. (2022). "LangChain: Building applications with LLMs through composability." GitHub Repository. https://github.com/langchain-ai/langchain
3. LangChain AI. (2024). "LangGraph: Build resilient language agents as graphs." https://github.com/langchain-ai/langgraph
4. Anthropic. (2024). "Model Context Protocol (MCP) Specification." https://modelcontextprotocol.io/
5. LangChain AI. (2023). "LangSmith: LLM observability and evaluation." https://smith.langchain.com/
6. Shao, Y., et al. (2024). "Assisting in Writing Wikipedia-like Articles From Scratch with Large Language Models." *arXiv preprint arXiv:2402.14207*. (STORM system)
7. Assafo, A. (2023). "GPT Researcher: Autonomous agent designed for comprehensive online research." https://github.com/assafelovic/gpt-researcher
8. ByteDance. (2025). "DeerFlow: Deep Exploration and Efficient Research Flow." https://github.com/bytedance/deer-flow
9. OpenAI. (2025). "Introducing Deep Research." https://openai.com/index/introducing-deep-research/
10. Chen, B., et al. (2024). "MIRA: Towards Multi-Round Information Retrieval for Long Documents via RAG." *arXiv preprint arXiv:2406.01399*.
