---
title: "Celebrity Cruises RAG Assistant"
description: "An intelligent conversational assistant for Celebrity Cruises information, powered by Retrieval-Augmented Generation (RAG). This system combines SQL database queries with vector store retrieval to answer questions about cruise availability, pricing, schedules, and general cruise information using LangGraph and LangChain."
pubDate: 2025-10-10
heroImage: "/cruise-rag-assistant.png"
badge: ""
# githubUrl: "https://github.com/Guigui031/AIAssistantWithRAG"
githubUrl: "https://rag.guillaume.genois.ca/"
category: "machine-learning"
titleFr: "Assistant RAG pour Celebrity Cruises"
descriptionFr: "Un assistant conversationnel intelligent pour les informations sur Celebrity Cruises, alimenté par la génération augmentée par récupération (RAG). Ce système combine des requêtes de base de données SQL avec la récupération de magasin vectoriel pour répondre aux questions sur la disponibilité des croisières, les prix, les horaires et les informations générales sur les croisières en utilisant LangGraph et LangChain."
badgeFr: ""
contentFr: |
  # Assistant RAG pour Celebrity Cruises

  Un assistant conversationnel intelligent pour les informations sur Celebrity Cruises, alimenté par la génération augmentée par récupération (RAG). Ce système combine des requêtes de base de données SQL avec la récupération de magasin vectoriel pour répondre aux questions sur la disponibilité des croisières, les prix, les horaires et les informations générales sur les croisières.

  ## Défi du projet

  ### Énoncé du problème
  - **Recherche d'information complexe** : Permettre aux utilisateurs d'interroger les données de croisières en langage naturel
  - **Sources de données hybrides** : Combiner des données structurées (SQL) et non structurées (documents)
  - **Intelligence contextuelle** : Acheminer automatiquement les requêtes vers la bonne source de données

  ## Architecture de la solution

  ### Système d'orchestration d'agents
  - **LangGraph** : Orchestration de workflow pour l'agent React
  - **Routage intelligent** : Détermine automatiquement s'il faut utiliser SQL ou la recherche de documents
  - **Mémoire basée sur les threads** : Maintient le contexte de conversation à travers les questions

  ### Développement de modèles

  #### Composants de récupération
  - **Base de données SQL (SQLite)** : Requêtes structurées pour les dates, prix, navires et itinéraires
  - **Magasin vectoriel (Chroma)** : Recherche sémantique sur les documents d'information sur les croisières
  - **Embeddings HuggingFace** : Modèle all-MiniLM-L6-v2 pour la représentation vectorielle

  #### Stratégie RAG
  - **Recherche hybride** : Combine les requêtes de base de données avec la recherche sémantique
  - **Streaming en temps réel** : Affiche le raisonnement de l'agent et l'utilisation des outils
  - **Conversation naturelle** : Gère les salutations, le chat informel et les requêtes complexes

  ## Implémentation technique

  ### Traitement et ingénierie des données
  - **Nettoyage des données** : Analyse et nettoyage des données brutes de croisières
  - **Création de champs de date** : Extraction de l'année, du mois et du jour des dates de départ
  - **Agrégation** : Regroupement des données par identifiant de croisière
  - **Stockage dual** : Export vers SQLite et fichiers texte pour la vectorisation

  ### Entraînement et configuration du modèle
  - **LLM (Groq)** : llama-3.3-70b-versatile pour la compréhension du langage naturel
  - **Prompts système** : Prompts personnalisés pour le comportement et le style de réponse de l'agent
  - **Gestion des outils** : Sélection et exécution automatiques d'outils (SQL vs recherche de documents)

  ## Résultats et performances

  ### Capacités du système
  - **Interface web** : Interface Gradio propre avec historique de conversation
  - **Interface CLI** : Interaction en ligne de commande avec visibilité des étapes de l'agent
  - **Déploiement** : Configuration Systemd et Nginx pour l'hébergement en production
  - **Traitement des requêtes** : Gestion réussie de requêtes complexes multi-tours

  ### Apprentissages clés
  - **Avantages de l'approche hybride** : La combinaison de SQL et de la recherche vectorielle offre les meilleurs résultats
  - **Conception de prompts** : Les prompts système soigneusement conçus améliorent la fiabilité de l'agent
  - **Chunking de documents** : La stratégie de chunking appropriée améliore la qualité de la récupération

  ## Stack technique

  - **Python** : Langage de développement principal
  - **LangChain** : Cadre pour les applications LLM
  - **LangGraph** : Orchestration d'agents et gestion de workflow
  - **Groq** : Inférence LLM rapide
  - **Chroma** : Base de données vectorielle pour la recherche sémantique
  - **HuggingFace** : Modèles d'embeddings
  - **Gradio** : Cadre d'interface utilisateur web
  - **SQLite** : Base de données relationnelle
  - **Pandas** : Traitement des données
  - **Nginx** : Proxy inverse pour le déploiement

  ## Développement

  Ce projet démontre :
  - **Conception de système RAG** : Architecture et implémentation de bout en bout
  - **Orchestration d'agents** : Utilisation de LangGraph pour des workflows complexes
  - **Recherche hybride** : Combinaison de bases de données structurées et de récupération vectorielle
  - **Déploiement en production** : Configuration complète d'hébergement

  ## Applications futures

  Le système RAG et le cadre d'agent développés peuvent être appliqués à :
  - **Centres d'appels d'entreprise** : Assistants automatisés de service client
  - **Support technique** : Bases de connaissances avec récupération intelligente
  - **Commerce électronique** : Recherche de produits et systèmes de recommandation
  - **Recherche académique** : Outils de recherche de littérature et de synthèse
