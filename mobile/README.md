# Mobile (QCess)

Cette application Flutter correspond au client mobile de QCess.

## Prérequis

- Docker Desktop (pour lancer le backend et le webadmin)
- Flutter SDK (version compatible avec `pubspec.yaml`)
- Un émulateur Android ou un téléphone Android (USB debugging activé)

## Démarrage rapide

### 1) Démarrer le backend (+ webadmin)

Depuis la racine du projet (dossier contenant `docker-compose.yml`) :

```bash
docker-compose up -d --build
```

Services exposés :

- API backend : http://localhost:8080
- Webadmin : http://localhost:3000

### 2) Démarrer l’application mobile

Dans le dossier `mobile/` :

```bash
flutter pub get
flutter run
```

#### Accès API depuis un appareil Android (recommandé)

L’application utilise une URL d’API en `http://localhost:8080`.
Pour que le téléphone/émulateur accède au backend lancé sur votre machine, utilisez :

```bash
adb reverse tcp:8080 tcp:8080
```

### 3) (Optionnel) Interagir via le webadmin

Ouvrez http://localhost:3000, connectez-vous en tant qu’admin, puis modifiez un ticket (statut, commentaire, etc.) pour observer l’impact côté mobile.

## Arrêt

```bash
docker-compose down
```

## Données de test (comptes pour se connecter)

Par défaut l’application mobile nécessite une authentification (email + code d’accès).
Pour générer rapidement des utilisateurs de test (organisations, rôles, zones, historique d’accès), vous pouvez importer le script :

- [database/test-data-access.sql](../database/test-data-access.sql)

### Import dans Postgres (Docker)

Depuis la racine du projet :

```bash
docker exec -i qcess_postgres psql -U qcessuser -d qcessdb < database/test-data-access.sql
```

Si le nom du conteneur est différent, listez-le avec :

```bash
docker ps
```

### Identifiants (mobile)

Ensuite, dans l’écran de login du mobile, utilisez :

- 
	Email : `john.doe@techcorp.com` \
	Code : `123456`
- 
	Email : `jane.manager@techcorp.com` \
	Code : `123456`
- 
	Email : `alice.student@campus.edu` \
	Code : `123456`
- 
	Email : `prof.smith@campus.edu` \
	Code : `123456`

Note : le script documente aussi un compte admin (`bob.admin@techcorp.com`). Selon la configuration de la table `users` côté backend, ce compte peut être géré différemment (admin vs user). En cas de doute, utilisez un des comptes ci-dessus pour valider rapidement le parcours mobile.
