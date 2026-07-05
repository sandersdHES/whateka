-- Liste blanche d'accès à l'app durant la phase bêta.
-- Les utilisateurs dont l'email est dans cette table accèdent directement.
-- Les autres voient l'écran maintenance + champ code.
-- Si code OK, leur user_metadata.has_access est mis à true (cf. Flutter).

CREATE TABLE IF NOT EXISTS app_access (
  email TEXT PRIMARY KEY,
  granted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  granted_by TEXT,
  note TEXT
);

-- Insertion des 3 invités initiaux
INSERT INTO app_access (email, granted_by, note) VALUES
  ('yzurbuchen@bluewin.ch', 'system', 'Fondateur'),
  ('dylan.sanderson.97@gmail.com', 'system', 'Co-fondateur'),
  ('marilou.schild@heig-vd.ch', 'system', 'Co-fondatrice')
ON CONFLICT (email) DO NOTHING;

-- RLS : tout utilisateur authentifié peut lire (juste pour vérifier son email)
ALTER TABLE app_access ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS app_access_select_all ON app_access;
CREATE POLICY app_access_select_all ON app_access
  FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS app_access_admin_all ON app_access;
CREATE POLICY app_access_admin_all ON app_access
  FOR ALL
  TO authenticated
  USING (is_admin(auth.email()))
  WITH CHECK (is_admin(auth.email()));

-- Index pour la recherche rapide
CREATE INDEX IF NOT EXISTS idx_app_access_email ON app_access(LOWER(email));
