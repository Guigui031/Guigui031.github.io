---
title: "Indefinite Autonomous Navigation in DuckieTown"
description: "A robust hierarchical control system enabling autonomous vehicles to navigate indefinitely through DuckieTown intersections without traffic lights. Implements adaptive stop line detection, AprilTag-based alignment, trajectory generation, and LED-based V2V communication for future multi-robot coordination."
pubDate: 2025-12-15
heroImage: "/nav-duckietown.png"
badge: ""
githubUrl: "https://github.com/Guigui031/Navigation-Robustified-for-DuckieTown"
category: "other"
titleFr: "Navigation autonome infinie dans DuckieTown"
descriptionFr: "Un système de contrôle hiérarchique robuste permettant aux véhicules autonomes de naviguer indéfiniment à travers les intersections DuckieTown sans feux de circulation. Implémente la détection adaptative de lignes d'arrêt, l'alignement basé sur AprilTag, la génération de trajectoires et la communication V2V basée sur LED pour la future coordination multi-robots."
badgeFr: ""
contentFr: |
  # Navigation autonome indéfinie dans DuckieTown

  > Réaliser une conduite autonome indéfinie dans DuckieTown

  **Cours:** IFT6757 – Véhicules autonomes
  **Institution:** Université de Montréal
  **Date:** Décembre 2025

  **Auteurs:**
  - Firmin Chapoulie
  - Guillaume Genois
  - Mohamad Houdeib

  ## Énoncé du problème et motivation

  La navigation autonome dans des environnements structurés comme DuckieTown est souvent démontrée sur des scénarios finis : une carte fixe, une seule intersection ou un nombre limité de manœuvres. Cependant, la navigation indéfinie, où un robot peut continuellement conduire, traverser des intersections et revenir au suivi de voie sans réinitialisations manuelles, reste difficile en raison d'erreurs de perception accumulées, de transitions d'état instables et d'une gestion d'intersection peu fiable.

  L'objectif de ce projet est de permettre à un Duckiebot de conduire indéfiniment dans un environnement DuckieTown avec des intersections sans feux de circulation, en détectant de manière robuste les lignes d'arrêt, en interprétant les panneaux d'intersection, en planifiant des trajectoires et en revenant en toute sécurité au suivi de voie.

  Concrètement, nous nous concentrons sur le scénario LF-I_noTL (robot unique, pas de feux de circulation), qui nécessite :
  - Détection fiable des lignes d'arrêt
  - Identification correcte du type d'intersection
  - Traversée d'intersection sûre et stable
  - Changement d'état robuste pour éviter les blocages ou oscillations

  ## Travaux connexes

  Plusieurs efforts antérieurs ont abordé la gestion autonome des intersections :

  - **Dresner & Stone (2008)** ont proposé un système multi-agents basé sur des réservations où les véhicules négocient l'accès aux intersections via un protocole de demande/confirmation
  - **Azimi et al. (2013)** ont introduit des protocoles V2V distribués avec évitement de blocage, atteignant des améliorations significatives du débit dans des conditions sans fil réalistes

  Dans DuckieTown spécifiquement, des projets étudiants antérieurs ont exploré la communication basée sur LED utilisant la modulation de fréquence pour encoder les priorités aux intersections.

  ## Méthodologie et conception du système

  ### Architecture de haut niveau

  Notre travail consiste à étendre la pile d'autonomie standard de DuckieTown. Cette pile est un pipeline robuste de gestion d'intersection intégré dans une machine à états finis (FSM) :

  1. **Suivi de voie**
  2. **Détection de ligne d'arrêt**
  3. **Identification du type d'intersection**
  4. **Génération de trajectoire**
  5. **Contrôle d'intersection**
  6. **Retour au suivi de voie**

  ### Détection de ligne d'arrêt

  L'objectif du module de détection de ligne d'arrêt est d'identifier les lignes d'arrêt rouges sur la route et d'estimer la position du robot par rapport à elles. Le système reçoit en entrée un ensemble de segments de ligne rouge détectés par le pipeline de vision, ainsi que l'estimation de pose de voie `(d, φ)` fournie par le filtre de voie.

  Pour améliorer la robustesse de la détection, plusieurs techniques sont appliquées :
  - **Lissage médian** sur les estimations de distance récentes
  - **Hystérésis** avec des seuils séparés pour entrer et sortir de l'état de ligne d'arrêt
  - **Confirmation sur plusieurs images** pour éviter les faux positifs

  ### Arrêt adaptatif et contrôle d'intersection

  En approchant d'une ligne d'arrêt, le robot réduit progressivement sa vitesse en utilisant un facteur de décroissance basé sur la distance. La diminution est linéaire dans la zone de transition avec une vitesse finale nulle :

  $$
  f_{dec}(x) = {{x_{end}-x}\over{x_{end}-x_{start}}}
  $$

  Une fois arrêté, le contrôleur passe à un suiveur de trajectoire basé sur des points de passage. Les vitesses linéaire et angulaire sont calculées en utilisant des lois de contrôle proportionnel :

  $$
  \nu = k_{\rho}((x_{w} - x)cos(\theta)-(y_{w} - y)sin(\theta))
  $$
  $$
  \omega = k_{\alpha}[atan2((y_{w} - y), (x_{w} - x))-\theta]
  $$

  ### Génération de trajectoire

  Un défi clé était de s'assurer que les trajectoires générées respectent la géométrie de la voie, en particulier pour les virages à gauche. Une solution pratique que nous avons mise en œuvre était d'introduire un point de passage dans le processus de planification de trajectoire. Ce point aide à guider le robot plus loin dans l'intersection avant qu'il ne commence à tourner.

  De plus, nous avons ajusté le nombre de points de passage utilisés pour chaque manœuvre :
  - **Virages à gauche** : plus de points de passage pour la fluidité et la précision
  - **Virages à droite** : moins de points de passage, car ils nécessitent moins d'effort de direction

  ### Alignement basé sur AprilTag

  Pour améliorer la cohérence d'entrée dans l'intersection, nous avons développé un système d'alignement AprilTag qui oriente le robot perpendiculairement à la ligne d'arrêt avant l'exécution de la trajectoire.

  Lorsque le tag AprilTag cible n'est pas initialement visible, le robot effectue un balayage systématique :
  1. Rotation à gauche (~23°) et vérification du tag
  2. Retour au centre et vérification
  3. Rotation à droite (~23°) et vérification
  4. Retour au centre pour alignement final

  **Paramètres :**
  - `align_tag_tolerance`: 0.15 rad (~8.6°) précision d'alignement
  - `align_tag_k`: 1.5 gain proportionnel pour le contrôle de rotation
  - `align_tag_omega_max`: 2.0 rad/s vitesse de rotation maximale
  - `align_tag_max_time`: 2.5s délai d'attente par tentative d'alignement

  ### Détection et filtrage robustes d'AprilTag

  Un défi critique dans la navigation d'intersection est d'identifier de manière fiable le bon AprilTag parmi plusieurs détections. Pour résoudre ce problème, nous avons implémenté un système de filtrage multi-critères qui sélectionne uniquement le tag le plus pertinent.

  Le système évalue chaque AprilTag détecté par rapport à trois contraintes spatiales :

  1. **Vérification de la perpendicularité** : La normale de surface du tag doit être approximativement face à la caméra
  2. **Angle de vue horizontal** : Pour s'assurer que le robot ne considère que les tags directement devant lui
  3. **Limites de distance** : Les tags en dehors d'une distance maximale configurable sont ignorés

  Seuls les tags satisfaisant toutes les contraintes géométriques sont considérés, et le tag valide le plus proche est sélectionné.

  ### Protocole de communication LED

  Pour les futurs scénarios multi-robots, nous avons implémenté un protocole de communication à 5 LED qui signale la priorité du robot et la direction prévue aux intersections.

  **Structure du tableau LED :** `[Avant Gauche, Arrière Gauche, Haut, Arrière Droite, Avant Droite]`

  - **Avant Gauche (LED 0) :** Niveau de priorité (1-4) encodé en couleur
  - **Avant Droite (LED 4) :** Direction ou état de préparation

  | Phase | LED 0 (Avant Gauche) | LED 4 (Avant Droite) | Signification |
  | :--- | :--- | :--- | :--- |
  | Approche / Arrêt | Couleur priorité | Couleur direction | Diffusion d'intention (Négociation) |
  | Validation (Prêt) | Couleur priorité | 🟩 | Scénario calculé, prêt à bouger |
  | Traversée | 🟨 | 🟨 | Occupation de l'intersection (Avertissement) |
  | Sortie | 🟩 | 🟩 | Intersection dégagée |
  | Inactif | 🔲 | 🔲 | Conduite normale / Pas de conflit |

  ## Résultats et leçons apprises

  Tout au long du développement, il est devenu clair que le réglage fin du système sur du matériel réel est beaucoup plus difficile qu'en simulation. Le projet a également révélé que les architectures de machines à états finis (FSM) peuvent être fragiles à moins que les transitions ne soient gérées avec soin et précision.

  **Leçons clés :**
  - Le réglage sur matériel réel est beaucoup plus difficile qu'en simulation
  - Les architectures FSM nécessitent une gestion prudente des transitions
  - Les incohérences de timing dans les nœuds ROS peuvent se propager et causer des échecs
  - L'utilisation cohérente des cadres de référence corrects est essentielle

  ## Travaux futurs

  Les extensions potentielles incluent :
  - Expériences réelles de navigation indéfinie multi-robots
  - Intégration de protocoles d'intersection spatio-temporels (par exemple, planification inspirée de STIP)
  - Amélioration de la robustesse de détection d'AprilTag dans des conditions d'éclairage variables
  - Implémentation de la coordination multi-agents basée sur LED

  ## Stack technique

  - **Python/ROS** : Développement principal et middleware robotique
  - **OpenCV** : Traitement d'image et détection de lignes
  - **AprilTag** : Détection et localisation de tags fiduciaires
  - **NumPy/SciPy** : Calcul scientifique et interpolation de trajectoires
  - **Duckietown SDK** : Infrastructure de simulation et de déploiement

  ## Développement

  Ce projet démontre :
  - **Conception de système de contrôle hiérarchique** : Architecture FSM pour navigation autonome
  - **Traitement de la vision** : Détection robuste de lignes d'arrêt et d'AprilTags
  - **Génération de trajectoires** : Planification de chemins SE(2) pour manœuvres d'intersection
  - **Protocoles de communication** : Communication V2V basée sur LED pour coordination future

  ## Références

  1. **Dresner, K., & Stone, P. (2008)** - Gestion d'intersection multi-agents basée sur réservation
  2. **Azimi, R., et al. (2013)** - Protocoles V2V distribués avec évitement de blocage
  3. **Paull, L., et al. (2017)** - Architecture de la plateforme Duckietown et pile d'autonomie
  4. **Censi, A., et al. (2019)** - Cadre éducatif pour la recherche en véhicules autonomes
  5. **Azimi, R., et al. (2014)** - Protocoles d'intersection spatio-temporels (STIP)
