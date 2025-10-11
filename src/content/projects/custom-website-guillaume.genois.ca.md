---
title: "Custom Portfolio Website"
description: "A modern, bilingual personal portfolio website built with Astro 4.x, TailwindCSS, and DaisyUI. Features include a blog system with content collections, dynamic projects showcase, interactive CV timeline, multilingual support (EN/FR), contact form with custom API integration, and fully responsive design optimized for all devices."
pubDate: 2024-12-01
heroImage: "/portfolio-website.png"
badge: ""
githubUrl: "https://github.com/Guigui031/Guigui031.github.io"
demoUrl: "https://guigui031.github.io/"
category: "web-development"
titleFr: "Site Web Portfolio Personnalisé"
descriptionFr: "Un site web portfolio personnel moderne et bilingue construit avec Astro 4.x, TailwindCSS et DaisyUI. Les fonctionnalités incluent un système de blog avec collections de contenu, une vitrine de projets dynamique, une chronologie CV interactive, le support multilingue (EN/FR), un formulaire de contact avec intégration API personnalisée, et un design entièrement responsive optimisé pour tous les appareils."
badgeFr: "Vedette"
contentFr: |
  # Site Web Portfolio Personnalisé

  Un site web portfolio personnel moderne construit avec Astro, TailwindCSS et DaisyUI, présentant mes projets, mon blog, mon CV et mes services avec un support bilingue complet.

  ## Aperçu du projet

  Ce site web portfolio représente ma présence professionnelle en ligne, construit à partir du template Astrofy et étendu avec des fonctionnalités personnalisées incluant le support multilingue, une intégration API de formulaire de contact personnalisée, et un système de gestion de contenu dynamique.

  ## Architecture et fonctionnalités

  ### Système de gestion de contenu

  #### Collections de contenu
  - **Collection Blog** : Articles techniques et billets de blog avec système de tags
  - **Collection Projets** : Vitrine de projets avec catégorisation et descriptions bilingues
  - **Collection Store** : Section store optionnelle pour services et produits
  - **Schémas TypeScript** : Collections définies par schéma avec validation Zod

  #### Contenu bilingue
  - **Support EN/FR** : Système complet de sélection de langue
  - **Champs localisés** : Titres, descriptions et contenu séparés pour chaque langue
  - **Commutation de langue** : Transitions fluides entre les versions linguistiques
  - **Persistance de préférence** : Mémorisation de la sélection de langue de l'utilisateur

  ### Fonctionnalités principales

  #### Section Portfolio
  - **Projets dynamiques** : Grille de cartes de projet responsive avec filtrage par catégorie
  - **Intégration GitHub** : Liens directs vers les dépôts de code source
  - **URLs de démo** : Liens de démonstration en direct pour les projets déployés
  - **Images Hero** : Images présentant les projets de manière visuellement attrayante
  - **Système de badges** : Mise en évidence de projets en vedette

  #### Chronologie CV
  - **Disposition de chronologie** : Présentation visuelle de l'historique de carrière et d'éducation
  - **Composants TimeLineElement** : Éléments de chronologie réutilisables
  - **Contenu enrichi** : Support pour HTML et markdown dans les entrées

  #### Système de blog
  - **Rendu Markdown** : Articles de blog écrits en Markdown
  - **Flux RSS** : Flux RSS auto-généré pour les abonnés
  - **Système de tags** : Pages filtrées par tags pour la découverte de contenu
  - **Pagination** : Génération de liste de billets paginée
  - **Image Hero** : Images d'en-tête pour chaque article

  #### Formulaire de contact
  - **Intégration API personnalisée** : Connexion avec API de formulaire backend personnalisée
  - **Validation** : Validation de formulaire côté client
  - **Messages de feedback** : Messages de succès/erreur pour les soumissions
  - **Conception responsive** : Expérience de formulaire mobile-first

  ## Implémentation technique

  ### Architecture du framework

  #### Configuration Astro
  - **Génération de site statique** : Build-time SSG pour des performances optimales
  - **Routing basé sur fichiers** : Organisation intuitive des pages
  - **Routes dynamiques** : Patterns [slug] et [...page] pour le contenu
  - **API Transitions** : Transitions de vue fluides entre les pages
  - **Configuration du site** : Site URL et métadonnées dans astro.config.mjs

  #### Système de layout
  - **BaseLayout** : Template principal avec sidebar et navigation
  - **PostLayout** : Layout spécialisé pour les articles de blog
  - **StoreItemLayout** : Layout pour les items de store
  - **Props sideBarActiveItemID** : État actif dynamique de la sidebar

  #### Structure de composants
  - **Cartes** : Card, HorizontalCard, HorizontalShopItem
  - **Navigation** : SideBar, SideBarMenu, SideBarFooter
  - **Header/Footer** : En-tête et pied de page cohérents
  - **BaseHead** : Gestion des métadonnées et SEO

  ### Stack de stylisation

  #### TailwindCSS
  - **Système utility-first** : Classes CSS composables
  - **Configuration personnalisée** : Couleurs et breakpoints étendus
  - **Plugin Typography** : Stylage automatique du contenu markdown
  - **Design responsive** : Approche mobile-first avec modificateurs breakpoint

  #### Bibliothèque de composants DaisyUI
  - **Composants pré-construits** : Boutons, cartes, modals stylisés
  - **Support de thème** : 30+ thèmes disponibles via data-theme
  - **Personnalisation** : Variables CSS pour l'adaptation du thème
  - **Classes mask** : Formes d'avatar personnalisées

  ### Configuration TypeScript

  - **Sécurité de type** : Configuration TypeScript stricte
  - **Alias de chemins** : Imports @components/*, @layouts/*
  - **Inférence de schéma** : Types générés à partir des schémas Zod
  - **Sécurité des props de composants** : Composants Astro typés

  ## Développement et déploiement

  ### Workflow de développement
  - **pnpm** : Gestionnaire de paquets rapide et efficace
  - **Serveur de dev** : Rechargement à chaud pour le développement rapide
  - **Construction de production** : Build statique optimisé
  - **Mode preview** : Test local des builds de production

  ### Génération de build
  - **Génération de sitemap** : Sitemap.xml auto-généré
  - **Flux RSS** : Feed XML pour les lecteurs de blog
  - **Optimisation d'assets** : Images optimisées et bundles de scripts
  - **Optimisation SEO** : Meta tags et données structurées

  ### Déploiement GitHub Pages
  - **Déploiement statique** : Hébergé sur GitHub Pages
  - **Actions GitHub** : Pipeline CI/CD automatisé
  - **Domaine personnalisé** : Configuré pour guillaume.genois.ca
  - **Déploiement de branches** : Déploiement automatique depuis la branche main

  ## Fonctionnalités personnalisées implémentées

  ### Sélection de langue
  - **Bouton de commutation** : Commutateur de langue dans la sidebar
  - **Persistance** : Sauvegarde de la préférence linguistique dans le stockage local
  - **Fallback** : Graceful fallback vers le contenu anglais
  - **Meta tags** : Tags hreflang appropriés pour le SEO

  ### Intégration API de formulaire
  - **Endpoint personnalisé** : API backend séparée pour les soumissions de formulaire
  - **Validation côté client** : Validation des champs de formulaire avant la soumission
  - **Gestion des erreurs** : Messages d'erreur gracieux
  - **Messages de succès** : Confirmation des soumissions réussies

  ### Système de projets
  - **Énumération de catégorie** : Catégorisation strictement typée des projets
  - **Filtrage de tags** : Filtrage de contenu basé sur les tags
  - **Liens externes** : Intégration GitHub et URLs de démo
  - **Contenu bilingue** : Champs FR séparés pour toutes les métadonnées

  ## Optimisation des performances

  ### Génération de site statique
  - **Temps de chargement rapides** : Pages HTML pré-rendues
  - **Zero JavaScript** : JS minimal envoyé au client
  - **Routing côté serveur** : Pas de routeur côté client nécessaire
  - **Mise en cache efficace** : Assets statiques facilement cachables

  ### Optimisation d'images
  - **Sharp** : Traitement d'image haute performance
  - **Images responsive** : Multiples tailles pour différents appareils
  - **Lazy loading** : Chargement d'images en dessous de la ligne de flottaison
  - **Formats modernes** : WebP et support AVIF

  ### Optimisation du bundle
  - **Splitting de code** : Petits bundles pour le chargement initial
  - **CSS minifié** : Taille de stylesheets réduite
  - **Élimination de code mort** : Arbre-secoué pour le JS inutilisé
  - **Préchargement d'assets** : Préchargement des ressources critiques

  ## Améliorations futures

  ### Fonctionnalités planifiées
  - **Recherche** : Recherche de contenu en texte intégral
  - **Mode sombre** : Commutateur de thème automatique
  - **Analytiques** : Suivi des visiteurs et métriques de contenu
  - **Newsletter** : Formulaire d'abonnement par email
  - **Commentaires** : Système de commentaires pour les articles de blog

  ### Améliorations potentielles
  - **MDX** : Composants interactifs dans les articles de blog
  - **Recherche par facettes** : Filtrage avancé de projets
  - **Vue transitions** : API View Transitions pour des animations fluides
  - **Offline support** : Fonctionnalité PWA avec service workers
  - **CMS headless** : Intégration pour la gestion de contenu non-technique

  ## Stack technique

  - **Astro 4.x** : Framework de site statique moderne
  - **TailwindCSS** : Framework CSS utility-first
  - **DaisyUI** : Bibliothèque de composants TailwindCSS
  - **TypeScript** : JavaScript typé statiquement
  - **Zod** : Validation de schéma TypeScript-first
  - **pnpm** : Gestionnaire de paquets rapide
  - **Marked** : Parser et renderer Markdown
  - **Sharp** : Traitement d'image haute performance
  - **Git** : Contrôle de version
  - **GitHub Pages** : Plateforme d'hébergement statique

  Ce projet démontre la capacité à construire des sites web modernes et performants avec des frameworks modernes tout en maintenant un excellent SEO, accessibilité et expérience utilisateur. La nature open-source du template Astrofy a fourni une excellente base pour la personnalisation et l'extension.
---

# Custom Portfolio Website

A modern personal portfolio website built with Astro, TailwindCSS, and DaisyUI, showcasing my projects, blog, CV, and services with full bilingual support.

## Project Overview

This portfolio website represents my professional online presence, built from the Astrofy template and extended with custom features including multilingual support, custom contact form API integration, and dynamic content management system.

## Architecture & Features

### Content Management System

#### Content Collections
- **Blog Collection**: Technical articles and blog posts with tagging system
- **Projects Collection**: Project showcase with categorization and bilingual descriptions
- **Store Collection**: Optional store section for services and products
- **TypeScript Schemas**: Schema-defined collections with Zod validation

#### Bilingual Content
- **EN/FR Support**: Complete language selection system
- **Localized Fields**: Separate titles, descriptions, and content for each language
- **Language Switching**: Smooth transitions between language versions
- **Preference Persistence**: Remembers user's language selection

### Core Features

#### Portfolio Section
- **Dynamic Projects**: Responsive project card grid with category filtering
- **GitHub Integration**: Direct links to source code repositories
- **Demo URLs**: Live demonstration links for deployed projects
- **Hero Images**: Visually appealing project showcase images
- **Badge System**: Featured project highlighting

#### CV Timeline
- **Timeline Layout**: Visual presentation of career and education history
- **TimeLineElement Components**: Reusable timeline entries
- **Rich Content**: Support for HTML and markdown in entries

#### Blog System
- **Markdown Rendering**: Blog posts written in Markdown
- **RSS Feed**: Auto-generated RSS feed for subscribers
- **Tag System**: Tag-filtered pages for content discovery
- **Pagination**: Paginated post list generation
- **Hero Images**: Header images for each post

#### Contact Form
- **Custom API Integration**: Connected to custom backend form API
- **Validation**: Client-side form validation
- **Feedback Messages**: Success/error messages for submissions
- **Responsive Design**: Mobile-first form experience

## Technical Implementation

### Framework Architecture

#### Astro Configuration
- **Static Site Generation**: Build-time SSG for optimal performance
- **File-Based Routing**: Intuitive page organization
- **Dynamic Routes**: [slug] and [...page] patterns for content
- **Transitions API**: Smooth view transitions between pages
- **Site Config**: Site URL and metadata in astro.config.mjs

#### Layout System
- **BaseLayout**: Main template with sidebar navigation
- **PostLayout**: Specialized layout for blog posts
- **StoreItemLayout**: Layout for store items
- **sideBarActiveItemID Props**: Dynamic sidebar active state

#### Component Structure
- **Cards**: Card, HorizontalCard, HorizontalShopItem
- **Navigation**: SideBar, SideBarMenu, SideBarFooter
- **Header/Footer**: Consistent header and footer
- **BaseHead**: SEO and metadata management

### Styling Stack

#### TailwindCSS
- **Utility-First System**: Composable CSS classes
- **Custom Configuration**: Extended colors and breakpoints
- **Typography Plugin**: Automatic markdown content styling
- **Responsive Design**: Mobile-first approach with breakpoint modifiers

#### DaisyUI Component Library
- **Pre-Built Components**: Styled buttons, cards, modals
- **Theme Support**: 30+ available themes via data-theme
- **Customization**: CSS variables for theme adaptation
- **Mask Classes**: Custom avatar shapes

### TypeScript Configuration

- **Type Safety**: Strict TypeScript configuration
- **Path Aliases**: @components/*, @layouts/* imports
- **Schema Inference**: Types generated from Zod schemas
- **Component Props Safety**: Typed Astro components

## Development & Deployment

### Development Workflow
- **pnpm**: Fast and efficient package manager
- **Dev Server**: Hot reloading for rapid development
- **Production Build**: Optimized static build
- **Preview Mode**: Local testing of production builds

### Build Generation
- **Sitemap Generation**: Auto-generated sitemap.xml
- **RSS Feed**: XML feed for blog readers
- **Asset Optimization**: Optimized images and script bundles
- **SEO Optimization**: Meta tags and structured data

### GitHub Pages Deployment
- **Static Deployment**: Hosted on GitHub Pages
- **GitHub Actions**: Automated CI/CD pipeline
- **Custom Domain**: Configured for guillaume.genois.ca
- **Branch Deployment**: Automatic deployment from main branch

## Custom Features Implemented

### Language Selection
- **Toggle Button**: Language switcher in sidebar
- **Persistence**: Saves language preference to local storage
- **Fallback**: Graceful fallback to English content
- **Meta Tags**: Proper hreflang tags for SEO

### Form API Integration
- **Custom Endpoint**: Separate backend API for form submissions
- **Client-Side Validation**: Form field validation before submission
- **Error Handling**: Graceful error messages
- **Success Messages**: Confirmation of successful submissions

### Projects System
- **Category Enum**: Strictly typed project categorization
- **Tag Filtering**: Tag-based content filtering
- **External Links**: GitHub integration and demo URLs
- **Bilingual Content**: Separate FR fields for all metadata

## Performance Optimizations

### Static Site Generation
- **Fast Load Times**: Pre-rendered HTML pages
- **Zero JavaScript**: Minimal JS shipped to client
- **Server-Side Routing**: No client-side router needed
- **Efficient Caching**: Static assets easily cacheable

### Image Optimization
- **Sharp**: High-performance image processing
- **Responsive Images**: Multiple sizes for different devices
- **Lazy Loading**: Below-the-fold image loading
- **Modern Formats**: WebP and AVIF support

### Bundle Optimization
- **Code Splitting**: Small bundles for initial load
- **Minified CSS**: Reduced stylesheet size
- **Tree Shaking**: Unused JS removed
- **Asset Preloading**: Critical resources preloaded

## Future Enhancements

### Planned Features
- **Search**: Full-text content search
- **Dark Mode**: Automatic theme switcher
- **Analytics**: Visitor tracking and content metrics
- **Newsletter**: Email subscription form
- **Comments**: Blog post comment system

### Potential Improvements
- **MDX**: Interactive components in blog posts
- **Faceted Search**: Advanced project filtering
- **View Transitions**: View Transitions API for smooth animations
- **Offline Support**: PWA functionality with service workers
- **Headless CMS**: Integration for non-technical content management

## Technical Stack

- **Astro 4.x**: Modern static site framework
- **TailwindCSS**: Utility-first CSS framework
- **DaisyUI**: TailwindCSS component library
- **TypeScript**: Statically typed JavaScript
- **Zod**: TypeScript-first schema validation
- **pnpm**: Fast package manager
- **Marked**: Markdown parser and renderer
- **Sharp**: High-performance image processing
- **Git**: Version control
- **GitHub Pages**: Static hosting platform

This project demonstrates the ability to build modern, performant websites with modern frameworks while maintaining excellent SEO, accessibility, and user experience. The open-source nature of the Astrofy template provided an excellent foundation for customization and extension.