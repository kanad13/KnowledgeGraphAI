# KnowledgeGraphAI

## project purpose and goals

- the code in this repository aims to showcase how
  - data from a legacy relational database can be transformed into a knowledge graph in Neo4j, and
  - enriched with AI capabilities for enhanced data retrieval and natural language processing

## tools involved

- **infrastructure**
  - `Docker`: for MySQL, Neo4J containers
  - `Google Cloud`: for porting local application to the cloud
- **Databases**
  - `MySQL`: legacy relational database
  - `Neo4j`: graph database for knowledge graph creation
- **Frontend**
  - `Streamlit`: for building the frontend application
- **AI**
  - `OpenAI/Gemini/Llama`: large language models for query processing
  - `LangChain`: for integrating LLMs with the knowledge graph

## sequence of steps

- this section lists the sequence of steps that will be taken as part of this project:
  - clone this repository locally and setup development environment
  - deploy MySQL and Neo4j containers using docker compose
  - load sample data into MySQL
  - move data from MySQL to Neo4J
  - build the knowledge graph inside Neo4J
  - develop frontend application with Streamlit
  - setup connection to LLM
  - implement query handling
  - port tool to cloud

## installation and setup

- detailed steps on setting up the dev environment and other topics are available inside the [setup folder](./setup/)

## references

- [Knowledge Graphs - A Practical Review of the Research Landscape](/references/Knowledge_Graphs-A_Practical_Review.pdf)
- [Building Semantic Knowledge Graphs](/references/Building_Semantic_Knowledge_Graphs.pdf)
- [Knowledge Graphs - Research Paper](/references/Knowledge_Graphs-Research_paper.pdf)
- O'Reilly - Building Knowledge Graphs Practitioner's Guide [listing here](https://www.oreilly.com/library/view/building-knowledge-graphs/9781098127091/) and [direct book here](https://go.neo4j.com/rs/710-RRC-335/images/Building-Knowledge-Graphs-Practitioner%27s-Guide-OReilly-book.pdf)
- [Neo4j Knowledge Graph Blog](https://neo4j.com/blog/what-is-knowledge-graph/)
- [Knowledge Graph RAG Application](https://neo4j.com/developer-blog/knowledge-graph-rag-application/)
- [Neo4j & LLM Fundamentals](https://graphacademy.neo4j.com/courses/llm-fundamentals/)
- [Introduction to Vector Indexes and Unstructured Data](https://graphacademy.neo4j.com/courses/llm-vectors-unstructured/)
- [Building Neo4j Applications with Python](https://graphacademy.neo4j.com/courses/app-python/)
- [LLM Graph Builder GitHub](https://github.com/neo4j-labs/llm-graph-builder)
- [Neo4j LLM Knowledge Graph Builder](https://neo4j.com/labs/genai-ecosystem/llm-graph-builder/)
- [LangChain Documentation](https://python.langchain.com/v0.1/docs/use_cases/graph/constructing/)
- [Install Neo4J using Docker Compose](https://neo4j.com/docs/operations-manual/current/docker/introduction/)
