# Whateka — Bugs & Améliorations

> Dernière mise à jour : 29 juin 2026

---

## Bugs critiques

### 1. Réinitialisation du mot de passe — lien non fonctionnel
- **Problème :** Le lien envoyé par e-mail lors d'une demande de mot de passe oublié ne fonctionne pas.
- **Impact :** Les utilisateurs ne peuvent pas récupérer leur compte.
- **Priorité :** Haute

### 2. Confirmation d'e-mail — lien non fonctionnel
- **Problème :** Le lien de confirmation d'adresse e-mail envoyé à l'inscription n'aboutit pas.
- **Impact :** Les nouveaux comptes ne peuvent pas être validés.
- **Priorité :** Haute

### 3. Images non affichables pour certaines activités
- **Problème :** Certaines activités présentent des images qui ne s'affichent pas correctement.
- **Impact :** Expérience utilisateur dégradée sur les fiches activités.
- **Priorité :** Moyenne

### 4. Impossible de définir une photo de profil utilisateur
- **Problème :** Le flux d'upload/modification de l'avatar utilisateur est bloqué.
- **Impact :** Les profils restent sans photo.
- **Priorité :** Moyenne

---

## Migrations & Infrastructure

### 5. Migration Supabase / GitHub OAuth
- **Contexte :** La connexion via GitHub est liée au compte GitHub de l'école ; elle cessera de fonctionner à terme.
- **Actions :**
  - Migrer le projet Supabase vers un dépôt/organisation GitHub indépendant (à définir).
  - Privilégier si possible un hébergement Supabase en Suisse (conformité RGPD/LPD).
- **Priorité :** Haute

### 6. Migration de l'API Gemini
- **Contexte :** Remplacement de l'API Gemini par une alternative.
- **Options à évaluer :**
  - Autre modèle cloud (OpenAI, Mistral, Cohere…)
  - Solution on-premise (Ollama, modèle open-source hébergé en interne)
- **Décision :** À déterminer avec l'équipe.
- **Priorité :** Moyenne

---

## Fonctionnalités à mettre en place

### 7. Intégration Stripe — Paiement
- **Description :** Mettre en place Stripe pour permettre l'accès payant à l'application ou à des fonctionnalités premium.
- **Étapes :**
  - Définir le modèle tarifaire (abonnement, achat unique…)
  - Intégrer le SDK Stripe
  - Gérer les webhooks (confirmation de paiement, expiration, remboursement)
- **Priorité :** Haute

### 8. Espace commentaires
- **Description :** Ajouter un système de commentaires sur les activités.
- **À préciser :** Modération, signalement, pagination.
- **Priorité :** Moyenne

### 9. Soumission d'activités et de photos par les utilisateurs
- **Description :** Permettre aux utilisateurs de :
  - Publier des photos liées à une activité.
  - Proposer de nouvelles activités (soumises à modération avant publication).
- **Priorité :** Moyenne

### 10. API Business — Réception d'activités partenaires
- **Description :** Concevoir un système permettant à des partenaires Business d'envoyer des activités via API.
- **À préciser :**
  - Format d'authentification (API key, OAuth2…)
  - Schéma de données attendu
  - Workflow de validation/modération
- **Priorité :** Basse (conception à initier)

### 11. Traduction en allemand
- **Description :** Rendre l'application disponible en langue allemande.
- **Étapes :**
  - Auditer les chaînes de traduction existantes (i18n)
  - Traduire l'ensemble du contenu (UI + contenu éditorial)
  - Tester sur les locales `de-DE` et `de-CH`
- **Priorité :** Moyenne

### 12. Déploiement sur Google Play Store
- **Description :** Mettre l'application Android disponible sur le Play Store.
- **Phases :**
  1. Programme testeurs (accès interne / bêta fermée)
  2. Distribution globale
- **Prérequis :** Compte Google Play Developer, conformité aux politiques Play Store.
- **Priorité :** Haute

---

## Design & Contenu

### 13. Logo Aventure — révision graphique
- **Description :** Revoir le logo de la catégorie Aventure.
- **Statut :** En attente de la maquette de Louisa.
- **Priorité :** Basse

---

## À clarifier

### 14. Messagerie équipe
- **Description :** Le fonctionnement actuel de la messagerie entre membres d'une équipe n'est pas clair.
- **Questions ouvertes :**
  - Où les messages sont-ils stockés ? (Supabase, service tiers ?)
  - Comment sont-ils acheminés ? (temps réel, polling ?)
  - Faut-il maintenir le système actuel ou le refondre ?
- **Priorité :** À déterminer après audit technique.

---

## Récapitulatif

| # | Titre | Catégorie | Priorité |
|---|-------|-----------|----------|
| 1 | Lien réinitialisation mot de passe | Bug | Haute |
| 2 | Lien confirmation e-mail | Bug | Haute |
| 3 | Images activités non affichées | Bug | Moyenne |
| 4 | Photo de profil utilisateur | Bug | Moyenne |
| 5 | Migration Supabase / GitHub OAuth | Infrastructure | Haute |
| 6 | Migration API Gemini | Infrastructure | Moyenne |
| 7 | Intégration Stripe | Fonctionnalité | Haute |
| 8 | Espace commentaires | Fonctionnalité | Moyenne |
| 9 | Soumission activités & photos | Fonctionnalité | Moyenne |
| 10 | API Business | Fonctionnalité | Basse |
| 11 | Traduction allemand | Fonctionnalité | Moyenne |
| 12 | Google Play Store | Déploiement | Haute |
| 13 | Logo Aventure | Design | Basse |
| 14 | Messagerie équipe | À clarifier | — |
