# Web Admin – Platine Qcess

## 🧱 Stack
- [Next.js](https://nextjs.org) (App Router)
- React
- TypeScript (via config `jsconfig`/`eslint` du projet)
- Tailwind/PostCSS (voir `postcss.config.mjs`)

## 🎯 Rôle de la web admin
- Interface d’administration pour la plateforme Platine Qcess :
	- gestion des organisations / bâtiments
	- gestion des utilisateurs et de leurs accès
	- configuration des modules (maintenance, notifications, etc.)

## 🚀 Lancer le projet en local

Depuis le dossier `webadmin/` :

```bash
npm install

# Lancer le serveur de dev
npm run dev
```

Par défaut, l’application est disponible sur :

- http://localhost:3000

L’URL de l’API backend à appeler (base URL) est généralement configurée via des variables d’environnement Next.js (ex : `NEXT_PUBLIC_API_BASE_URL`).

## 🧪 Tests & qualité

Selon la config actuelle :

```bash
# Lint
npm run lint

# (Ajouter ici les commandes de tests si/quant elles sont définies dans package.json)
```

## 🌐 Intégration avec le backend
- Consommation de l’API REST exposée par le backend (voir `/backend/README.md`).
- Authentification / autorisation alignée avec les contrats de sécurité définis côté backend.

## 📁 Repères dans le code
- `src/app` : routes/app Next.js
- `src/components` : composants réutilisables
- `src/lib` : utilitaires, accès API, etc.
