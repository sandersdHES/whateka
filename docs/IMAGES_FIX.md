# Fix images d'activités (#3)

> Établi le 5 juillet 2026. Statut : **4/5 corrigées** ✅ · **1 en attente (self-host)** ⏳

## État réel (mesuré sur le remote, pas sur les seeds du repo)

- **353** activités actives, **0 sans image** (l'audit initial « tout NULL » venait
  des fichiers de seed du repo, désynchronisés ; le remote a été peuplé via les
  migrations `image_urls_chunk_*`).
- **149** → bucket `activity-images` (fiable) · **202** → URLs externes · **2** → base64 `data:` (ids 4, 124).
- Probe des 202 URLs externes (2 passes : bare + avec `Referer: https://whateka.ch`
  pour reproduire le navigateur) : **197 OK**, **3 hotlink** (KO sur web), **2 mortes**.

## Corrections appliquées (4/5) — via MCP, réversible

| id | Activité | Ancienne (cassée) → Nouvelle (vérifiée 200) |
|----|----------|---------------------------------------------|
| 167 | Mystery Wine – Celliers | celliers.ch `xbrulefer…` → celliers.ch `Mystery-wine-header.jpg` |
| 265 | Lac de Moiry | oastatic (hotlink) → static.mycity.travel cover |
| 632 | Foire du Valais | foireduvalais.ch `val-1267` (morte) → foireduvalais.ch `foire-2025-ambiance` |
| 669 | Via Farinetta | oastatic (hotlink) → saillon.ch (api.i-web.ch) |

Les 4 nouvelles URLs ont été re-vérifiées : **200 image/jpeg** avec `Referer` navigateur.

### Rollback (si besoin)
```sql
update public.activities set image_url = case id
  when 167 then 'https://celliers.ch/wp-content/uploads/2024/09/xbrulefer-sante.jpg.pagespeed.ic.bSCrogDCbN.jpg'
  when 265 then 'https://img.oastatic.com/img2/27188932/2048x1366/.jpg'
  when 632 then 'https://foireduvalais.ch/media/image/0/normal_3_2/val-1267.jpg?08cc397ab3850942c4915b094099d6fd'
  when 669 then 'https://img.oastatic.com/img2/20118381/3840x0/.jpg'
end where id in (167, 265, 632, 669);
```

## En attente ⏳ — id 246 « Ski Alpin Les Diablerets – Glacier 3000 »
- Site 100 % JS → aucune image fiable trouvable automatiquement.
- Son image d'origine (`iloveski.org`) **fonctionne sur mobile** mais est bloquée
  en hotlink sur **web** uniquement.
- **Fix durable = self-host** dans le bucket. Script prêt :
  `scratchpad/rehost_broken_images.sh` + `scratchpad/rehost_targets.tsv` (contient 246).
  ```bash
  export SUPABASE_URL="https://pqywriedvxsdngypplpg.supabase.co"
  export SUPABASE_SERVICE_ROLE_KEY="<clé service_role>"   # jamais committée
  ./rehost_broken_images.sh rehost_targets.tsv
  ```
  (nécessite la clé service_role — à lancer de ton côté). Sinon : fournir une photo.

## Test de contrôle
- **Automatisé** : [test/widgets/activity_card_test.dart](../test/widgets/activity_card_test.dart)
  — URL cassée / null → carte affichée via le fallback catégoriel, aucun crash.
- **Manuel** : ouvrir les 4 fiches (167, 265, 632, 669) sur **whateka.ch** → image visible.

## Notes / pistes
- **Durabilité** : les remplacements restent des URLs externes (fiables mais
  susceptibles de re-rot). Option future : mirror des 202 externes dans le bucket
  (même script) pour supprimer toute dépendance externe.
- **base64 (ids 4, 124)** : s'affichent bien mais alourdissent chaque requête
  (image inline dans la colonne). À migrer vers le bucket un jour (perf).
