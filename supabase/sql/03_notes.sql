-- =============================================================================
-- 03_notes.sql
-- Smart Notes table with title, content, and optional reminders
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  title TEXT NOT NULL CHECK (
    char_length(trim(title)) > 0
    AND char_length(title) <= 100
  ),
  content TEXT NOT NULL CHECK (
    char_length(trim(content)) > 0
    AND char_length(content) <= 5000
  ),
  reminder_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.notes IS 'Smart Notes — user notes with optional reminders';
COMMENT ON COLUMN public.notes.reminder_at IS 'Optional reminder; only validated when set (must be in the future)';
