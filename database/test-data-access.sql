-- Script de test pour le module Access
-- Génère des utilisateurs, zones, rôles et historique d'accès

-- ====================================
-- 0. CRÉATION DES TABLES SI NÉCESSAIRE
-- ====================================
-- Table access_logs (si elle n'existe pas encore)
CREATE TABLE IF NOT EXISTS access_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    zone_id BIGINT NOT NULL,
    organization_id BIGINT NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    access_granted BOOLEAN NOT NULL,
    reason VARCHAR(255)
);



-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS idx_access_logs_user_id ON access_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_access_logs_zone_id ON access_logs(zone_id);
CREATE INDEX IF NOT EXISTS idx_access_logs_timestamp ON access_logs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_access_logs_org_id ON access_logs(organization_id);

-- ====================================
-- 1. ORGANISATIONS
-- ====================================
-- Vérifier si les organisations existent déjà
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM organizations WHERE id = 1) THEN
        INSERT INTO organizations (id, name, created_at) VALUES
        (1, 'Tech Corp', NOW());
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM organizations WHERE id = 2) THEN
        INSERT INTO organizations (id, name, created_at) VALUES
        (2, 'University Campus', NOW());
    END IF;
END $$;

-- Mettre à jour la séquence
SELECT setval('organizations_id_seq', (SELECT MAX(id) FROM organizations));

-- ====================================
-- 2. ROLES PERSONNALISÉS
-- ====================================
-- Insérer ou mettre à jour les rôles
INSERT INTO custom_roles (id, name, organization_id, created_at) VALUES
(1, 'Employee', 1, NOW()),
(2, 'Manager', 1, NOW()),
(3, 'Admin', 1, NOW()),
(4, 'Student', 2, NOW()),
(5, 'Professor', 2, NOW())
ON CONFLICT (id) DO UPDATE 
SET name = EXCLUDED.name, 
    organization_id = EXCLUDED.organization_id;

-- Mettre à jour la séquence
SELECT setval('custom_roles_id_seq', (SELECT MAX(id) FROM custom_roles));

-- ====================================
-- 3. UTILISATEURS
-- ====================================
-- Login Code: "123456" pour tous les utilisateurs de test
-- Supprimer les utilisateurs de test existants pour éviter les conflits
DELETE FROM users WHERE email IN (
    'john.doe@techcorp.com',
    'jane.manager@techcorp.com', 
    'bob.admin@techcorp.com',
    'alice.student@campus.edu',
    'prof.smith@campus.edu'
);

-- Insérer les nouveaux utilisateurs avec login_code
INSERT INTO users (email, login_code, full_name, first_name, last_name, role, status, organization_id, custom_role_id, created_at) VALUES
('john.doe@techcorp.com', '123456', 'John Doe', 'John', 'Doe', 'USER', 'ACTIVE', 1, 1, NOW()),
('jane.manager@techcorp.com', '123456', 'Jane Manager', 'Jane', 'Manager', 'USER', 'ACTIVE', 1, 2, NOW()),
('bob.admin@techcorp.com', '','$2a$12$BIRQ706sP1HTu5sWBNL17e7UreNSuKND0uAeABK4Rh4JvGko/bCvm', 'Bob Admin', 'Bob', 'Admin', 'ADMIN', 'ACTIVE', 1, 3, NOW()),
('alice.student@campus.edu', '123456', 'Alice Student', 'Alice', 'Student', 'USER', 'ACTIVE', 2, 4, NOW()),
('prof.smith@campus.edu', '123456', 'Prof. Smith', 'Prof', 'Smith', 'USER', 'ACTIVE', 2, 5, NOW());

-- ====================================
-- 4. ZONES
-- ====================================
-- Note: allowed_role_ids sera inséré via la table zone_allowed_roles
INSERT INTO zones (id, name, description, status, org_id, created_at) VALUES
-- Zones Tech Corp (org 1)
(1, 'Main Entrance', 'Entrance principale - Accès public', 'ACTIVE', 1, NOW()),
(2, 'Office Floor 1', 'Bureau étage 1 - Tous les employés', 'ACTIVE', 1, NOW()),
(3, 'Management Suite', 'Suite direction - Managers et Admin seulement', 'ACTIVE', 1, NOW()),
(4, 'Server Room', 'Salle serveurs - Admin uniquement', 'ACTIVE', 1, NOW()),
(5, 'Parking Garage', 'Parking souterrain - En maintenance', 'INACTIVE', 1, NOW()),

