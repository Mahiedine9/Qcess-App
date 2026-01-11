# Platine Qcess

## 🎯 Overview
Platine Qcess est une plateforme SaaS modulaire de gestion intelligente des bâtiments (résidences, entreprises, etc.) avec :
- Un **backend** Java/Spring pour la logique métier et les APIs
- Une **web app admin** (Next.js) pour la gestion des organisations, accès et modules
- Une **application mobile** Flutter pour les utilisateurs finaux (QR codes, notifications, accès)

## 🧱 Architecture globale
- **Monorepo** avec plusieurs modules backend et clients (web + mobile)
- **Communication** principale via API REST sécurisée
- **Notifications temps réel** via WebSocket/STOMP
- **Contrats partagés** entre les modules backend (platform-core, platform-contracts, etc.)
- **Architecture hexagonale** côté backend (ports/adapters, modules métier)

## 📂 Structure du repo
- `/backend` → backend Java (Spring Boot, multi-modules Maven)
	- `app-rest` → application REST principale (API)
	- `module-*` → modules fonctionnels (access, dashboard, maintenance, notification, etc.)
	- `platform-*` → noyau métier, contrats partagés, support de tests
- `/mobile` → app mobile Flutter (Android, iOS, web, desktop)
- `/webadmin` → web app d’administration (Next.js / React)
- `/database` → scripts SQL de données de test et documentation associée

## 👥 Navigation par profil
- **Dev backend** → voir le README dédié dans `/backend/README.md`
- **Dev front web (admin)** → voir `/webadmin/README.md`
- **Dev mobile** → voir `/mobile/README.md`
- **Ops / DevOps** →
	- `docker-compose.yml` pour l’orchestration locale
	- README backend pour la config des services et BDD

## 🚀 Getting started
1. Cloner le repo
2. Démarrer le backend (Spring Boot) – voir `/backend/README.md`
3. Lancer la web app admin – voir `/webadmin/README.md`
4. Lancer l’app mobile – voir `/mobile/README.md`


## 👨‍💻 Auteurs / Contributeurs

| Nom | Rôle | Contact |
|-----|------|---------|
| **Mahiedine Ferdjoukh** | Développeur Full Stack | [GitHub](https://github.com/Mahiedine9/) |
| **Aymane Essajidi** | Développeur Full Stack | [GitHub](https://github.com/Essajidi-Aymane/) |

---

*Projet en cours de développement – voir les README des sous‑projets pour les détails techniques.*