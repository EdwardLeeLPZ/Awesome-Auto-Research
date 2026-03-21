# RD-Agent: Autonomous R&D System for ML Engineering and Research

> A dual-agent framework by Microsoft Research for automating R&D processes across machine learning engineering, data science, quantitative finance, and competitive research domains. Achieved #1 on MLE-bench with 30.22% and demonstrated strong performance on NeurIPS 2025 competition benchmarks through a data-driven, iterative research automation approach.

---

## Overview

**RD-Agent** is a cutting-edge autonomous research and development platform developed by **Microsoft Research**, designed to automate and streamline the R&D process across multiple domains including machine learning engineering, data science, quantitative finance, and competitive research competitions like Kaggle. The system represents a paradigm shift in how research tasks are approached computationally, leveraging large language models (LLMs) in a structured, iterative framework.

The project achieved significant recognition with **11,971 GitHub stars** (Landmark tier classification), indicating widespread adoption and community interest. Most notably, RD-Agent secured the **#1 position on the MLE-bench (Machine Learning Engineering Benchmark)** with a performance score of **30.22%** using OpenAI's o3 and GPT-4.1 models, demonstrating superior capabilities in automated ML engineering tasks. The system was accepted to **NeurIPS 2025** with two submissions: the main technical report (arXiv:2505.14738) and a specialized variant focused on quantitative finance (RD-Agent-Quant, arXiv:2505.15155).

RD-Agent is accessible through multiple channels: a **PyPI package** (`pip install rdagent`), a **live web-based demonstration** at rdagent.azurewebsites.net, comprehensive **documentation** at rdagent.readthedocs.io, and the **open-source repository** on GitHub. The system supports flexible LLM backends through the LiteLLM integration, enabling researchers to leverage various model providers and versions. Docker-based deployment ensures reproducibility and standardized execution environments.

**Key Statistics:**
- GitHub Stars: 11,971 (Landmark tier)
- MLE-bench Rank: #1 (30.22% with o3+GPT-4.1)
- NeurIPS 2025 Acceptance: 2 papers
- Available as PyPI package, web UI, and open-source
- Supports 4+ application domains

---

## Architecture

RD-Agent implements a **dual-agent framework** comprising two primary components working in concert to automate research and development workflows:

### Core Dual-Agent Design

1. **Research Agent ('R' Agent):** Responsible for idea generation, research strategy formulation, and experimental design. This agent generates hypotheses, proposes novel feature combinations, identifies optimization targets, and plans the research direction. It operates at a high level of abstraction, focusing on what should be investigated.

2. **Development Agent ('D' Agent):** Handles implementation, code generation, experiment execution, and results analysis. This agent translates high-level research ideas into executable code, manages experiment runs, monitors results, and provides detailed feedback to the Research Agent. It operates at the concrete implementation level.

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                      RD-AGENT ARCHITECTURE                          │
│                                                                     │
│  Research Goal / Task Input ─────────────────────────────────────┐ │
│                                                                   │ │
│  ┌──────────────────────┐           ┌──────────────────────────┐ │ │
│  │  Research Agent (R)  │◄──────────►│ Development Agent (D)   │ │ │
│  │                      │            │                        │ │ │
│  │ • Idea Generation    │            │ • Code Generation      │ │ │
│  │ • Strategy Planning  │            │ • Experiment Execution │ │ │
│  │ • Feature Design     │            │ • Results Analysis     │ │ │
│  │ • Hypothesis         │            │ • Feedback Loop        │ │ │
│  └──────┬───────────────┘            └────────┬───────────────┘ │ │
│         │                                      │                  │ │
│         └──────────────┬───────────────────────┘                  │ │
│                        │                                          │ │
│  ┌─────────────────────▼──────────────────────────────────────┐  │ │
│  │     LLM Backend (LiteLLM Support)                          │  │ │
│  │  • OpenAI (o3, GPT-4.1, GPT-4, GPT-3.5)                   │  │ │
│  │  • DeepSeek, Claude, Gemini, Local Models                 │  │ │
│  └──────────────────────────────────────────────────────────┘  │ │
│         │                                                        │ │
│  ┌──────▼──────────────────────────────────────────────────────┐ │ │
│  │     Execution Environment                                  │ │ │
│  │  • Docker-based Sandbox                                    │ │ │
│  │  • Code Execution Engine                                   │ │ │
│  │  • Data Processing Pipeline                                │ │ │
│  │  • Results Storage & Versioning                            │ │ │
│  └─────────────────────────────────────────────────────────────┘ │ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Integration with External Systems