---

# Indefinite Autonomous Navigation in DuckieTown

> Achieving indefinite autonomous driving in DuckieTown

**Course:** IFT6757 – Autonomous Vehicles
**Institution:** Université de Montréal
**Date:** December 2025

**Authors:**
- Firmin Chapoulie
- Guillaume Genois
- Mohamad Houdeib

## Problem Statement & Motivation

Autonomous navigation in structured environments such as DuckieTown is often demonstrated on finite scenarios: a fixed map, a single intersection, or a limited number of maneuvers. However, indefinite navigation, where a robot can continuously drive, cross intersections, and return to lane following without manual resets, remains challenging due to accumulated perception errors, unstable state transitions, and unreliable intersection handling.

The objective of this project is to enable a Duckiebot to drive indefinitely in a DuckieTown environment with intersections without traffic lights, by robustly detecting stop lines, interpreting intersection signs, planning trajectories, and safely transitioning back to lane following.

Concretely, we focus on the LF-I_noTL scenario (single robot, no traffic lights), which requires:
- Reliable stop line detection
- Correct identification of intersection type
- Safe and stable intersection crossing
- Robust state switching to avoid deadlocks or oscillations

This work serves as a foundation toward multi-robot indefinite navigation (LF-IV), where decentralized coordination becomes necessary.

