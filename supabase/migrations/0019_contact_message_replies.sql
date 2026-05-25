-- Whateka — Migration 0019 : conversations bidirectionnelles
-- =====================================================================
-- Le systeme initial (migration 0018) etait un envoi simple user -> admin.
-- On le transforme en conversation : admin peut repondre dans l'app, user
-- voit la reponse + peut continuer le fil.
--
-- Modele :
--   contact_messages    = thread (1 par sujet, contient le 1er message)
--   contact_message_replies = N reponses par thread
--
-- Pour simplifier le client, le 1er message reste dans contact_messages,
-- les suivants vont dans replies.
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.contact_message_replies (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  contact_message_id BIGINT NOT NULL
    REFERENCES public.contact_messages(id) ON DELETE CASCADE,

  -- Qui a ecrit cette reponse :
  --   'user'  = utilisateur final de l'app
  --   'admin' = membre de admin_users
  author_role TEXT NOT NULL CHECK (author_role IN ('user', 'admin')),
  author_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  author_email TEXT,
  author_name TEXT,

  message TEXT NOT NULL CHECK (length(trim(message)) > 0)
);

CREATE INDEX IF NOT EXISTS contact_message_replies_thread_idx
  ON public.contact_message_replies(contact_message_id, created_at);

COMMENT ON TABLE public.contact_message_replies IS
  'Reponses successives dans un thread contact_messages (conversation user <-> admin). Migration 0019.';

ALTER TABLE public.contact_message_replies ENABLE ROW LEVEL SECURITY;

-- POLICIES -------------------------------------------------------------

-- INSERT user : peut ecrire dans un thread dont il est le proprietaire
-- (contact_messages.user_id = auth.uid()), avec author_role='user'.
DROP POLICY IF EXISTS "Users reply in own thread" ON public.contact_message_replies;
CREATE POLICY "Users reply in own thread"
  ON public.contact_message_replies FOR INSERT
  TO authenticated
  WITH CHECK (
    author_role = 'user'
    AND author_user_id = (SELECT auth.uid())
    AND EXISTS (
      SELECT 1 FROM public.contact_messages m
       WHERE m.id = contact_message_id
         AND m.user_id = (SELECT auth.uid())
    )
  );

-- INSERT admin : peut ecrire dans n'importe quel thread, author_role='admin'.
DROP POLICY IF EXISTS "Admins reply anywhere" ON public.contact_message_replies;
CREATE POLICY "Admins reply anywhere"
  ON public.contact_message_replies FOR INSERT
  TO authenticated
  WITH CHECK (
    author_role = 'admin'
    AND (SELECT public.is_admin())
  );

-- SELECT user : lit toutes les reponses d'un thread dont il est proprietaire.
DROP POLICY IF EXISTS "Users read own thread replies" ON public.contact_message_replies;
CREATE POLICY "Users read own thread replies"
  ON public.contact_message_replies FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.contact_messages m
       WHERE m.id = contact_message_id
         AND m.user_id = (SELECT auth.uid())
    )
  );

-- SELECT admin : lit toutes les reponses de tous les threads.
DROP POLICY IF EXISTS "Admins read all replies" ON public.contact_message_replies;
CREATE POLICY "Admins read all replies"
  ON public.contact_message_replies FOR SELECT
  TO authenticated
  USING ((SELECT public.is_admin()));


-- TRIGGER ------------------------------------------------------------
-- A chaque nouvelle reponse, on met a jour le status du thread parent :
--   - Si la reponse vient de l'admin -> status = 'responded'
--   - Si la reponse vient de l'user (apres reponse admin) -> retour 'new'
--     (pour que ca remonte dans l'onglet "Nouveaux" de l'admin)
CREATE OR REPLACE FUNCTION public.tg_contact_reply_update_status()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NEW.author_role = 'admin' THEN
    UPDATE public.contact_messages
       SET status = 'responded',
           reviewed_at = NEW.created_at,
           reviewed_by = NEW.author_email
     WHERE id = NEW.contact_message_id;
  ELSIF NEW.author_role = 'user' THEN
    -- L'utilisateur a relance -> re-prioriser cote admin (status 'new').
    UPDATE public.contact_messages
       SET status = 'new'
     WHERE id = NEW.contact_message_id
       AND status IN ('responded', 'read', 'archived');
  END IF;
  RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.tg_contact_reply_update_status() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS trg_contact_reply_status ON public.contact_message_replies;
CREATE TRIGGER trg_contact_reply_status
  AFTER INSERT ON public.contact_message_replies
  FOR EACH ROW EXECUTE FUNCTION public.tg_contact_reply_update_status();


-- AUDIT --------------------------------------------------------------
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'tg_admin_audit_log') THEN
    EXECUTE 'DROP TRIGGER IF EXISTS trg_audit_contact_replies ON public.contact_message_replies';
    EXECUTE 'CREATE TRIGGER trg_audit_contact_replies
             AFTER UPDATE OR DELETE ON public.contact_message_replies
             FOR EACH ROW EXECUTE FUNCTION public.tg_admin_audit_log()';
  END IF;
END $$;
