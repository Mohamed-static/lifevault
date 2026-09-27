# LifeVault

Coffre-fort numerique personnel : documents, recus, garanties, billets, notes, avec rappels d expiration.

## Stack

- Frontend : Flutter (Dart)
- Backend : Supabase (PostgreSQL, Auth, Storage)
- Securite : Row Level Security sur toutes les tables, bucket storage prive, Edge Functions pour operations sensibles

## Structure

lib/
  main.dart              Point d entree, routing Auth/Home
  core/theme.dart         Theme visuel de l app
  models/                Structures de donnees (VaultItem, Category, Tag, Reminder, UserProfile)
  services/               Logique d acces aux donnees (Supabase, Auth, Vault, Storage, Reminder)
  features/               Ecrans par domaine (auth, home, vault)
  shared/widgets/          Composants reutilisables

supabase/
  schema.sql               Schema complet de la base de donnees
  storage_policies.sql      Policies RLS du bucket de fichiers
  functions/               Edge Functions (suppression de compte)

## Installation

1. Cloner le depot
2. Copier .env.example vers .env et remplir avec vos cles Supabase
3. flutter pub get
4. flutter run

## Securite

- Toutes les tables ont RLS active : un utilisateur ne peut jamais lire ou modifier les donnees d un autre utilisateur
- Le bucket de fichiers est prive, chaque fichier est range sous {user_id}/ et protege par policy
- La cle service_role n est jamais exposee cote client, uniquement utilisee dans les Edge Functions
- La suppression de compte passe par une Edge Function serveur, jamais directement depuis l app

## Statut du MVP

Voir la liste des fonctionnalites en cours dans les notes de developpement.
