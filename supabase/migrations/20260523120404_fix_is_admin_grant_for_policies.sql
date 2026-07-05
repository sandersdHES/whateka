-- BUG : la migration 0014 a REVOKE EXECUTE de is_admin() depuis 
-- authenticated, ce qui casse les 15 policies "Admins read all *" qui 
-- l'invoquent (Postgres ne peut pas evaluer la qual -> falsey -> RLS deny).
--
-- Side-effect concret : la page Feedbacks de l'admin etait vide,
-- impossible aussi de selectionner les promo_codes / promo_redemptions /
-- subscriptions / app_access / audit_log depuis l'UI admin.
--
-- Fix : re-GRANT EXECUTE a anon ET authenticated. C'est sans risque cote
-- security :
--   - is_admin() est SECURITY DEFINER, donc s'execute en tant que postgres
--   - elle verifie auth.uid() en interne (NULL pour anon -> retourne false)
--   - elle ne renvoie qu'un boolean, aucune donnee sensible
--   - l'expose via /rest/v1/rpc/is_admin renvoie juste true/false sur
--     "est-ce que JE suis admin", info pas exploitable.
GRANT EXECUTE ON FUNCTION public.is_admin() TO anon, authenticated;

-- Pareil pour la surcharge is_admin(text) si elle existe encore et est
-- utilisee dans d'anciennes policies historiques.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'is_admin' AND pronargs = 1) THEN
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.is_admin(text) TO anon, authenticated';
  END IF;
END $$;
