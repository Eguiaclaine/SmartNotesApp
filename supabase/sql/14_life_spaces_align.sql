-- =============================================================================
-- 14_life_spaces_align.sql
-- NoteVault — COMPLETE Life Spaces schema (one-shot, safe to re-run)
-- Fixes save errors when motto / mood / weekly_goal / is_focus / sort_order
-- columns or RLS were missing.
-- Run this in Supabase SQL Editor after full_schema OR alone.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Ensure updated_at helper exists (needed by trigger)
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- Base table
CREATE TABLE IF NOT EXISTS public.spaces (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (
    char_length(trim(name)) > 0
    AND char_length(name) <= 40
  ),
  emoji TEXT NOT NULL DEFAULT '💗',
  color_hex TEXT NOT NULL DEFAULT '#FF8FB8',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enhanced columns used by the Flutter app
ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS motto TEXT;
ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS mood TEXT NOT NULL DEFAULT 'focus';
ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS weekly_goal INTEGER NOT NULL DEFAULT 5;
ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS is_focus BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS sort_order INTEGER NOT NULL DEFAULT 0;

-- Constraints (idempotent)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'spaces_mood_check'
      AND conrelid = 'public.spaces'::regclass
  ) THEN
    ALTER TABLE public.spaces
      ADD CONSTRAINT spaces_mood_check
      CHECK (mood IN ('focus', 'chill', 'boost', 'reset'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'spaces_weekly_goal_check'
      AND conrelid = 'public.spaces'::regclass
  ) THEN
    ALTER TABLE public.spaces
      ADD CONSTRAINT spaces_weekly_goal_check
      CHECK (weekly_goal >= 1 AND weekly_goal <= 50);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'spaces_motto_len_check'
      AND conrelid = 'public.spaces'::regclass
  ) THEN
    ALTER TABLE public.spaces
      ADD CONSTRAINT spaces_motto_len_check
      CHECK (motto IS NULL OR char_length(motto) <= 80);
  END IF;
END;
$$;

-- Notes link to spaces
ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS space_id UUID REFERENCES public.spaces (id) ON DELETE SET NULL;
ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS is_archived BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;
ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS color_tag TEXT;

CREATE INDEX IF NOT EXISTS idx_spaces_user_id ON public.spaces (user_id);
CREATE INDEX IF NOT EXISTS idx_spaces_user_focus ON public.spaces (user_id, is_focus);
CREATE INDEX IF NOT EXISTS idx_notes_space_id ON public.notes (space_id);

-- RLS
ALTER TABLE public.spaces ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own spaces" ON public.spaces;
CREATE POLICY "Users can view own spaces"
  ON public.spaces FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own spaces" ON public.spaces;
CREATE POLICY "Users can insert own spaces"
  ON public.spaces FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own spaces" ON public.spaces;
CREATE POLICY "Users can update own spaces"
  ON public.spaces FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own spaces" ON public.spaces;
CREATE POLICY "Users can delete own spaces"
  ON public.spaces FOR DELETE
  USING (auth.uid() = user_id);

DROP TRIGGER IF EXISTS set_spaces_updated_at ON public.spaces;
CREATE TRIGGER set_spaces_updated_at
  BEFORE UPDATE ON public.spaces
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- Realtime
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'spaces'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.spaces;
  END IF;
END;
$$;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.spaces TO authenticated;
GRANT ALL ON public.spaces TO service_role;

COMMENT ON TABLE public.spaces IS
  'NoteVault Life Spaces — organizer boards (emoji, color, mood, motto, weekly goal, focus). Required by Flutter Notes + Life Spaces UI (SpacesProvider).';
COMMENT ON COLUMN public.spaces.mood IS 'focus | chill | boost | reset';
COMMENT ON COLUMN public.spaces.weekly_goal IS 'Target notes per week (1-50)';
COMMENT ON COLUMN public.spaces.is_focus IS 'Today''s Focus Space';
