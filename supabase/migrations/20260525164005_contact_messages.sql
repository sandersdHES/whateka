CREATE TABLE IF NOT EXISTS public.contact_messages (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  sender_email TEXT,
  sender_name TEXT,
  subject TEXT NOT NULL CHECK (length(trim(subject)) > 0),
  message TEXT NOT NULL CHECK (length(trim(message)) > 0),
  status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'read', 'responded', 'archived')),
  reviewed_at TIMESTAMPTZ,
  reviewed_by TEXT,
  admin_notes TEXT
);

CREATE INDEX IF NOT EXISTS contact_messages_status_idx ON public.contact_messages(status) WHERE status <> 'archived';
CREATE INDEX IF NOT EXISTS contact_messages_user_idx ON public.contact_messages(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS contact_messages_created_at_idx ON public.contact_messages(created_at DESC);

COMMENT ON TABLE public.contact_messages IS 'Messages user -> equipe Whateka via le formulaire interne du profil. Migration 0018.';

ALTER TABLE public.contact_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated users can send messages" ON public.contact_messages;
CREATE POLICY "Authenticated users can send messages" ON public.contact_messages FOR INSERT TO authenticated WITH CHECK (user_id = (SELECT auth.uid()) OR (user_id IS NULL AND sender_email IS NOT NULL));

DROP POLICY IF EXISTS "Users read own messages" ON public.contact_messages;
CREATE POLICY "Users read own messages" ON public.contact_messages FOR SELECT TO authenticated USING ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Admins read all messages" ON public.contact_messages;
CREATE POLICY "Admins read all messages" ON public.contact_messages FOR SELECT TO authenticated USING ((SELECT public.is_admin()));

DROP POLICY IF EXISTS "Admins update messages" ON public.contact_messages;
CREATE POLICY "Admins update messages" ON public.contact_messages FOR UPDATE TO authenticated USING ((SELECT public.is_admin())) WITH CHECK ((SELECT public.is_admin()));

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'tg_admin_audit_log') THEN
    EXECUTE 'DROP TRIGGER IF EXISTS trg_audit_contact_messages ON public.contact_messages';
    EXECUTE 'CREATE TRIGGER trg_audit_contact_messages AFTER UPDATE OR DELETE ON public.contact_messages FOR EACH ROW EXECUTE FUNCTION public.tg_admin_audit_log()';
  END IF;
END $$;