## Related Work

Several prior efforts have addressed autonomous intersection management:

- **Dresner & Stone (2008)** proposed a reservation-based multi-agent system where vehicles negotiate intersection access through a request/confirm protocol. While efficient, this approach assumes reliable communication and global coordination.
- **Azimi et al. (2013)** introduced distributed V2V protocols with deadlock avoidance, achieving significant throughput improvements under realistic wireless conditions.

In DuckieTown specifically, prior student projects explored LED-based communication using frequency modulation to encode priorities at intersections. While conceptually elegant, these approaches were limited by sensitivity to noise, unstable ROS node frequencies, and limited scalability (≤2 robots).

## Methodology & System Design

### High-Level Architecture

Our work extends the standard DuckieTown autonomy stack with a robust intersection-handling pipeline integrated into a finite state machine (FSM):

1. **Lane Following**
2. **Stop Line Detection**
3. **Intersection Type Identification**
4. **Trajectory Generation**
5. **Intersection Control**
6. **Return to Lane Following**

### Stop Line Detection

The goal of the stop line detection module is to identify red stop lines on the road and estimate the robot's position relative to them. The system receives as input a set of red line segments detected by the vision pipeline, along with the lane pose estimate `(d, φ)` provided by the lane filter.

To enhance detection robustness, several techniques are applied:
- **Median smoothing** over recent distance estimates to reduce outliers
- **Hysteresis** with separate thresholds for entering and exiting the stop line state to prevent rapid switching
- **Multi-frame confirmation** requiring consistent detection across multiple frames to avoid false positives

