# Migrations Supabase — état & réconciliation

> Réconcilié le 5 juillet 2026.

## Ce qui s'est passé

Le dossier contenait auparavant **17 fichiers** `0003_…` → `0019_…` qui étaient un
**sous-ensemble renommé et désynchronisé** de l'historique réel appliqué en
production. Concrètement, la base de prod (`pqywriedvxsdngypplpg`) suit un
historique **horodaté** de **80 migrations** (table `supabase_migrations.schema_migrations`),
qui ne correspondait pas au repo. Symptôme concret : le bucket `profile-photos`
(repo `0004`) n'avait **jamais** été appliqué en prod → bug #4.

Les 80 fichiers présents ici sont désormais le **miroir fidèle** de
`schema_migrations` (nom = `{version}_{name}.sql`, SQL exact appliqué).

## ⚠️ Limite importante (à lire avant tout `db reset`)

Ces 80 migrations sont un **enregistrement fidèle de l'historique tracké**, mais
**pas** un schéma reconstructible depuis zéro : la première migration trackée
(`20260424114357`) ne fait qu'`ALTER` des tables déjà existantes. Le **schéma de
base** (tables `activities`, `feedback_*`, profils…) a été créé **avant** le début
du tracking et n'est donc **pas** capturé ici. Rejouer ces migrations sur une base
vide échouerait.

## Pour obtenir un baseline reconstructible (étape définitive)

Nécessite le **CLI Supabase** + le **mot de passe DB** (non versionné) :

```bash
# 1. Installer le CLI
brew install supabase/tap/supabase        # ou: npm i -g supabase

# 2. Lier le projet
supabase link --project-ref pqywriedvxsdngypplpg

# 3. Générer un baseline schéma (dump du schéma courant)
supabase db pull                          # crée un fichier <ts>_remote_schema.sql
```

Après ça, le repo pourra reconstruire la base de zéro. Voir aussi la Phase 5
(migration Supabase) dans [../../docs/PLAN_BUGS_ET_AMELIORATIONS.md](../../docs/PLAN_BUGS_ET_AMELIORATIONS.md).

## Bonnes pratiques désormais

- **Ne plus** appliquer de SQL uniquement via le dashboard : passer par une
  migration versionnée (fichier ici) + `supabase db push`, ou via l'outil MCP en
  gardant le fichier en repo.
- La config d'auth (Site URL, redirect URLs) est désormais versionnée dans
  [../config.toml](../config.toml).