-- Zones University (org 2)
(6, 'Library', 'Bibliothèque universitaire - Public', 'ACTIVE', 2, NOW()),
(7, 'Classroom Building', 'Bâtiment des salles de cours', 'ACTIVE', 2, NOW()),
(8, 'Research Lab', 'Laboratoire de recherche - Professeurs', 'ACTIVE', 2, NOW()),
(9, 'Student Center', 'Centre étudiant', 'ACTIVE', 2, NOW()),
(10, 'Admin Building', 'Bâtiment administratif - Fermé temporairement', 'INACTIVE', 2, NOW())
ON CONFLICT (id) DO NOTHING;

-- ====================================
-- 4b. ZONE ALLOWED ROLES (Table de jointure)
-- ====================================
-- Zone 1 (Main Entrance) : Pas de restriction (public)
-- Zone 2 (Office Floor 1) : Employés, Managers, Admins
INSERT INTO zone_allowed_roles (zone_id, allowed_role_ids) VALUES
(2, 1), (2, 2), (2, 3);

-- Zone 3 (Management Suite) : Managers et Admins seulement
INSERT INTO zone_allowed_roles (zone_id, allowed_role_ids) VALUES
(3, 2), (3, 3);

-- Zone 4 (Server Room) : Admin uniquement
INSERT INTO zone_allowed_roles (zone_id, allowed_role_ids) VALUES
(4, 3);

-- Zone 5 (Parking) : Tous (mais inactive)
INSERT INTO zone_allowed_roles (zone_id, allowed_role_ids) VALUES
(5, 1), (5, 2), (5, 3);

-- Zone 6 (Library) : Pas de restriction (public)
-- Zone 7 (Classroom) : Students et Professors
INSERT INTO zone_allowed_roles (zone_id, allowed_role_ids) VALUES
(7, 4), (7, 5);

-- Zone 8 (Research Lab) : Professors uniquement
INSERT INTO zone_allowed_roles (zone_id, allowed_role_ids) VALUES
(8, 5);

-- Zone 9 (Student Center) : Students uniquement
INSERT INTO zone_allowed_roles (zone_id, allowed_role_ids) VALUES
(9, 4);

-- Zone 10 (Admin Building) : Professors (mais inactive)
INSERT INTO zone_allowed_roles (zone_id, allowed_role_ids) VALUES
(10, 5);

-- ====================================
-- 5. HISTORIQUE D'ACCÈS (ACCESS LOGS)
-- ====================================
-- Récupérer les IDs des utilisateurs créés
DO $$
DECLARE
    john_id BIGINT;
    jane_id BIGINT;
    bob_id BIGINT;
    alice_id BIGINT;
    prof_id BIGINT;