These combined strategies lead to a much more stable and reliable `at_stop_line` condition for state transitions.

### Adaptive Stop & Intersection Control

Upon approaching a stop line, the robot gradually reduces its velocity using a distance-based decay factor. The decrease is linear in the transition area with a null final speed:

$$
f_{dec}(x) = {{x_{end}-x}\over{x_{end}-x_{start}}}
$$

Where $x_{end}$ & $x_{start}$ define the transition area.

Once stopped, the controller switches to a waypoint-based trajectory follower. Linear and angular velocities are computed using proportional control laws in the robot frame:

$$
\nu = k_{\rho}((x_{w} - x)cos(\theta)-(y_{w} - y)sin(\theta))
$$
$$
\omega = k_{\alpha}[atan2((y_{w} - y), (x_{w} - x))-\theta]
$$

This decoupled control scheme allows smooth execution of complex intersection maneuvers.

### Trajectory Generation

A key challenge was ensuring that generated trajectories respect lane geometry, especially for left turns. The robot occasionally planned paths that drifted into the opposite lane.

A practical solution we implemented was to introduce a **via point** into the trajectory planning process. This via point helps guide the robot further into the intersection before it begins turning, ensuring that the path remains within the correct lane.

Additionally, we adjusted the number of waypoints used for each maneuver:
- **Left turns**: More waypoints for smoothness and precision
- **Right turns**: Fewer waypoints, as they require less steering effort

### Multi-Frame Trajectory Handling