---

# Celebrity Cruises RAG Assistant

An intelligent conversational assistant for Celebrity Cruises information, powered by Retrieval-Augmented Generation (RAG). This system combines SQL database queries with vector store retrieval to answer questions about cruise availability, pricing, schedules, and general cruise information.

## Project Challenge

### Problem Statement
- **Complex Information Retrieval**: Enable users to query cruise data using natural language
- **Hybrid Data Sources**: Combine structured (SQL) and unstructured (documents) data
- **Contextual Intelligence**: Automatically route queries to the right data source

## Solution Architecture

### Agent Orchestration System
- **LangGraph**: Workflow orchestration for React agent
- **Intelligent Routing**: Automatically determines whether to use SQL or document search
- **Thread-based Memory**: Maintains conversation context across questions

### Model Development

#### Retrieval Components
- **SQL Database (SQLite)**: Structured queries for dates, prices, ships, and itineraries
- **Vector Store (Chroma)**: Semantic search over cruise information documents
- **HuggingFace Embeddings**: all-MiniLM-L6-v2 model for vector representation

#### RAG Strategy
- **Hybrid Search**: Combines database queries with semantic search
- **Real-time Streaming**: Displays agent reasoning and tool usage
- **Natural Conversation**: Handles greetings, casual chat, and complex queries

## Technical Implementation

### Data Processing & Engineering
- **Data Cleaning**: Parsing and cleaning raw cruise data
- **Date Field Creation**: Extracting year, month, and day from sail dates
- **Aggregation**: Grouping data by cruise identifier
- **Dual Storage**: Export to SQLite and text files for vectorization

### Model Training & Configuration
- **LLM (Groq)**: llama-3.3-70b-versatile for natural language understanding
- **System Prompts**: Custom prompts for agent behavior and response style
- **Tool Management**: Automatic tool selection and execution (SQL vs document search)

## Results & Performance

### System Capabilities
- **Web Interface**: Clean Gradio interface with conversation history
- **CLI Interface**: Command-line interaction with agent step visibility
- **Deployment**: Systemd and Nginx configuration for production hosting
- **Query Handling**: Successfully handles complex multi-turn queries

### Key Learnings
- **Hybrid Approach Benefits**: Combining SQL and vector search provides best results
- **Prompt Design**: Carefully crafted system prompts improve agent reliability
- **Document Chunking**: Proper chunking strategy enhances retrieval quality

## Technical Stack

- **Python**: Primary development language
- **LangChain**: Framework for LLM applications
- **LangGraph**: Agent orchestration and workflow management
- **Groq**: Fast LLM inference
- **Chroma**: Vector database for semantic search
- **HuggingFace**: Embedding models
- **Gradio**: Web UI framework
- **SQLite**: Relational database
- **Pandas**: Data processing
- **Nginx**: Reverse proxy for deployment

## Development

This project demonstrates:
- **RAG System Design**: End-to-end architecture and implementation
- **Agent Orchestration**: Using LangGraph for complex workflows
- **Hybrid Search**: Combining structured database and vector retrieval
- **Production Deployment**: Complete hosting configuration

## Future Applications

The RAG system and agent framework developed can be applied to:
- **Business Call Centers**: Automated customer service assistants
- **Technical Support**: Knowledge bases with intelligent retrieval
- **E-commerce**: Product search and recommendation systems
- **Academic Research**: Literature search and synthesis tools
