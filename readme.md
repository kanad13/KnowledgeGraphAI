# KnowledgeGraphAI

## project purpose and goals

- the code in this repository aims to showcase how
  - data from a legacy relational database can be transformed into a knowledge graph in Neo4j, and
  - enriched with AI capabilities for enhanced data retrieval and natural language processing

## tools involved

- **infrastructure**
  - `Docker`: for MySQL, Neo4J containers
  - `Kubernetes`: for container orchestration
  - `Terraform/Helm`: Infrastructure as Code tools for deployment
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
  - setup local Kubernetes cluster
  - deploy MySQL and Neo4j containers
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

- [Neo4j Knowledge Graph Blog](https://neo4j.com/blog/what-is-knowledge-graph/)
- [Knowledge Graph RAG Application](https://neo4j.com/developer-blog/knowledge-graph-rag-application/)
- [LLM Graph Builder GitHub](https://github.com/neo4j-labs/llm-graph-builder)
- [Neo4j LLM Knowledge Graph Builder](https://neo4j.com/labs/genai-ecosystem/llm-graph-builder/)
- [LangChain Documentation](https://python.langchain.com/v0.1/docs/use_cases/graph/constructing/)