A critical challenge in intersection navigation was managing multiple coordinate frames correctly. The implementation uses a stop-line-relative planning approach where waypoints are generated in the robot's coordinate frame at planning time, using the stop line pose as a stable reference.

**Planning Phase:**
1. The stop line pose is detected relative to the robot's current position
2. Canonical goal poses are defined in the stop-line coordinate frame for left, right, and straight maneuvers
3. The goal pose is transformed from the stop-line frame to the robot frame using SE(2) transformations
4. For left turns with via-point enabled, the trajectory is split into two segments
5. Waypoints are generated by interpolating along the trajectory using SE(2) Lie algebra interpolation
6. All waypoints are clamped to prevent planning behind the stop line

**Execution Phase:**
The waypoints generated during planning are tracked using dead reckoning from wheel encoders. The waypoint reaching logic is made robust by decomposing the robot's position error into along-track and cross-track components.

### AprilTag-Based Alignment

To improve intersection entry consistency, we developed an AprilTag alignment system that orients the robot perpendicular to the stop line before trajectory execution.

When approaching the intersection, the robot first detects the AprilTag on the intersection sign and determines its 3D pose. The system then calculates the required coordinate transformation and adjusts the robot's heading to face directly toward the tag.

When the target AprilTag is not initially visible, the robot performs a systematic scan:
1. Rotates left (~23°) and checks for tag
2. Returns to center and checks
3. Rotates right (~23°) and checks
4. Returns to center for final alignment

**Parameters:**
- `align_tag_tolerance`: 0.15 rad (~8.6°) alignment accuracy
- `align_tag_k`: 1.5 proportional gain for rotation control
- `align_tag_omega_max`: 2.0 rad/s maximum rotation speed
- `align_tag_max_time`: 2.5s timeout per alignment attempt

This pre-alignment improves trajectory following accuracy and reduces the robot's tendency to drift into opposing lanes during turns.

### Robust AprilTag Detection and Filtering

A critical challenge in intersection navigation is reliably identifying the correct AprilTag among multiple detections. To address this, we implemented a multi-criteria filtering system that selects only the most relevant tag for intersection identification.

The system evaluates each detected AprilTag against three spatial constraints:

1. **Perpendicularity Check**: The tag's surface normal must be roughly facing the camera, indicating head-on approach. Tags are rejected if the angle exceeds ±45° from perpendicular (`|dot_product| < 0.707`).

2. **Horizontal Viewing Angle**: The system calculates horizontal angle using `arctan2(pos.y, pos.x)` to ensure the robot only considers tags directly ahead, not those to the left or already passed.

3. **Distance Bounds**: Tags outside a configurable maximum distance are ignored. Among all valid tags, the **closest** one is selected.

Only tags satisfying all geometric constraints are considered, ensuring the robot responds to the immediate intersection rather than distant ones.

### LED Communication Protocol

For future multi-robot scenarios, we implemented a 5-LED communication protocol that signals robot priority and intended direction at intersections. Our protocol is based on SAE's J2735 standard basic safety messages.

**LED Array Structure:** `[Front Left, Rear Left, Top, Rear Right, Front Right]`

- **Front Left (LED 0):** Priority level (1-4) encoded as color
- **Front Right (LED 4):** Direction or ready state

| Phase | LED 0 (Front Left) | LED 4 (Front Right) | Meaning |
| :--- | :--- | :--- | :--- |
| Approach / Stop | Priority Color | Direction Color | Intent broadcasting (Negotiation) |
| Validation (Ready) | Priority Color | 🟩 | Scenario calculated, ready to move |
| Crossing | 🟨 | 🟨 | Occupying the intersection (Warning) |
| Exit | 🟩 | 🟩 | Intersection cleared |
| Idle | 🔲 | 🔲 | Normal driving / No conflict |

**FSM Integration:**
The LED system is integrated with the finite state machine, with custom patterns allowed during `STOP_SIGN_INTERSECTION` and `INTERSECTION_CONTROL` states. A 0.5s re-application timer ensures patterns persist despite FSM state transitions.

