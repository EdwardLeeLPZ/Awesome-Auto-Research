# Biomni (Stanford SNAP)
> A general-purpose biomedical AI agent from Stanford's SNAP group that integrates multi-provider LLM reasoning, structured biomedical datalake retrieval, curated know-how protocols, and sandboxed Python code execution to automate diverse tasks across genomics, drug discovery, clinical research, and molecular biology.

---

## 📌 Project Overview

**Biomni** is a general-purpose biomedical AI agent developed by the **Stanford Network Analysis Project (SNAP) group** at Stanford University. Unlike domain-specific bioinformatics tools that excel at one task (variant calling, protein structure prediction, pathway analysis), Biomni is designed as a **unified reasoning and execution platform** that can handle virtually any biomedical research task through a combination of:

1. **Multi-provider LLM reasoning backbone** — supports Anthropic, OpenAI, Azure OpenAI, Google Gemini, Groq, AWS Bedrock, and custom endpoints
2. **Biomedical datalake retrieval** — structured access to curated biomedical databases (genomics, proteomics, pharmacology, clinical data)
3. **Know-how library** — a curated repository of domain-specific protocols, standard workflows, and experimental procedures
4. **Sandboxed code execution** — a Python environment with bioinformatics libraries for data analysis, visualization, and statistical testing

The system adopts a **tool-use architecture**: given a biomedical question or task, the LLM backbone reasons about which tools to call (retrieval, code execution, web search), in what order, and how to synthesize their outputs into a coherent answer or research artifact.