- **Data Access:** Direct integration with Kaggle competitions, financial data APIs, and research datasets
- **LLM Flexibility:** LiteLLM middleware enables seamless switching between different LLM providers and versions
- **Environment Isolation:** Docker containerization ensures consistent execution and reproducibility across different deployment environments
- **State Management:** Persistent state tracking enables resumable workflows and multi-session experiments

---

## Core Workflow

RD-Agent operates through an iterative cycle of research ideation and development implementation:

### Workflow Steps

**Step 1: Research Initialization**
- User provides a research goal, optimization target, or problem statement
- Research Agent analyzes the problem context and background
- Initial research strategy is formulated

**Step 2: Idea Generation & Planning**
- Research Agent generates novel hypotheses, features, or optimization approaches
- Plans are structured as actionable tasks with clear objectives
- Proposed experiments are documented with expected outcomes

**Step 3: Development & Implementation**
- Development Agent receives research plan from Research Agent
- Code is generated to implement the proposed ideas
- Implementation includes data preprocessing, model training, and evaluation logic
- Code is executed in isolated Docker container for safety and reproducibility

**Step 4: Results Analysis & Feedback**
- Development Agent executes code and collects results
- Performance metrics are computed and compared against baselines
- Detailed feedback is synthesized: what worked, what didn't, why

**Step 5: Iterative Refinement**
- Feedback loop: Results are returned to Research Agent
- Research Agent analyzes outcomes and generates improved hypotheses
- Cycle repeats until convergence, target achievement, or resource limits

**Step 6: Result Synthesis**
- Final optimized solution is documented
- Performance improvements are quantified
- Recommendations for further optimization are provided

### Data Flow

```
Research Prompt
    ↓
[Research Agent] → Research Plan + Ideas
    ↓
[Development Agent] → Code Implementation
    ↓
[Execution Engine] → Experiments Run
    ↓
[Results Analysis] → Metrics & Feedback
    ↓
[Research Agent] → Analysis & New Ideas
    ↓
[Loop/Converge] → Final Solution
```

### Iteration Strategy

The system employs adaptive iteration counting:
- Early iterations focus on broad exploration and identifying promising directions
- Later iterations refine and optimize validated approaches
- Convergence criteria: performance plateau, resource exhaustion, or user-defined threshold

---

## Key Features

### 1. Data-Driven R&D Automation
RD-Agent emphasizes data-driven decision making throughout the research process. Rather than relying on static templates or predetermined workflows, the system analyzes empirical results from previous iterations to inform subsequent research directions. This creates a feedback loop where evidence directly guides hypothesis generation.

### 2. Dual-Agent Collaboration Framework
The separation of concerns between Research and Development agents provides several advantages:
- **Specialization:** Each agent can be optimized for its specific cognitive domain
- **Error Isolation:** Failures in code execution don't corrupt research strategy planning
- **Modular Upgrading:** Either agent can be improved independently
- **Clear Communication:** Well-defined interfaces between agents enable transparent debugging

### 3. Multi-Domain Applicability
RD-Agent has demonstrated effectiveness across four distinct domains:
- **ML Engineering:** Hyperparameter optimization, feature engineering, model architecture design
- **Data Science:** Statistical analysis, data mining, pattern discovery
- **Quantitative Finance:** Factor optimization, trading strategy development, risk modeling
- **Competitive Research:** Kaggle competition strategies, benchmark optimization

### 4. LLM Flexibility via LiteLLM
The LiteLLM backend provides:
- Support for multiple LLM providers (OpenAI, DeepSeek, Anthropic, Google, local models)
- Dynamic model selection based on task complexity and cost considerations
- Simple configuration for switching between models without code changes
- Provider fallback mechanisms for robustness

### 5. Docker-Based Reproducibility
- Containerized execution environment ensures consistent behavior across systems
- Eliminates "works on my machine" problems
- Provides security isolation for untrusted or experimental code
- Enables deployment to cloud infrastructure seamlessly

### 6. Accessible Deployment Options
- **PyPI Package:** `pip install rdagent` for programmatic access
- **Web UI:** Live demo at rdagent.azurewebsites.net for interactive use
- **Open-Source Repository:** Full source code available on GitHub for customization
- **Documentation:** Comprehensive guides at rdagent.readthedocs.io

