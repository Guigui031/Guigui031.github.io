---
title: "Preventing Electricity Demand Rebound with Multi-CPP"
description: "A two-level hierarchical control system using Model Predictive Control (MPC) and thermal RC models to prevent demand rebound peaks during Hydro-Québec's critical pricing events. Implements staggered Multi-CPP pricing across customer cohorts to achieve 19.3% peak demand reduction while maintaining thermal comfort."
pubDate: 2025-12-07
heroImage: "/MPC-spikes.png"
badge: ""
githubUrl: "https://github.com/Guigui031/HQ-Demand-Response-Optimization"
category: "machine-learning"
titleFr: "Prévention du rebond de la demande électrique avec Multi-CPP"
descriptionFr: "Un système de contrôle hiérarchique à deux niveaux utilisant le contrôle prédictif par modèle (MPC) et les modèles thermiques RC pour prévenir les pics de rebond de la demande lors des événements de tarification critique d'Hydro-Québec. Implémente une tarification Multi-CPP échelonnée entre les cohortes de clients pour obtenir une réduction de 19,3% de la demande de pointe tout en maintenant le confort thermique."
badgeFr: ""
contentFr: |
  # Prévention du rebond de la demande électrique avec Multi-CPP

  **Appliqué aux thermostats intelligents Hilo d'Hydro-Québec**

  *IFT6162: Apprentissage par renforcement et contrôle optimal*
  Guillaume Genois, Simon Langlois
  Université de Montréal | Mila – Institut québécois d'intelligence artificielle

  ## Vue d'ensemble du projet

  Ce projet implémente un **système de contrôle hiérarchique à deux niveaux** pour l'optimisation de la réponse à la demande en utilisant des modèles thermiques de résistance-capacitance (RC) et le contrôle prédictif par modèle (MPC). Le système s'attaque aux défis critiques de la demande de pointe hivernale d'Hydro-Québec en prévenant le phénomène de "rebond de la demande" qui se produit lorsque tous les clients répondent simultanément aux signaux de prix.

  Nous combinons **Multi-CPP (Multi-Critical Peak Pricing)** avec **des modèles thermiques RC agrégés** pour :
  - **Minimiser les coûts d'électricité des clients** tout en maintenant le confort thermique
  - **Réduire la demande de pointe d'Hydro-Québec** pendant les vagues de froid hivernales
  - **Prévenir les pics de rebond** grâce à des signaux de tarification échelonnés entre les cohortes de clients

  En utilisant des données agrégées de **96 bâtiments** sur **3 saisons hivernales**, notre approche Multi-CPP échelonnée atteint :

  | Métrique | Pic aligné | Pic échelonné (5 cohortes) | **Amélioration** |
  |----------|------------|----------------------------|------------------|
  | **Demande de pointe** | 39,70 kW | 32,04 kW | **-19,3%** |
  | **Ratio pointe-moyenne (PAR)** | 1,84 | 1,49 | **-19,0%** |
  | **95e percentile (P95)** | 34,34 kW | 30,08 kW | **-12,4%** |

  ## Le problème de la réponse à la demande

  ### Défi

  Hydro-Québec fait face à de graves pics de demande pendant les vagues de froid hivernales lorsque les charges de chauffage augmentent à travers la province. Pendant ces périodes critiques, le service public doit activer des unités de génération de pointe coûteuses ou acheter de l'électricité à des prix premium sur le marché pour répondre à la demande.

  ### Structure tarifaire Flex D

  Le **Tarif Flex D** d'Hydro-Québec crée des signaux de prix dramatiques pour inciter à la réduction de la demande :

  - **Heures creuses** : 4,774¢/kWh
  - **Événements de pointe** : 45,088¢/kWh (préavis de 24 heures)
  - **Fenêtres d'événement** : 6h-10h ou 16h-20h, pendant la saison hivernale

  **Multiplicateur de prix pendant les événements : ~9,5×**

  ### Le problème du pic de rebond

  Lorsque tous les clients répondent simultanément au même signal de prix :
  1. Tout le monde préchauffe avant l'événement → **pic pré-événement**
  2. Tout le monde réduit la consommation pendant l'événement → la demande chute
  3. Tout le monde reprend le chauffage après l'événement → **pic de rebond post-événement**

  ## Modélisation thermique : Réseaux RC

  Nous modélisons la dynamique thermique des bâtiments en utilisant des **réseaux Résistance-Capacitance (RC)** :

  ### Modèle 2R2C (deux états)

  **Dynamique de la température de la zone :**

  $$C_{\text{zone}} \frac{dT_{\text{zone}}}{dt} = \frac{T_{\text{wall}} - T_{\text{zone}}}{R_{\text{zone,wall}}} + P_{\text{total}} + A_{\text{zone}} Q_{\text{solar}}$$

  **Dynamique de la température du mur :**

  $$C_{\text{wall}} \frac{dT_{\text{wall}}}{dt} = \frac{T_{\text{zone}} - T_{\text{wall}}}{R_{\text{zone,wall}}} + \frac{T_{\text{out}} - T_{\text{wall}}}{R_{\text{wall,out}}} + A_{\text{wall}} Q_{\text{solar}}$$

  ### Estimation des paramètres

  Nous employons trois approches complémentaires :
  1. **Régression en régime permanent** : Isole les périodes où dT/dt ≈ 0
  2. **Approximation par différences finies** : Approxime les dérivées ODE avec des différences finies
  3. **Multiple Shooting avec descente de gradient** : Minimise les résidus au carré en utilisant JAX avec Optax

  ## Contrôle prédictif par modèle (MPC)

  ### Fonction objectif du client

  Chaque bâtiment optimise sur un horizon glissant H :

  $$J = \Delta t \cdot \sum_{k=0}^{H-1} \left[ w_c \cdot (T_{\text{in}}[k] - T_{\text{sp}})^2 + w_e \cdot P_{\text{heat}}[k] \cdot \text{prix}[k] \right]$$

  **Composants :**
  - **Pénalité de confort** : $w_c \cdot (T_{\text{in}} - T_{\text{sp}})^2$
  - **Coût énergétique** : $w_e \cdot P_{\text{heat}} \cdot \text{prix}$

  ### Architecture hiérarchique à deux niveaux

  #### Niveau 1 : MPC au niveau du bâtiment
  - Utilise le modèle thermique 2R2C avec filtrage de Kalman
  - Optimise les coûts d'électricité individuels des clients
  - Maintient le confort thermique dans des limites acceptables

  #### Niveau 2 : Opérateur de réseau (coordination Multi-CPP)
  - Génère des **signaux de tarification de pointe échelonnés** entre 5 cohortes de clients
  - Chaque cohorte reçoit des événements de pointe à des moments différents
  - Prévient la réponse synchronisée à la demande
  - Réduit les pics de rebond agrégés

  ## Résultats

  ### Validation comportementale du MPC

  Malgré les limitations d'estimation des paramètres, notre contrôleur MPC **reproduit avec succès les modèles caractéristiques de réponse à la demande** observés dans le jeu de données réel Hilo. La simulation présente trois phases distinctes qui reflètent le comportement réel des clients.

  ### Réduction des pics Multi-CPP

  Après confirmation de l'alignement comportemental avec le cas de référence, nous avons implémenté une **tarification Multi-CPP échelonnée** entre 5 cohortes de clients. Chaque cohorte reçoit des signaux de tarification de pointe décalés dans le temps, empêchant une réponse synchronisée à la demande.

  | Métrique | Pic aligné | Pic échelonné (5 cohortes) | **Réduction** |
  |----------|------------|----------------------------|---------------|
  | **Demande de pointe** | 39,70 kW | 32,04 kW | **-19,3%** |
  | **Ratio pointe-moyenne (PAR)** | 1,84 | 1,49 | **-19,0%** |
  | **95e percentile (P95)** | 34,34 kW | 30,08 kW | **-12,4%** |

  ### Inférence au système réel

  Puisque notre modèle RC démontre un **comportement qualitativement identique** au jeu de données réel Hilo (préchauffage, réponse à l'événement, timing du rebond), nous pouvons raisonnablement inférer que **Multi-CPP produirait des réductions de pic similaires sur le système réel**. La réduction de 19,3% de la demande de pointe représente une estimation conservatrice.

  ## Stack technique

  - **Python** : Langage de développement principal
  - **JAX** : Calcul différentiable pour l'optimisation
  - **Optax** : Optimisation de descente de gradient (Adam)
  - **NumPy/SciPy** : Calcul scientifique et optimisation
  - **Pandas** : Traitement et analyse des données
  - **Matplotlib** : Visualisation des résultats

  ## Développement

  Ce projet démontre :
  - **Conception de système de contrôle hiérarchique** : Architecture MPC à deux niveaux
  - **Modélisation thermique** : Réseaux RC pour la dynamique des bâtiments
  - **Optimisation de la réponse à la demande** : Tarification Multi-CPP pour la prévention des pics
  - **Analyse de données à grande échelle** : Données d'Hydro-Québec sur 96 bâtiments

  ## Directions futures

  Trois directions de recherche clés amélioreraient considérablement l'applicabilité pratique de ce travail :
  - **Amélioration de l'estimation des paramètres** : Développer un modèle RC opérationnel avec des paramètres acceptables
  - **Optimisation au niveau du réseau** : Étendre l'optimisation pour inclure les coûts de génération et les contraintes de transmission
  - **Tarification adaptative** : Implémenter des prix dynamiques qui s'ajustent en temps réel en fonction des conditions du réseau

  ## Références

  ### Source de données
  **Catalogue de données Hydro-Québec (2024)**
  "Consommation d'électricité des clients participant à un programme local de réponse à la demande"
  https://donnees.hydroquebec.com/

  ### Références académiques
  1. **Matteo Muratori & Giorgio Rizzoni (2015)** - Cadre Multi-CPP pour prévenir la synchronisation et les pics de rebond de la demande
  2. **Zhong Guo et al. (2018)** - Formulation de réseau RC et méthodologie d'estimation des paramètres
  3. **Costanza Saletti et al. (2022)** - Modélisation en boîte grise évolutive pour la gestion de la demande basée sur MPC
---

# Preventing Electricity Demand Rebound with Multi-CPP

**Applied To Hydro-Québec Hilo Smart Thermostats**

*IFT6162: Reinforcement Learning and Optimal Control*
Guillaume Genois, Simon Langlois
Université de Montréal | Mila – Quebec Artificial Intelligence Institute

## Project Overview

This project implements a **two-level hierarchical control system** for demand response optimization using thermal building resistance-capacitance (RC) models and Model Predictive Control (MPC). The system addresses Hydro-Québec's critical winter peak demand challenges by preventing the "demand rebound" phenomenon that occurs when all customers simultaneously respond to price signals.

We combine **Multi-CPP (Multi-Critical Peak Pricing)** with **aggregate RC thermal models** to:
- **Minimize client electricity costs** while maintaining thermal comfort
- **Reduce Hydro-Québec's peak demand** during winter cold snaps
- **Prevent rebound peaks** through staggered pricing signals across customer cohorts

Using aggregated data from **96 buildings** over **3 winter seasons**, our staggered Multi-CPP approach achieves:

| Metric | Aligned Peak | Staggered Peak (5 cohorts) | **Improvement** |
|--------|--------------|----------------------------|-----------------|
| **Peak Demand** | 39.70 kW | 32.04 kW | **-19.3%** |
| **Peak-to-Average Ratio (PAR)** | 1.84 | 1.49 | **-19.0%** |
| **95th Percentile (P95)** | 34.34 kW | 30.08 kW | **-12.4%** |

## The Demand Response Problem

### Challenge

Hydro-Québec faces severe demand spikes during winter cold snaps when heating loads surge across the province. During these critical periods, the utility must activate expensive peaking generation units or purchase power at premium market prices to meet demand. The challenge is particularly acute in Quebec, where space heating represents 54% of annual residential electricity consumption.

### Tarif Flex D Pricing Structure

Hydro-Québec's **Tarif Flex D** creates dramatic price signals to incentivize demand reduction:

- **Off-peak**: 4.774¢/kWh
- **Peak events**: 45.088¢/kWh (24-hour advance notice)
- **Event windows**: 6-10 AM or 4-8 PM, during winter season

**Price multiplier during events: ~9.5×**

### The Rebound Peak Problem

When all customers respond simultaneously to the same price signal:
1. Everyone pre-heats before the event → **pre-event spike**
2. Everyone reduces consumption during the event → demand drops
3. Everyone resumes heating after the event → **post-event rebound spike**

These new demand peaks, caused by everyone resuming heating at the same time, can sometimes be even greater than the original peak. Multi-CPP with staggered signals across 5 customer cohorts distributes demand response temporally.

## Dataset

### Source
**Hydro-Québec Data Catalogue**: "Electricity consumption of customers taking part in a local demand response program"
https://donnees.solutions.hydroquebec.com/

The dataset comes from customers participating in Hydro-Québec's Hilo Smart Thermostat energy-reduction program. It includes electricity consumption, indoor temperature, outdoor weather conditions, and timing of critical peak pricing events spanning 3 substations over 3 winter seasons.

### Observable Patterns

From real customer data, we observe:
- Energy consumption increases before events as customers pre-heat buildings
- Sharp reduction during critical event windows
- Post-event rebound spike as heating systems resume operation

## Thermal Modeling: RC Networks

We model building thermal dynamics using **Resistance-Capacitance (RC) networks**:

### 2R2C Model (Two-State)

**Zone Temperature Dynamics:**

$$C_{\text{zone}} \frac{dT_{\text{zone}}}{dt} = \frac{T_{\text{wall}} - T_{\text{zone}}}{R_{\text{zone,wall}}} + P_{\text{total}} + A_{\text{zone}} Q_{\text{solar}}$$

**Wall Temperature Dynamics:**

$$C_{\text{wall}} \frac{dT_{\text{wall}}}{dt} = \frac{T_{\text{zone}} - T_{\text{wall}}}{R_{\text{zone,wall}}} + \frac{T_{\text{out}} - T_{\text{wall}}}{R_{\text{wall,out}}} + A_{\text{wall}} Q_{\text{solar}}$$

**State Variables:**
- $T_{\text{zone}}$: Indoor air temperature (observable)
- $T_{\text{wall}}$: Thermal mass temperature (hidden state)

**Parameters:**
- $C_{\text{zone}}$, $C_{\text{wall}}$: Heat capacities (kJ/°C)
- $R_{\text{zone,wall}}$, $R_{\text{wall,out}}$: Thermal resistances (°C/kW)
- $A_{\text{zone}}$, $A_{\text{wall}}$: Solar aperture (m²)

### Parameter Estimation

We employ three complementary approaches:

1. **Steady-State Regression**: Isolates periods where `dT_zone/dt ≈ 0`, linear regression to estimate `R_zone`
2. **Finite Difference Approximation**: Approximates ODE derivatives with finite differences
3. **Multiple Shooting with Gradient Descent**: Minimizes squared residuals using **JAX** with **Optax** (Adam optimizer)

## Model Predictive Control (MPC)

### Client Objective Function

Each building optimizes over a receding horizon $H$:

$$J = \Delta t \cdot \sum_{k=0}^{H-1} \left[ w_c \cdot (T_{\text{in}}[k] - T_{\text{sp}})^2 + w_e \cdot P_{\text{heat}}[k] \cdot \text{price}[k] \right]$$

**Components:**
- **Comfort penalty**: $w_c \cdot (T_{\text{in}} - T_{\text{sp}})^2$ - quadratic cost for temperature deviation
- **Energy cost**: $w_e \cdot P_{\text{heat}} \cdot \text{price}$ - linear cost for electricity at time-varying prices

**Constraints:**
- Heating power: $0 \leq P_{\text{heat}} \leq 10$ kW
- Thermal dynamics: 2R2C state evolution
- Comfort bounds: typically $19°\text{C} \leq T_{\text{in}} \leq 22°\text{C}$

### State Estimation

We use a Kalman Filter to estimate the unobservable wall temperature in real-time. The approach models both process noise (randomness in system state evolution) and measurement noise (sensor uncertainty).

## Two-Level Hierarchical Architecture

### Level 1: Building-Level MPC (Client Optimization)
- Uses 2R2C thermal model with Kalman filtering
- Optimizes individual client electricity costs
- Maintains thermal comfort within acceptable bounds
- Exploits building thermal mass for energy shifting
- Responds to dynamic price signals

### Level 2: Grid Operator (Multi-CPP Coordination)
- Generates **staggered peak pricing signals** across 5 customer cohorts
- Each cohort receives peak events at different times
- Prevents synchronized demand response
- Reduces aggregate rebound peaks while maintaining individual incentives

## Results

### Parameter Estimation Challenges

Despite implementing multiple parameter estimation approaches (steady-state regression, finite differences, and multiple shooting), we were unable to reliably identify RC model parameters directly from the Hydro-Québec dataset. The optimization procedures either converged to physically unrealistic values or exhibited high sensitivity to initialization. We employed **physically plausible hand-tuned parameters** based on typical residential building characteristics from the literature.

### MPC Behavioral Validation

Despite the parameter estimation limitations, our MPC controller successfully **reproduces the characteristic demand response patterns** observed in the real Hilo dataset. The simulation exhibits three distinct phases that mirror actual customer behavior:

1. **Pre-event thermal charging**: MPC pre-heats building 1-2 hours before high-price period
2. **Event response**: Heating power reduced to minimum during peak pricing
3. **Post-event recovery**: Controlled heating ramp-up creates characteristic rebound spike

The key observation is that the MPC exhibits the **same demand response behavior** as the Hilo customers, including the problematic rebound peak, validating that our model captures the essential thermal-economic dynamics.

### Multi-CPP Peak Reduction

After confirming behavioral alignment, we implemented **staggered Multi-CPP pricing** across 5 customer cohorts. Each cohort receives peak pricing signals offset in time, preventing synchronized demand response. The aggregate energy demand profile becomes flattened under Multi-CPP.

| Metric | Aligned Peak | Staggered Peak (5 cohorts) | **Reduction** |
|--------|--------------|----------------------------|---------------|
| **Peak Demand** | 39.70 kW | 32.04 kW | **-19.3%** |
| **Peak-to-Average Ratio (PAR)** | 1.84 | 1.49 | **-19.0%** |
| **95th Percentile (P95)** | 34.34 kW | 30.08 kW | **-12.4%** |

### Inference to Real System

Since our RC model demonstrates **qualitatively identical behavior** to the real Hilo dataset (pre-heating, event response, rebound timing), we can reasonably infer that **Multi-CPP would produce similar peak reductions on the actual system**. The 19.3% peak demand reduction represents a conservative estimate based on behavioral pattern matching, identical economic incentives, and preserved fundamental physics.

### Current Limitations

- **Parameter estimation**: Unable to infer exact RC parameters from aggregate data
- **Unknown preferences**: Real client utility functions not directly observable
- **Event triggers**: Peak event decision criteria not fully characterized

### Future Directions

Three key research directions would improve practical applicability:
1. **Improved RC modeling**: Develop working model with acceptable parameters through better estimation methods or alternative frameworks
2. **Grid-level optimization**: Extend to include generation costs, transmission constraints, and distribution limits
3. **Adaptive pricing**: Implement dynamic pricing that adjusts based on real-time grid conditions and weather forecasts

## Technical Stack

- **Python**: Primary development language
- **JAX**: Differentiable computing for optimization
- **Optax**: Gradient descent optimization (Adam)
- **NumPy/SciPy**: Scientific computing and optimization
- **Pandas**: Data processing and analysis
- **Matplotlib**: Results visualization

## Development

This project demonstrates:
- **Hierarchical control system design**: Two-level MPC architecture
- **Thermal modeling**: RC networks for building dynamics
- **Demand response optimization**: Multi-CPP pricing for peak prevention
- **Large-scale data analysis**: Hydro-Québec data across 96 buildings

## Future Applications

The hierarchical MPC framework and Multi-CPP strategy can be applied to:
- **Residential demand response programs**: Preventing rebound peaks in large-scale deployments
- **Commercial building optimization**: Energy cost reduction for office buildings and industrial facilities
- **Electric vehicle charging**: Coordinating EV charging to avoid grid stress
- **Renewable energy integration**: Using thermal storage to balance intermittent generation

## References

### Data Source
**Hydro-Québec Data Catalogue (2024)**
"Electricity consumption of customers taking part in a local demand response program"
https://donnees.hydroquebec.com/

### Academic References
1. **Matteo Muratori & Giorgio Rizzoni (2015)** - Multi-CPP framework to prevent demand synchronization and rebound peaks
2. **Zhong Guo et al. (2018)** - RC network formulation and parameter estimation methodology for aggregate building models
3. **Costanza Saletti et al. (2022)** - Scale-free gray-box modeling for MPC-based demand side management in large-scale systems