BEGIN
    SELECT id INTO john_id FROM users WHERE email = 'john.doe@techcorp.com';
    SELECT id INTO jane_id FROM users WHERE email = 'jane.manager@techcorp.com';
    SELECT id INTO bob_id FROM users WHERE email = 'bob.admin@techcorp.com';
    SELECT id INTO alice_id FROM users WHERE email = 'alice.student@campus.edu';
    SELECT id INTO prof_id FROM users WHERE email = 'prof.smith@campus.edu';

    -- Accès de John Doe (Employee)
    INSERT INTO access_logs (user_id, zone_id, organization_id, timestamp, access_granted, reason) VALUES
    -- Aujourd'hui
    (john_id, 1, 1, NOW() - INTERVAL '10 minutes', true, 'PUBLIC_ZONE'),
    (john_id, 2, 1, NOW() - INTERVAL '8 minutes', true, 'AUTHORIZED_ROLE'),
    (john_id, 3, 1, NOW() - INTERVAL '5 minutes', false, 'ROLE_NOT_ALLOWED'),

    -- Hier
    (john_id, 1, 1, NOW() - INTERVAL '1 day', true, 'PUBLIC_ZONE'),
    (john_id, 2, 1, NOW() - INTERVAL '1 day' + INTERVAL '2 hours', true, 'AUTHORIZED_ROLE'),
    (john_id, 2, 1, NOW() - INTERVAL '1 day' + INTERVAL '5 hours', true, 'AUTHORIZED_ROLE'),

    -- Il y a 2 jours
    (john_id, 1, 1, NOW() - INTERVAL '2 days', true, 'PUBLIC_ZONE'),
    (john_id, 2, 1, NOW() - INTERVAL '2 days' + INTERVAL '3 hours', true, 'AUTHORIZED_ROLE'),
    (john_id, 5, 1, NOW() - INTERVAL '2 days' + INTERVAL '4 hours', false, 'ZONE_INACTIVE');

    -- Accès de Jane Manager
    INSERT INTO access_logs (user_id, zone_id, organization_id, timestamp, access_granted, reason) VALUES
    (jane_id, 1, 1, NOW() - INTERVAL '30 minutes', true, 'PUBLIC_ZONE'),
    (jane_id, 2, 1, NOW() - INTERVAL '25 minutes', true, 'AUTHORIZED_ROLE'),
    (jane_id, 3, 1, NOW() - INTERVAL '20 minutes', true, 'AUTHORIZED_ROLE'),
    (jane_id, 4, 1, NOW() - INTERVAL '15 minutes', false, 'ROLE_NOT_ALLOWED'),
    (jane_id, 1, 1, NOW() - INTERVAL '1 day', true, 'PUBLIC_ZONE'),
    (jane_id, 3, 1, NOW() - INTERVAL '1 day' + INTERVAL '2 hours', true, 'AUTHORIZED_ROLE');

    -- Accès de Bob Admin
    INSERT INTO access_logs (user_id, zone_id, organization_id, timestamp, access_granted, reason) VALUES
    (bob_id, 1, 1, NOW() - INTERVAL '2 hours', true, 'PUBLIC_ZONE'),
    (bob_id, 2, 1, NOW() - INTERVAL '1 hour 50 minutes', true, 'AUTHORIZED_ROLE'),
    (bob_id, 3, 1, NOW() - INTERVAL '1 hour 40 minutes', true, 'AUTHORIZED_ROLE'),
    (bob_id, 4, 1, NOW() - INTERVAL '1 hour 30 minutes', true, 'AUTHORIZED_ROLE');

    -- Accès d'Alice Student
    INSERT INTO access_logs (user_id, zone_id, organization_id, timestamp, access_granted, reason) VALUES
    (alice_id, 6, 2, NOW() - INTERVAL '45 minutes', true, 'PUBLIC_ZONE'),
    (alice_id, 7, 2, NOW() - INTERVAL '40 minutes', true, 'AUTHORIZED_ROLE'),
    (alice_id, 9, 2, NOW() - INTERVAL '30 minutes', true, 'AUTHORIZED_ROLE'),
    (alice_id, 8, 2, NOW() - INTERVAL '20 minutes', false, 'ROLE_NOT_ALLOWED'),
    (alice_id, 6, 2, NOW() - INTERVAL '1 day', true, 'PUBLIC_ZONE'),
    (alice_id, 7, 2, NOW() - INTERVAL '1 day' + INTERVAL '3 hours', true, 'AUTHORIZED_ROLE'),
    (alice_id, 9, 2, NOW() - INTERVAL '2 days', true, 'AUTHORIZED_ROLE');

    -- Accès de Prof. Smith
    INSERT INTO access_logs (user_id, zone_id, organization_id, timestamp, access_granted, reason) VALUES
    (prof_id, 6, 2, NOW() - INTERVAL '3 hours', true, 'PUBLIC_ZONE'),
    (prof_id, 7, 2, NOW() - INTERVAL '2 hours 50 minutes', true, 'AUTHORIZED_ROLE'),
    (prof_id, 8, 2, NOW() - INTERVAL '2 hours 40 minutes', true, 'AUTHORIZED_ROLE'),
    (prof_id, 10, 2, NOW() - INTERVAL '2 hours 30 minutes', false, 'ZONE_INACTIVE');
END $$;

-- ====================================
-- RÉSUMÉ DES DONNÉES
-- ====================================
-- Organizations: 2 (Tech Corp, University Campus)
-- Custom Roles: 5 (Employee, Manager, Admin, Student, Professor)
-- Users: 5 (1 Employee, 1 Manager, 1 Admin, 1 Student, 1 Professor)
-- Zones: 10 (5 par organisation, incluant zones publiques, restreintes et inactives)
-- Access Logs: ~40 entrées avec succès et refus

-- ====================================
-- COMPTES DE TEST
-- ====================================
-- Email: john.doe@techcorp.com
-- Login Code: 123456
-- Role: Employee
-- Peut accéder à: Main Entrance (public), Office Floor 1
-- Ne peut PAS accéder à: Management Suite, Server Room

-- Email: jane.manager@techcorp.com
-- Login Code: 123456
-- Role: Manager
-- Peut accéder à: Main Entrance, Office Floor 1, Management Suite
-- Ne peut PAS accéder à: Server Room

-- Email: bob.admin@techcorp.com
-- Login Code: 123456
-- Role: Admin
-- Peut accéder à: TOUT (Main Entrance, Office Floor 1, Management Suite, Server Room)

-- Email: alice.student@campus.edu
-- Login Code: 123456
-- Role: Student
-- Peut accéder à: Library (public), Classroom Building, Student Center
-- Ne peut PAS accéder à: Research Lab

-- Email: prof.smith@campus.edu
-- Login Code: 123456
-- Role: Professor
-- Peut accéder à: Library, Classroom Building, Research Lab
-- Peut accéder à: Student Center (non)
