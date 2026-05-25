-- Whateka — Migration 0018 : table contact_messages
-- =====================================================================
-- Stocke les messages envoyes par les utilisateurs depuis la section
-- "Contactez-nous" du profil (formulaire interne, alternative au lien
-- Instagram).
--
-- L'admin les voit sur la page /messages de whateka-admin.
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.contact_messages (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Identification du sender : preferentiel via user_id (auth), fallback
  -- email saisi a la main (utile pour un eventuel mode anonyme plus tard).
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  sender_email TEXT, -- snapshot de l'email au moment de l'envoi
  sender_name TEXT,  -- snapshot du prenom au moment de l'envoi

  subject TEXT NOT NULL CHECK (length(trim(subject)) > 0),
  message TEXT NOT NULL CHECK (length(trim(message)) > 0),

  -- Lifecycle cote admin
  status TEXT NOT NULL DEFAULT 'new'
    CHECK (status IN ('new', 'read', 'responded', 'archived')),
  reviewed_at TIMESTAMPTZ,
  reviewed_by TEXT, -- email admin qui a traite
  admin_notes TEXT  -- notes internes (visibles que cote admin)
);

CREATE INDEX IF NOT EXISTS contact_messages_status_idx
  ON public.contact_messages(status) WHERE status <> 'archived';
CREATE INDEX IF NOT EXISTS contact_messages_user_idx
  ON public.contact_messages(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS contact_messages_created_at_idx
  ON public.contact_messages(created_at DESC);

COMMENT ON TABLE public.contact_messages IS
  'Messages user -> equipe Whateka via le formulaire interne du profil. Migration 0018.';

ALTER TABLE public.contact_messages ENABLE ROW LEVEL SECURITY;

-- Policies
-- User authentifie peut creer un message (avec son propre user_id ou anonyme).
DROP POLICY IF EXISTS "Authenticated users can send messages" ON public.contact_messages;
CREATE POLICY "Authenticated users can send messages"
  ON public.contact_messages FOR INSERT
  TO authenticated
  WITH CHECK (
    -- soit l'user_id correspond a l'auth.uid (recommande)
    user_id = (SELECT auth.uid())
    -- soit le message est anonyme (user_id NULL) mais sender_email present
    OR (user_id IS NULL AND sender_email IS NOT NULL)
  );

-- L'user peut relire ses propres messages (option future "mes messages").
DROP POLICY IF EXISTS "Users read own messages" ON public.contact_messages;
CREATE POLICY "Users read own messages"
  ON public.contact_messages FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

-- L'admin lit / modifie tous les messages.
DROP POLICY IF EXISTS "Admins read all messages" ON public.contact_messages;
CREATE POLICY "Admins read all messages"
  ON public.contact_messages FOR SELECT
  TO authenticated
  USING ((SELECT public.is_admin()));

DROP POLICY IF EXISTS "Admins update messages" ON public.contact_messages;
CREATE POLICY "Admins update messages"
  ON public.contact_messages FOR UPDATE
  TO authenticated
  USING ((SELECT public.is_admin()))
  WITH CHECK ((SELECT public.is_admin()));

-- Audit log : trigger ajoute pour tracer les modifs admin (statut, notes).
-- On reutilise tg_admin_audit_log de la migration 0016.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'tg_admin_audit_log') THEN
    EXECUTE 'DROP TRIGGER IF EXISTS trg_audit_contact_messages ON public.contact_messages';
    EXECUTE 'CREATE TRIGGER trg_audit_contact_messages
             AFTER UPDATE OR DELETE ON public.contact_messages
             FOR EACH ROW EXECUTE FUNCTION public.tg_admin_audit_log()';
  END IF;
END $$;