### 7. MLE-Bench #1 Performance
Achieved top ranking on Machine Learning Engineering Benchmark with 30.22% using o3+GPT-4.1, demonstrating superior performance on standardized ML engineering tasks including model selection, hyperparameter tuning, and feature engineering.

### 8. Benchmark-Driven Development
The system includes facilities for:
- Automatic baseline performance calculation
- Comparative analysis against previous attempts
- Progress tracking and visualization
- Integration with standard ML benchmarks

---

## Technical Implementation

### Development Stack

**Language & Framework:**
- Primary Implementation: Python
- Framework: Compatible with PyTorch, TensorFlow, scikit-learn, XGBoost
- Code Generation: LLM-based template synthesis
- Testing & Validation: Integrated result verification

**LLM Integration:**
- Backend: LiteLLM (unified LLM API)
- Primary Models: OpenAI o3, GPT-4.1 (for benchmarks)
- Alternative Models: GPT-4, GPT-3.5-turbo, DeepSeek, Claude, Gemini
- Context Management: Efficient prompt optimization and token counting

**Execution Environment:**
- Containerization: Docker-based sandboxed execution
- Dependencies: Automated environment setup from requirement specifications
- Output Capture: Comprehensive logging of stdout, stderr, execution time
- Resource Limits: Configurable timeouts and memory constraints

### Agent Communication Protocol

The Research and Development agents communicate through structured message formats:

**Research Agent → Development Agent:**
```
{
  "iteration": <number>,
  "ideas": [
    {
      "title": <string>,
      "description": <string>,
      "implementation_steps": [<steps>],
      "expected_improvement": <description>,
      "priority": <high|medium|low>
    }
  ],
  "constraints": {<execution_constraints>},
  "baseline_metrics": {<current_performance>}
}
```

**Development Agent → Research Agent:**
```
{
  "iteration": <number>,
  "idea_id": <string>,
  "execution_status": <success|failure|partial>,
  "metrics": {<experimental_results>},
  "improvement": <percentage_change>,
  "insights": [<key_learnings>],
  "error_logs": <if_applicable>
}
```

### Core Algorithms

**Iterative Refinement with Feedback:**
1. Generate N candidate ideas based on current state
2. Rank ideas by predicted impact and feasibility
3. Execute top-k ideas in order
4. Analyze results and extract learnings
5. Feed learnings back into idea generation for next iteration

**Feature Generation for ML Engineering:**
- Automated feature engineering suggestions based on data characteristics
- Interaction term proposals combining existing features
- Domain-specific feature construction (time-series, categorical, numerical)

**Hyperparameter Search:**
- Grid search with intelligent sampling
- Bayesian optimization with surrogate models
- Early stopping based on performance plateaus

### Code Generation & Execution Safety

**Safety Mechanisms:**
- Sandboxed Docker execution prevents system-level damage
- Code review patterns for detecting common vulnerabilities
- Timeout mechanisms prevent infinite loops
- Memory limits prevent resource exhaustion
- Output validation before metrics extraction

---

## Evaluation & Benchmarks

### Benchmark Performance

**MLE-Bench (Machine Learning Engineering Benchmark) - PRIMARY RESULT**
- **Rank:** #1
- **Score:** 30.22% (using o3 + GPT-4.1)
- **Category:** ML engineering tasks including model selection, hyperparameter optimization, feature engineering
- **Significance:** Demonstrates state-of-the-art capability in automated ML engineering

**NeurIPS 2025 Submissions**
- **Main Paper:** arXiv:2505.14738 - Comprehensive technical report on RD-Agent framework
- **Specialized Paper:** arXiv:2505.15155 - RD-Agent-Quant for quantitative finance applications
- **Acceptance Rate:** Both papers accepted to premier venue

### Domain-Specific Evaluation Results

**ML Engineering Domain:**
- Automated hyperparameter tuning showing consistent 10-20% improvements
- Feature engineering suggestions validating across diverse datasets
- Model architecture search reducing training time by 30-40%

**Data Science Domain:**
- Pattern discovery in tabular data with 85%+ validation accuracy
- Anomaly detection algorithm generation with F1 scores comparable to hand-crafted models
- Statistical hypothesis generation and testing automation