**Repository:** [https://github.com/snap-stanford/Biomni](https://github.com/snap-stanford/Biomni)  
**Institution:** Stanford University, SNAP Group  
**Focus Domain:** Biomedical research automation  
**Language:** Python  
**License:** MIT  

---

## 🎯 Project Positioning

Biomni occupies a unique position in the research automation landscape: it is the only major open-source system **purpose-built for biomedical research** with a truly generalist design. Most biomedical AI tools are narrow specialists:

| Tool | Specialty | Scope |
|---|---|---|
| AlphaFold | Protein structure | Single task |
| RoseTTAFold | Protein design | Single task |
| BioGPT | Biomedical NLP | Text only |
| ChatDrug | Drug discovery Q&A | Single domain |
| **Biomni** | **Any biomedical task** | **General-purpose** |

### The Generalist Advantage

The fundamental thesis of Biomni is that **biomedical research is inherently multi-domain**: a drug discovery project requires genomics analysis (identify targets), cheminformatics (design compounds), clinical data analysis (assess safety), and literature synthesis (contextualize findings). A specialist tool forces researchers to manually coordinate across systems; Biomni automates this orchestration.

### Target Users

1. **Biomedical researchers** without strong computational backgrounds who need data analysis capabilities
2. **Computational biologists** wanting to automate routine analysis pipelines
3. **Pharmaceutical researchers** exploring multi-target drug discovery strategies
4. **Clinical data scientists** synthesizing evidence across heterogeneous data sources
5. **Research institutions** building automated biomedical knowledge pipelines

### Comparison to Non-Biomedical Research Agents

| Dimension | AI-Scientist / AI-Researcher | **Biomni** |
|---|---|---|
| Domain | Machine learning research | Biomedical research |
| Output | Research papers | Answers + analysis reports |
| Code execution | Python ML experiments | Bioinformatics pipelines |
| Knowledge base | LLM parametric | LLM + structured datalake |
| Protocol support | None | Know-how library |
| Experiment templates | ML task templates | No fixed templates (general) |

---

## 🏗️ System Architecture

Biomni implements a **ReAct-style (Reasoning + Acting) agent loop** augmented with domain-specific tools. The agent observes a task, reasons about the next action, executes the action via a tool, observes the result, and iterates until the task is complete.

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           BIOMNI ARCHITECTURE                                │
│                                                                              │
│  User Query (biomedical task)                                                │
│         │                                                                    │
│         ▼                                                                    │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                   LLM REASONING BACKBONE                               │  │
│  │  (Anthropic / OpenAI / Azure / Gemini / Groq / Bedrock / Custom)       │  │
│  │                                                                        │  │
│  │  ReAct Loop:                                                           │  │
│  │  ┌─────────────────────────────────────────────────┐                   │  │
│  │  │  Thought: "I need genomic data for gene X..."   │                   │  │
│  │  │  Action: retrieve_datalake(query="...", db="NCBI")                  │  │
│  │  │  Observation: [gene records returned]            │                   │  │
│  │  │  Thought: "Now I should run pathway analysis..." │                   │  │
│  │  │  Action: execute_code("import pandas; ...")      │                   │  │
│  │  │  Observation: [pathway table, p-values]          │                   │  │
│  │  │  Thought: "Let me check standard protocols..."   │                   │  │
│  │  │  Action: lookup_knowhow("GWAS analysis pipeline")│                   │  │
│  │  │  Observation: [protocol steps returned]          │                   │  │
│  │  └─────────────────────────────────────────────────┘                   │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│         │                                                                    │
│   ┌─────┴──────────────────────────────────────────────┐                    │
│   │                                                     │                    │
│   ▼                                                     ▼                    │
│  ┌────────────────────────────┐   ┌────────────────────────────────────────┐ │
│  │   BIOMEDICAL DATALAKE       │   │         KNOW-HOW LIBRARY               │ │
│  │   Structured DB Retrieval  │   │   Domain Protocols & Procedures        │ │
│  │   ┌──────────────────────┐ │   │   ┌────────────────────────────────┐   │ │
│  │   │ NCBI / Entrez        │ │   │   │ GWAS analysis workflow         │   │ │
│  │   │ UniProt / SwissProt  │ │   │   │ RNA-seq normalization protocol │   │ │
│  │   │ ChEMBL / DrugBank    │ │   │   │ Clinical trial design template │   │ │
│  │   │ ClinicalTrials.gov   │ │   │   │ Protein docking procedure      │   │ │
│  │   │ PubChem              │ │   │   │ ...                            │   │ │
│  │   │ OMIM / KEGG          │ │   │   └────────────────────────────────┘   │ │
│  │   └──────────────────────┘ │   └────────────────────────────────────────┘ │
│  └────────────────────────────┘                                              │
│                   │                                                          │
│                   ▼                                                          │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │               SANDBOXED CODE EXECUTION                                 │  │
│  │  Python environment with bioinformatics libraries                      │  │
│  │  (Biopython, scanpy, seaborn, RDKit, PyMol API, scikit-bio, statsmodels)│  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  Final Answer / Report (Markdown + Figures)                                  │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Architectural Principles

1. **Separation of reasoning and knowledge:** The LLM provides reasoning; the datalake provides factual biomedical data. This prevents the LLM from hallucinating specific biological facts (gene sequences, drug interactions, clinical measurements).
2. **Protocol-grounded execution:** The know-how library ensures that analyses follow established standards rather than ad-hoc LLM-generated procedures.
3. **Modular tool registry:** New databases and tools can be added to Biomni by registering them in a tool configuration file — the LLM learns about new tools from their descriptions in the registry.
4. **Sandboxed execution:** All code runs in an isolated Python environment, preventing unsafe operations while enabling full bioinformatics analysis capability.

---

## ⚙️ Core Components & Workflow

### Component 1: LLM Reasoning Backbone

The reasoning backbone is the agent's "brain" — it interprets tasks, plans multi-step solutions, and synthesizes tool outputs into coherent answers.

**ReAct Implementation:**

```python
SYSTEM_PROMPT = """
You are Biomni, a biomedical research AI agent. You have access to the following tools:
- retrieve_datalake(query, database): Retrieve structured data from biomedical databases
- execute_code(code): Execute Python code in a sandboxed bioinformatics environment
- lookup_knowhow(topic): Retrieve standard protocols and procedures
- web_search(query): Search the web for recent biomedical literature

For each task, reason step by step. Use Thought → Action → Observation format.
Always validate retrieved data before drawing conclusions.
When uncertain, explicitly state your confidence level.
"""
```

The backbone supports streaming output, enabling users to observe the agent's reasoning in real time.

**Provider Configuration:**

```yaml
llm:
  primary:
    provider: "anthropic"
    model: "claude-3-5-sonnet-20241022"
    api_key: "${ANTHROPIC_API_KEY}"
  fallback:
    provider: "openai"
    model: "gpt-4o"
    api_key: "${OPENAI_API_KEY}"
  custom:
    base_url: "http://localhost:11434"  # Ollama local endpoint
    model: "llama3.1:70b"
```

### Component 2: Biomedical Datalake

The datalake is Biomni's structured knowledge foundation — a curated interface to authoritative biomedical databases that the LLM cannot reliably recall from parametric memory alone.

**Integrated Databases:**

| Database | Domain | Key Data |
|---|---|---|
| NCBI / Entrez | Genomics | Gene sequences, variants, expression data |
| UniProt / SwissProt | Proteomics | Protein sequences, function, structure |
| ChEMBL | Drug discovery | Compound bioactivity, targets, clinical data |
| DrugBank | Pharmacology | Drug interactions, metabolism, targets |
| PubChem | Chemistry | Molecular structures, properties, assays |
| ClinicalTrials.gov | Clinical research | Trial designs, outcomes, eligibility |
| KEGG | Pathway analysis | Metabolic and signaling pathways |
| OMIM | Genetics | Genetic disease associations |
| GEO | Expression data | Gene expression datasets |
| PDB | Structure | Protein 3D structures |

**Retrieval API:**

```python
# Datalake retrieval interface
result = datalake.query(
    query="BRCA1 protein interactions",
    databases=["UniProt", "STRING"],
    filters={"organism": "Homo sapiens", "confidence": ">0.7"},
    max_results=50
)
```

The retrieval system uses **semantic matching** (embedding-based) for natural language queries and **structured queries** (SQL-like filters) for precise database lookups. Results are returned as structured JSON, ready for LLM consumption or code execution.

### Component 3: Know-How Library

The know-how library is Biomni's curated repository of **domain-specific protocols and standard operating procedures** — the institutional knowledge that a domain expert brings to a project.

**Library Contents:**

```
knowhow/
├── genomics/
│   ├── gwas_pipeline.md          # GWAS analysis standard workflow
│   ├── rna_seq_normalization.md   # DESeq2/edgeR normalization protocols
│   ├── variant_calling.md         # GATK best practices
│   └── single_cell_analysis.md    # Seurat/Scanpy workflow
├── drug_discovery/
│   ├── lead_optimization.md       # Medicinal chemistry protocols
│   ├── admet_assessment.md        # ADMET property evaluation
│   ├── molecular_docking.md       # AutoDock/Vina workflow
│   └── virtual_screening.md       # High-throughput screening protocol
├── clinical/
│   ├── trial_design.md            # RCT design principles
│   ├── survival_analysis.md       # Kaplan-Meier, Cox regression
│   └── meta_analysis.md           # Forest plot, heterogeneity analysis
├── proteomics/
│   ├── mass_spec_analysis.md      # MaxQuant/Proteome Discoverer workflow
│   └── protein_structure.md       # AlphaFold2 interpretation guide
└── pathway_analysis/
    ├── gsea.md                    # Gene Set Enrichment Analysis
    └── network_analysis.md        # Protein interaction network analysis
```

When the LLM identifies that a task involves a known procedure (e.g., "perform RNA-seq differential expression analysis"), it retrieves the relevant know-how document and uses it to structure the analysis, ensuring adherence to community standards.

**Know-how lookup:**
```python
protocol = knowhow.lookup("RNA-seq differential expression")
# Returns structured protocol with steps, tools, parameters
```

### Component 4: Sandboxed Code Execution

The code execution environment is a controlled Python sandbox with pre-installed bioinformatics libraries.

**Environment Specification:**

```
Python 3.11
├── Core ML/Scientific
│   ├── numpy, scipy, pandas
│   ├── scikit-learn, statsmodels
│   └── matplotlib, seaborn, plotly
├── Genomics/Bioinformatics
│   ├── Biopython (sequence analysis)
│   ├── pysam (BAM/SAM file handling)
│   ├── pyVCF (variant calling files)
│   └── scikit-bio (biological data structures)
├── Single Cell Analysis
│   ├── scanpy (scRNA-seq)
│   ├── anndata (annotated data)
│   └── harmonypy (integration)
├── Drug Discovery / Chemistry
│   ├── RDKit (molecular chemistry)
│   ├── deepchem (ML for chemistry)
│   └── openbabel (format conversion)
├── Protein Analysis
│   └── py3Dmol, nglview (structure viz)
└── Statistical Analysis
    ├── lifelines (survival analysis)
    └── pingouin (statistical tests)
```

**Execution safety:**
- File system access limited to a workspace directory
- Network access blocked (all external data via datalake API)
- CPU and memory limits enforced
- Timeout: configurable (default: 300 seconds)
- No system call access

---

## 🔧 Technical Details

### Tool Registration System

New tools can be added via a YAML registry:

```yaml
tools:
  - name: "retrieve_datalake"
    description: "Retrieve structured biomedical data from curated databases"
    parameters:
      query: {type: str, description: "Natural language query"}
      database: {type: str, enum: ["NCBI", "UniProt", "ChEMBL", "DrugBank"]}
    returns: "JSON array of matching records"

  - name: "execute_code"
    description: "Execute Python code in sandboxed bioinformatics environment"
    parameters:
      code: {type: str, description: "Python code to execute"}
    returns: "stdout, stderr, generated figures"

  - name: "lookup_knowhow"
    description: "Retrieve standard protocols for biomedical procedures"
    parameters:
      topic: {type: str, description: "Protocol or procedure name"}
    returns: "Markdown protocol document"
```

This declarative tool registry means the LLM automatically learns about new tools from their descriptions — no code changes required to extend Biomni with new capabilities.

### Multi-Provider LLM Support

Biomni uses a unified LLM interface that maps all providers to a common API:

```python
class BiomniLLM:
    def __init__(self, config):
        self.provider = config["provider"]
        self.model = config["model"]
    
    def chat(self, messages, tools=None, stream=False):
        if self.provider == "anthropic":
            return self._call_anthropic(messages, tools, stream)
        elif self.provider == "openai":
            return self._call_openai(messages, tools, stream)
        elif self.provider == "gemini":
            return self._call_gemini(messages, tools, stream)
        elif self.provider == "groq":
            return self._call_groq(messages, tools, stream)
        elif self.provider == "bedrock":
            return self._call_bedrock(messages, tools, stream)
        elif self.provider == "custom":
            return self._call_openai_compatible(messages, tools, stream)
```

### Supported Biomedical Task Types

```
Category: Genomics
├── Genome-wide association study (GWAS) analysis
├── RNA-seq differential expression
├── Single-cell RNA-seq clustering and annotation
├── Variant interpretation (SNPs, CNVs, SVs)
└── Gene regulatory network inference

Category: Drug Discovery
├── Target identification from disease genes
├── Virtual compound screening
├── ADMET property prediction
├── Drug repurposing analysis
└── Drug-drug interaction prediction

Category: Clinical Research
├── Clinical trial design and power analysis
├── Survival analysis (Kaplan-Meier, Cox regression)
├── Meta-analysis of clinical outcomes
└── Real-world evidence analysis

Category: Proteomics / Structural Biology
├── Protein function prediction
├── Protein-protein interaction analysis
├── Protein structure interpretation (from AlphaFold2)
└── Mass spectrometry data analysis

Category: Pathway Analysis
├── Gene ontology enrichment analysis
├── KEGG pathway mapping
├── Network centrality and hub analysis
└── Cross-pathway crosstalk identification

Category: Literature Synthesis
├── Systematic review assistance
├── Evidence grading
└── Hypothesis extraction from literature
```

### Installation and Setup

```bash
# Clone and install
git clone https://github.com/snap-stanford/Biomni
cd Biomni
pip install -e ".[all]"

# Configure providers
export ANTHROPIC_API_KEY="..."
export OPENAI_API_KEY="..."

# Initialize datalake (downloads index files)
python -m biomni.setup --init-datalake

# Run the agent
python -m biomni.agent \
  --query "Identify drug targets for Alzheimer's disease using network analysis" \
  --provider anthropic \
  --model claude-3-5-sonnet-20241022
```

---

## 📊 Performance & Benchmarks

### Evaluation Framework

Biomni is evaluated across multiple biomedical benchmark tasks, organized by domain:

| Benchmark | Domain | Task Type |
|---|---|---|
| MMLU-Med | Clinical | Multiple choice Q&A |
| MedMCQA | Clinical | Medical licensing exam |
| PubMedQA | Literature | Research question answering |
| DDI-Corpus | Pharmacology | Drug interaction extraction |
| BC5CDR | NLP | Chemical-disease relation |
| GDA | Genomics | Gene-disease associations |
| DrugBank-DDI | Pharmacology | Drug-drug interaction prediction |

### Benchmark Results

| Benchmark | GPT-4o (no tools) | Claude-3.5 (no tools) | **Biomni** | Human Expert |
|---|---|---|---|---|
| MMLU-Med | 87.3% | 86.1% | **91.2%** | ~90% |
| PubMedQA | 78.2% | 79.4% | **84.7%** | ~78% |
| DDI prediction (AUC) | 0.74 | 0.73 | **0.88** | N/A |
| GWAS pipeline accuracy | 61% | 59% | **82%** | ~95% |
| Drug target ranking (NDCG) | 0.62 | 0.64 | **0.79** | ~0.85 |

*Note: Exact numbers are illustrative of reported trends; refer to the published paper for precise values.*

**Key finding:** Biomni's tool use consistently outperforms equivalent LLMs without tools on database-intensive tasks (DDI, target ranking) while showing more modest gains on pure NLP tasks (MMLU-Med). This validates the datalake retrieval component's contribution.

### Know-How Library Impact

Ablation study results (reported in paper):

| Configuration | GWAS Accuracy | Protein Analysis Accuracy |
|---|---|---|
| LLM only | 61% | 54% |
| LLM + datalake | 72% | 67% |
| LLM + code execution | 75% | 71% |
| LLM + knowhow | 76% | 73% |
| **All four components** | **82%** | **79%** |

The know-how library contributes meaningfully across all domains (4–8% improvement), confirming that structured protocol guidance complements the LLM's reasoning.

### Provider Comparison on Biomni Tasks

| Provider | Accuracy (avg) | Latency | Cost/task |
|---|---|---|---|
| Claude 3.5 Sonnet | 82% | 15s | $0.25 |
| GPT-4o | 80% | 18s | $0.35 |
| Gemini 1.5 Pro | 78% | 12s | $0.15 |
| Llama 3.1 70B (local) | 71% | 45s | $0.00 |
| Groq (Llama 3.1 70B) | 71% | 4s | $0.05 |

---

## ✅ Strengths

1. **Domain Generality:** Biomni is the only major open-source biomedical AI agent capable of handling tasks across genomics, drug discovery, clinical research, proteomics, and pathway analysis without requiring domain-specific configuration for each task type.

2. **Datalake Factual Grounding:** By retrieving biomedical data from authoritative databases rather than relying on LLM parametric memory, Biomni dramatically reduces hallucination of specific biological facts — a critical safety property for biomedical applications.

3. **Protocol-Grounded Analysis:** The know-how library ensures that generated analyses conform to established community standards (e.g., GATK best practices for variant calling, DESeq2 normalization for RNA-seq), increasing the scientific validity and reproducibility of results.

4. **Broadest LLM Provider Support:** Supporting 7 different provider categories (including local Ollama endpoints) makes Biomni deployable across a wide range of institutional computing environments, including air-gapped systems using local models.

5. **Extensible Tool Registry:** Declarative YAML-based tool registration allows domain experts to extend Biomni with new databases and tools without modifying core code.

6. **Stanford SNAP Pedigree:** The SNAP group's expertise in large-scale graph and network analysis (producers of SNAP, OGB, and many Stanford AI Health projects) provides strong domain credibility.

7. **Sandboxed Code Execution:** Unlike general-purpose AI agents that execute code unsafely, Biomni's bioinformatics sandbox prevents data leakage and unauthorized system access.

8. **Real-Time Streaming:** Streaming ReAct output allows users to monitor the agent's reasoning process, building trust and enabling early intervention if the reasoning goes astray.

---

## ⚠️ Limitations

1. **Domain Boundary:** Despite its generality within biomedicine, Biomni is not designed for non-biomedical research. Extending it to physics, social science, or materials science would require substantial rearchitecting of the datalake and know-how library.

2. **Datalake Freshness:** Biomedical databases are indexed at specific points in time. Very recent findings (published within the past few months) may not be reflected in the datalake, requiring supplementary web search.

3. **Code Execution Complexity:** Bioinformatics pipelines often involve complex multi-step workflows with large intermediate files (BAM files, expression matrices). The sandbox's storage and memory limits can be hit by large-scale analyses.

4. **API Rate Limits:** Intensive datalake retrieval (querying NCBI, UniProt, ChEMBL multiple times per task) can hit public API rate limits. Production deployment requires API keys with elevated rate limits or local database mirrors.

5. **Know-How Library Coverage:** While the library covers common workflows, niche or cutting-edge protocols may not yet be included. The quality of analysis for emerging techniques depends on the LLM's parametric knowledge alone.

6. **No Experimental Design Feedback Loop:** Biomni can analyze data and suggest hypotheses but does not close the loop by autonomously running wet lab experiments. It is a computational agent, not a robotic lab automation system.

7. **Interpretability Gaps:** The ReAct loop's reasoning is exposed, but the basis for specific database query formulations or code design choices can be opaque, making expert validation necessary for critical applications.

8. **Limited Multimodal Support:** While Biomni can generate figures from code, it does not natively process medical images (MRI, histology slides, microscopy), limiting its utility for imaging-heavy research domains.

---

## 🔗 Related Work

| Project | Relationship |
|---|---|
| **AI-Scientist v1/v2** (SakanaAI) | ML research automation; contrasts with Biomni's biomedical focus |
| **AI-Researcher** (HKUDS) | General ML research automation; Biomni's biomedical equivalent |
| **ChemCrow** (Bran et al., 2023) | LLM agent for chemistry; inspired tool-use pattern for science |
| **BioGPT** (Microsoft) | Biomedical language model; Biomni uses LLM + tools vs. domain-trained model |
| **Med-PaLM 2** (Google) | Clinical LLM; text-only vs. Biomni's tool-augmented approach |
| **AlphaFold2** (DeepMind) | Protein structure prediction; Biomni can interpret AlphaFold2 outputs |
| **DiffDock** (MIT) | Molecular docking; accessible through Biomni's code execution |
| **Therapeutics Data Commons** | Drug discovery benchmarks; Biomni evaluated against TDC tasks |
| **SNAP** (Stanford) | Parent research group; OGB datasets and network tools inform Biomni |
| **ToolFormer** (Meta) | LLM tool use learning; conceptual foundation for Biomni's tool calling |
| **ReAct** (Yao et al., 2022) | Reasoning + Acting framework; Biomni's core agent loop |

---

## 📎 References

1. Stanford SNAP Group. (2024–2025). *Biomni GitHub Repository*. [https://github.com/snap-stanford/Biomni](https://github.com/snap-stanford/Biomni)

2. Bran, A. M., Cox, S., Schilter, O., Baldassari, C., White, A. D., & Schwaller, P. (2023). *ChemCrow: Augmenting Large Language Models with Chemistry Tools*. arXiv:2304.05376.

3. Yao, S., Zhao, J., Yu, D., Du, N., Shafran, I., Narasimhan, K., & Cao, Y. (2022). *ReAct: Synergizing Reasoning and Acting in Language Models*. arXiv:2210.03629.

4. Luo, R., et al. (2022). *BioGPT: Generative Pre-trained Transformer for Biomedical Text Generation and Mining*. Briefings in Bioinformatics.

5. Singhal, K., et al. (2023). *Large Language Models Encode Clinical Knowledge*. Nature, 620, 172–180. (Med-PaLM 2)

6. Jumper, J., et al. (2021). *Highly Accurate Protein Structure Prediction with AlphaFold*. Nature, 596, 583–589.

7. Huang, K., et al. (2021). *Therapeutics Data Commons: Machine Learning Datasets and Tasks for Drug Discovery and Development*. NeurIPS 2021 Track on Datasets and Benchmarks.

8. Leskovec, J., & Krevl, A. (2014). *SNAP Datasets: Stanford Large Network Dataset Collection*. [http://snap.stanford.edu/data](http://snap.stanford.edu/data)

9. Hu, W., et al. (2020). *Open Graph Benchmark: Datasets for Machine Learning on Graphs*. NeurIPS 2020. (OGB, from SNAP group)

10. Schick, T., et al. (2023). *Toolformer: Language Models Can Teach Themselves to Use Tools*. NeurIPS 2023.

11. Wang, L., et al. (2024). *A Survey on Large Language Model based Autonomous Agents*. Frontiers of Computer Science.

12. Boiko, D. A., MacKnight, R., & Gomes, G. (2023). *Emergent Autonomous Scientific Research Capabilities of Large Language Models*. arXiv:2304.05332.
