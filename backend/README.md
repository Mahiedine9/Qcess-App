# Backend – Platine Qcess

## 🧱 Stack principale
- Java 21 (toolchain projet)
- Spring Boot 3 (application REST `app-rest`)
- Maven multi-modules
- Base de données relationnelle (PostgreSQL )

## 🏗️ Architecture backend
- **Architecture hexagonale / modulaire**
- Modules Maven :
  - `app-rest` : point d’entrée Spring Boot (API REST, config principale)
  - `module-access` : gestion des accès (QR codes, zones, droits)
  - `module-dashboard` : données agrégées pour le tableau de bord
  - `module-maintenance` : tickets et suivi de maintenance
  - `module-notification` : notifications (push, temps réel)
  - `platform-core` : logique métier centrale
  - `platform-contracts` : contrats partagés entre modules
  - `test-support` : utilitaires de tests

## 🚀 Lancer le backend en local

Depuis le dossier `backend/` :

```bash
# Windows
mvnw spring-boot:run -pl app-rest -am

# Ou avec Maven installé
mvn spring-boot:run -pl app-rest -am
```

Par défaut l’API écoute généralement sur `http://localhost:8080`.

## 🔌 Accès API & WebSocket
- Base URL API : `http://localhost:8080`
- Endpoint WebSocket (STOMP / SockJS) : `http://localhost:8080/ws` (utilisé par le mobile)

## 🧪 Tests

Lancer tous les tests backend :

```bash
# Depuis backend/
mvnw test
# ou
mvn test
```

Lancer les tests d’un module spécifique, par exemple `module-maintenance` :

```bash
mvnw test -pl module-maintenance
```

## 🌐 Intégration avec les autres plateformes
- **Mobile** : consomme l’API REST ainsi que le WebSocket `/ws` pour les notifications en temps réel.
- **Web admin** : consomme les mêmes endpoints API pour la gestion des bâtiments, organisations, accès et modules.
