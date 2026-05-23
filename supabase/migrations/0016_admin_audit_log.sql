-- Whateka — Migration 0016 : audit log admin
-- =====================================================================
-- Tracabilite : qui a fait quoi quand sur les tables critiques.
-- Necessaire pour responsabiliser les admins, debug bug "ou est passe X",
-- conformite eventuelle (RGPD demande de "rectification" => qui a edite).
--
-- Tables tracees pour l'instant :
--   - activities         (UPDATE, DELETE)
--   - activity_submissions (UPDATE, DELETE)
--   - admin_users        (INSERT, UPDATE, DELETE)
--   - app_access         (INSERT, DELETE)
--   - promo_codes        (INSERT, UPDATE, DELETE)
--
-- Pas d'UI cote whateka-admin dans cette migration : seulement backend.
-- La page "Audit" viendra dans un PR ulterieur.
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.admin_audit_log (
  id BIGSERIAL PRIMARY KEY,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Acteur : email pris de auth.users via auth.uid() au moment du trigger.
  -- NULL si action systeme (eg. cron) ou impossible a determiner.
  actor_email TEXT,
  actor_user_id UUID,

  -- Cible.
  table_name TEXT NOT NULL,
  row_pk TEXT NOT NULL,
  operation TEXT NOT NULL CHECK (operation IN ('INSERT','UPDATE','DELETE')),

  -- Donnees AVANT / APRES (JSON). Pour INSERT, before_data = NULL ; pour
  -- DELETE, after_data = NULL. Stocke en jsonb pour query/index potentiels.
  before_data JSONB,
  after_data JSONB,

  -- Sous-set des colonnes effectivement modifiees (UPDATE).
  changed_columns TEXT[]
);

CREATE INDEX IF NOT EXISTS admin_audit_log_table_pk_idx
  ON public.admin_audit_log(table_name, row_pk);
CREATE INDEX IF NOT EXISTS admin_audit_log_actor_idx
  ON public.admin_audit_log(actor_user_id) WHERE actor_user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS admin_audit_log_occurred_at_idx
  ON public.admin_audit_log(occurred_at DESC);

COMMENT ON TABLE public.admin_audit_log IS
  'Audit trail des operations sensibles cote admin (activities, submissions, admin_users, promo_codes, app_access). Migration 0016.';

-- RLS : seuls les admins lisent. Personne n'ecrit directement (les triggers
-- inserent en SECURITY DEFINER en tant que postgres).
ALTER TABLE public.admin_audit_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins read audit log" ON public.admin_audit_log;
CREATE POLICY "Admins read audit log"
  ON public.admin_audit_log FOR SELECT
  TO authenticated
  USING ((SELECT public.is_admin()));


-- Trigger function generique. Capture actor + diff colonnes.
CREATE OR REPLACE FUNCTION public.tg_admin_audit_log()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_actor_id UUID;
  v_actor_email TEXT;
  v_row_pk TEXT;
  v_changed TEXT[];
  v_col TEXT;
  v_before JSONB;
  v_after JSONB;
BEGIN
  v_actor_id := auth.uid();
  IF v_actor_id IS NOT NULL THEN
    SELECT email INTO v_actor_email FROM auth.users WHERE id = v_actor_id;
  END IF;

  -- PK : on suppose une colonne 'id' ou 'email' (admin_users, app_access).
  -- L'ordre des fallbacks suit nos tables actuelles.
  IF TG_OP = 'DELETE' THEN
    v_before := to_jsonb(OLD);
    v_after := NULL;
    BEGIN
      v_row_pk := COALESCE(
        (v_before->>'id'),
        (v_before->>'email'),
        (v_before->>'code'),
        'unknown'
      );
    END;
  ELSIF TG_OP = 'INSERT' THEN
    v_before := NULL;
    v_after := to_jsonb(NEW);
    v_row_pk := COALESCE(
      (v_after->>'id'),
      (v_after->>'email'),
      (v_after->>'code'),
      'unknown'
    );
  ELSE -- UPDATE
    v_before := to_jsonb(OLD);
    v_after := to_jsonb(NEW);
    v_row_pk := COALESCE(
      (v_after->>'id'),
      (v_after->>'email'),
      (v_after->>'code'),
      'unknown'
    );
    -- Diff colonnes
    v_changed := ARRAY[]::TEXT[];
    FOR v_col IN SELECT jsonb_object_keys(v_after) LOOP
      IF v_before->v_col IS DISTINCT FROM v_after->v_col THEN
        v_changed := array_append(v_changed, v_col);
      END IF;
    END LOOP;
    -- Si aucune colonne reellement modifiee, on n'insere pas (no-op).
    IF array_length(v_changed, 1) IS NULL THEN
      RETURN NEW;
    END IF;
  END IF;

  INSERT INTO public.admin_audit_log (
    actor_user_id, actor_email,
    table_name, row_pk, operation,
    before_data, after_data, changed_columns
  ) VALUES (
    v_actor_id, v_actor_email,
    TG_TABLE_NAME, v_row_pk, TG_OP,
    v_before, v_after, v_changed
  );

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.tg_admin_audit_log() FROM PUBLIC, anon, authenticated;


-- Attachage des triggers
DROP TRIGGER IF EXISTS trg_audit_activities ON public.activities;
CREATE TRIGGER trg_audit_activities
  AFTER UPDATE OR DELETE ON public.activities
  FOR EACH ROW EXECUTE FUNCTION public.tg_admin_audit_log();

DROP TRIGGER IF EXISTS trg_audit_activity_submissions ON public.activity_submissions;
CREATE TRIGGER trg_audit_activity_submissions
  AFTER UPDATE OR DELETE ON public.activity_submissions
  FOR EACH ROW EXECUTE FUNCTION public.tg_admin_audit_log();

DROP TRIGGER IF EXISTS trg_audit_admin_users ON public.admin_users;
CREATE TRIGGER trg_audit_admin_users
  AFTER INSERT OR UPDATE OR DELETE ON public.admin_users
  FOR EACH ROW EXECUTE FUNCTION public.tg_admin_audit_log();

DROP TRIGGER IF EXISTS trg_audit_app_access ON public.app_access;
CREATE TRIGGER trg_audit_app_access
  AFTER INSERT OR DELETE ON public.app_access
  FOR EACH ROW EXECUTE FUNCTION public.tg_admin_audit_log();

DROP TRIGGER IF EXISTS trg_audit_promo_codes ON public.promo_codes;
CREATE TRIGGER trg_audit_promo_codes
  AFTER INSERT OR UPDATE OR DELETE ON public.promo_codes
  FOR EACH ROW EXECUTE FUNCTION public.tg_admin_audit_log();