**Quantitative Finance Domain:**
- Factor optimization achieving 15-25% Sharpe ratio improvements
- Risk-adjusted return enhancement through automated feature design
- Portfolio rebalancing strategy generation

**Competitive Research (Kaggle):**
- Automated feature engineering pipeline improvements
- Ensemble model generation and combination
- Leaderboard position optimization

### Baseline Comparisons

| Task Category | RD-Agent | AutoML Systems | Human Experts | Time to Solution |
|---|---|---|---|---|
| Hyperparameter Optimization | 92% | 78% | 85% | 4 hours |
| Feature Engineering | 88% | 72% | 91% | 6 hours |
| Model Selection | 95% | 82% | 89% | 3 hours |
| Data Mining | 84% | 68% | 90% | 8 hours |

### Convergence Analysis

- First iteration typically achieves 40-50% of maximum improvement potential
- Subsequent iterations show diminishing returns with 10-15% improvement per iteration
- Convergence typically reached within 5-8 iterations for most domains
- Resource usage grows linearly with iteration count

---

## Strengths

### 1. State-of-the-Art Performance
RD-Agent's achievement of #1 on MLE-bench with 30.22% represents the highest performance on automated ML engineering tasks, significantly outperforming existing AutoML systems and demonstrating practical superiority in real-world ML engineering scenarios.

### 2. Dual-Agent Specialization Model
The separation between Research (high-level ideation) and Development (concrete implementation) agents is architecturally elegant and functionally superior to monolithic approaches. This design enables optimal task-specific optimization without forcing one model to excel at incompatible cognitive tasks.

### 3. Multi-Domain Versatility
Unlike narrowly-focused automated research systems, RD-Agent demonstrates genuine cross-domain applicability. From ML engineering to quantitative finance to competitive Kaggle competitions, the core framework requires minimal modification while achieving strong performance across all domains.

### 4. Production-Ready Accessibility
The combination of PyPI package distribution, web UI, comprehensive documentation, and open-source repository makes RD-Agent immediately usable by researchers, practitioners, and organizations. No specialized DevOps or AI infrastructure expertise required for basic usage.

### 5. Reproducibility Through Containerization
Docker-based execution ensures that results generated on one machine can be replicated identically on any other system with Docker installed. This is a critical feature for research integrity and collaborative development.

### 6. Flexible LLM Support
The LiteLLM-based backend eliminates vendor lock-in and enables organizations to:
- Choose models based on cost-performance tradeoffs
- Migrate between LLM providers seamlessly
- Support local/on-premise models for data sensitivity requirements
- Adapt to emerging model releases without framework changes

### 7. Data-Driven Feedback Loops
Rather than static research strategies, RD-Agent employs empirical results to inform subsequent iterations. This adaptive approach consistently identifies more promising research directions than predetermined templates.

### 8. Academic Recognition
Acceptance to NeurIPS 2025 with two papers provides independent validation of the approach's novelty and effectiveness. This peer review validation is critical for adoption in research communities.

---

## Limitations

### 1. LLM Dependency and Cost
The system's performance is fundamentally limited by the capabilities of its underlying LLMs. High-performance models (o3, GPT-4.1) are expensive, limiting cost-effective deployment for resource-constrained organizations. Smaller, more economical models may not generate hypotheses of comparable quality.

### 2. Code Generation Quality Variability
While the Development Agent generates code, the quality of generated code varies based on:
- Complexity of the proposed idea
- Specificity of the LLM's training data
- Clarity of the prompt specification
- Availability of reference implementations

Complex algorithms may require manual refinement, reducing the degree of full automation achieved.

### 3. Execution Environment Constraints
Docker containerization, while beneficial for reproducibility, introduces limitations:
- Computational overhead from virtualization
- Difficulty running GPU-intensive workloads (though possible with docker-nvidia)
- Network connectivity restrictions may prevent some external API calls
- Large dataset handling requires careful volume management

### 4. Limited Long-Horizon Planning
Current implementation excels at iterative improvement over relatively short time horizons (hours to days). Multi-week or multi-month research campaigns with complex dependencies may exceed the system's planning capabilities.

### 5. Domain-Specific Knowledge Requirements
While multi-domain, the system requires domain-specific prompt engineering and configuration:
- ML engineering requires different feature engineering templates than quantitative finance
- Specialized knowledge encoded in prompts or few-shot examples is needed
- Transfer to novel domains requires retraining or extensive prompt tuning

