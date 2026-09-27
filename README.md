# LifeVault

Coffre-fort numerique personnel : documents, recus, garanties, billets, notes, avec rappels d'expiration.

## Stack

- Frontend : Flutter (Dart)
- Backend : Supabase (PostgreSQL, Auth, Storage)
- Securite : Row Level Security sur toutes les tables, bucket prive, Edge Functions pour les operations sensibles

## Structure

- lib/main.dart : point d'entree, routing Auth/Home
- lib/core : theme
- lib/models : VaultItem, Category, Tag, Reminder, UserProfile
- lib/services : Supabase, Auth, Vault, Storage, Reminder
- lib/features : ecrans par domaine (auth, home, vault)
- lib/shared/widgets : composants reutilisables
- supabase/ : schema.sql, storage_policies.sql, functions/

## Installation

1. Cloner le depot
2. Copier .env.example vers .env et remplir avec vos cles Supabase
3. flutter pub get
4. flutter run

## Securite

- RLS active sur toutes les tables : un utilisateur ne peut jamais lire ou modifier les donnees d'un autre
- Bucket de fichiers prive, chaque fichier range sous {user_id}/ et protege par policy
- La cle service_role n'est jamais exposee cote client, uniquement utilisee dans les Edge Functions
- La suppression de compte passe par une Edge Function serveur

## Statut

MVP en cours de developpement.