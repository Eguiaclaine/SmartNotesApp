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

CREATE INDEX IF NOT EXISTS idx_spaces_user_id
  ON public.spaces (user_id);

CREATE INDEX IF NOT EXISTS idx_spaces_user_focus
  ON public.spaces (user_id, is_focus);

CREATE INDEX IF NOT EXISTS idx_notes_space_id
  ON public.notes (space_id);

CREATE INDEX IF NOT EXISTS idx_notes_is_archived
  ON public.notes (user_id, is_archived);