While not yet used for actual coordination, this protocol provides a foundation for future decentralized multi-robot intersection management.

## Results & Lessons Learned

Throughout development, it became clear that fine-tuning the system on real hardware is far more challenging than in simulation. The project revealed several key insights:

**Key Lessons:**
- Real hardware tuning is significantly more challenging than simulation
- Finite State Machine (FSM) architectures can be fragile unless transitions are carefully managed
- Even subtle timing inconsistencies in ROS nodes can propagate and cause system-wide failures
- Consistently using correct reference frames (robot vs. odometry) is absolutely essential for reliable navigation

**System Achievements:**
- Successfully demonstrated indefinite autonomous navigation through multiple intersections
- Robust stop line detection with hysteresis and multi-frame confirmation
- Accurate AprilTag-based alignment improving intersection entry consistency
- Smooth trajectory execution using via-point planning and SE(2) interpolation
- Foundation for multi-robot coordination through LED communication protocol

## Future Work

Potential extensions include:
- **Multi-robot indefinite navigation experiments**: Implement and test true multi-robot coordination using the LED communication protocol
- **Spatio-temporal intersection protocols**: Integrate STIP-inspired planning for efficient multi-vehicle intersection management
- **Improved AprilTag robustness**: Enhance detection under varying lighting conditions and camera motion blur
- **Learning-based trajectory optimization**: Use reinforcement learning to adapt trajectory parameters based on intersection geometry
- **Real-world deployment**: Extend beyond DuckieTown to scaled autonomous vehicles in structured environments

## Technical Stack

- **Python/ROS**: Primary development language and robotics middleware
- **OpenCV**: Image processing and line detection
- **AprilTag**: Fiducial marker detection and localization
- **NumPy/SciPy**: Scientific computing and trajectory interpolation
- **Duckietown SDK**: Simulation infrastructure and deployment tools

## Development

This project demonstrates:
- **Hierarchical control system design**: FSM architecture for autonomous navigation
- **Vision processing**: Robust stop line detection and AprilTag filtering
- **Trajectory generation**: SE(2) path planning for intersection maneuvers
- **Communication protocols**: LED-based V2V communication for future coordination
- **Real-world robotics**: Hardware integration and real-time control

## Applications

The indefinite navigation framework can be applied to:
- **Autonomous delivery robots**: Campus and warehouse environments with structured intersections
- **Smart city transportation**: Coordinated autonomous vehicles in urban grid networks
- **Agricultural robotics**: Autonomous tractors navigating orchard rows and intersection points
- **Manufacturing**: AGVs (Automated Guided Vehicles) in factory floor layouts

## References

1. **Dresner, K., & Stone, P. (2008)** - "A multiagent approach to autonomous intersection management." *Journal of Artificial Intelligence Research*, 31, 591-656. Proposed reservation-based multi-agent intersection management.

2. **Azimi, R., Bhatia, G., Rajkumar, R. R., & Mudalige, P. (2013)** - "Reliable intersection protocols using vehicular networks." *ACM/IEEE International Conference on Cyber-Physical Systems*. Introduced distributed V2V protocols with deadlock avoidance.

3. **Paull, L., et al. (2017)** - "Duckietown: An open, inexpensive and flexible platform for autonomy education and research." *IEEE ICRA*. Core Duckietown platform architecture.

4. **Censi, A., Paull, L., Tani, J., & Frazzoli, E. (2019)** - "The Duckietown Project: An Open Platform for Research and Education in Autonomy." Educational framework for autonomous vehicle research.

5. **Azimi, R., Bhatia, G., Rajkumar, R. R., & Mudalige, P. (2014)** - "STIP: Spatio-temporal intersection protocols for autonomous vehicles." *ACM/IEEE ICCPS*. Spatio-temporal intersection coordination framework.