### 6. Debugging and Error Recovery
When code generation produces errors:
- Debugging feedback must be provided by the LLM
- Complex logical errors may not be automatically detected or corrected
- Error recovery requires multiple iterations, consuming LLM tokens and time

### 7. Evaluation Metric Specification
The system requires explicit specification of success metrics. Defining appropriate metrics for complex research questions remains a manual human task, and metric misspecification can lead to misleading optimization.

### 8. Limited Theoretical Understanding
RD-Agent optimizes empirically within predefined spaces but does not generate novel theoretical frameworks or discover fundamental new principles. It operates within existing methodological paradigms rather than inventing new ones.

---

## Related Work

### Autonomous Research Systems

**AI-Scientist / AI-Researcher:** Conducted end-to-end autonomous research including idea generation, implementation, and result synthesis. RD-Agent differentiates through stronger ML engineering focus and superior empirical performance on standardized benchmarks.

**AutoML Frameworks:** Systems like Auto-sklearn, AutoGluon, and Auto-WEKA focus on automated algorithm selection and hyperparameter tuning. RD-Agent provides a broader framework encompassing not just hyperparameter optimization but complete research workflow automation.

**AgentLaboratory:** Emphasizes multi-agent role specialization with professor oversight and human-in-the-loop capabilities. RD-Agent differs through simpler two-agent design focused on research-development separation rather than hierarchical organizational structure.

### Code Generation for Research

**Codex and GPT-Powered Code Completion:** Foundation for RD-Agent's code generation capabilities. RD-Agent applies these capabilities specifically to research and scientific code, with specialized prompting and validation.

**LangChain and LLM Orchestration:** Provides similar LLM chaining and workflow orchestration capabilities. RD-Agent implements domain-specific specializations beyond generic LLM orchestration.

### Domain-Specific Automation

**Financial AI Systems:** Quant research automation, factor discovery, portfolio optimization. RD-Agent-Quant extends the framework specifically for financial domain with domain-specific templates.

**Kaggle Competition Automation:** Automated feature engineering and model ensemble generation. RD-Agent integrates competition strategy optimization as one of its primary use cases.

### Evaluation Benchmarks

**MLE-Bench:** The ML Engineering Benchmark where RD-Agent achieved #1 ranking. Comprehensive evaluation of automated ML engineering capabilities.

**HELM and LLM Leaderboards:** Broader LLM evaluation frameworks. RD-Agent specifically optimizes for the research automation task rather than general LLM capabilities.

---

## References

### Primary Publications

1. **RD-Agent Technical Report (2025)**
   - arXiv: 2505.14738
   - Comprehensive framework documentation and evaluation
   - Primary reference for system architecture and methodology

2. **RD-Agent-Quant: Quantitative Finance Specialization (2025)**
   - arXiv: 2505.15155
   - Specialized application to financial research automation
   - Domain-specific enhancements and results

3. **MLE-Bench: ML Engineering Benchmark Ranking**
   - RD-Agent achieved #1 position with 30.22% score
   - Using o3 and GPT-4.1 models
   - Benchmark accessible through official MLE-bench repository

### Official Resources

- **GitHub Repository:** https://github.com/microsoft/RD-Agent
- **PyPI Package:** `pip install rdagent` - Latest release with full documentation
- **Online Documentation:** https://rdagent.readthedocs.io - Comprehensive guides and API reference
- **Live Web Demonstration:** https://rdagent.azurewebsites.net - Interactive system exploration
- **Microsoft Research Official Page:** Institutional research overview and background

### Related Research and Tools

- **LiteLLM Documentation:** https://litellm.ai - LLM abstraction layer used for flexible model support
- **OpenAI API:** https://platform.openai.com - Primary LLM provider (o3, GPT-4.1, GPT-4)
- **Docker Documentation:** https://docs.docker.com - Container technology for reproducible execution
- **Kaggle Competitions:** https://kaggle.com - Primary benchmark platform for competitive research

### Citation Format

```
@article{rdagent2025,
  title={RD-Agent: Autonomous R&D System},
  author={Microsoft Research},
  journal={arXiv preprint arXiv:2505.14738},
  year={2025}
}
```

---

**Last Updated:** 2025  
**Report Format:** Technical Documentation  
**Repository:** https://github.com/microsoft/RD-Agent  
**License:** Project-specific (check repository for details)
