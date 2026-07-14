-- =============================================================================
-- 06_indexes.sql
-- Performance indexes for notes and profiles
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_notes_user_id
  ON public.notes (user_id);

CREATE INDEX IF NOT EXISTS idx_notes_created_at
  ON public.notes (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notes_user_created
  ON public.notes (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notes_reminder_at
  ON public.notes (reminder_at)
  WHERE reminder_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_profiles_email
  ON public.profiles (email);
