-- =============================================================================
-- 11_spaces_enhanced.sql
-- NoteVault Life Spaces — mood, weekly goal, focus space, motto
-- Run after 10_spaces_archive.sql (safe to re-run)
-- =============================================================================

ALTER TABLE public.spaces
  ADD COLUMN IF NOT EXISTS motto TEXT;

ALTER TABLE public.spaces
  ADD COLUMN IF NOT EXISTS mood TEXT NOT NULL DEFAULT 'focus';

ALTER TABLE public.spaces
  ADD COLUMN IF NOT EXISTS weekly_goal INTEGER NOT NULL DEFAULT 5;

ALTER TABLE public.spaces
  ADD COLUMN IF NOT EXISTS is_focus BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE public.spaces
  ADD COLUMN IF NOT EXISTS sort_order INTEGER NOT NULL DEFAULT 0;

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

COMMENT ON COLUMN public.spaces.mood IS 'Life Space vibe: focus, chill, boost, reset';
COMMENT ON COLUMN public.spaces.weekly_goal IS 'Target number of notes for this space this week';
COMMENT ON COLUMN public.spaces.is_focus IS 'Today''s Focus Space (highlighted in the app)';

-- Align UPDATE RLS with Flutter save path
DROP POLICY IF EXISTS "Users can update own spaces" ON public.spaces;
CREATE POLICY "Users can update own spaces"
  ON public.spaces FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.spaces TO authenticated;
