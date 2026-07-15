-- =============================================================================
-- 13_notes_update_fix.sql
-- Fix: edited notes not saving (reminder trigger + UPDATE RLS)
-- Safe to re-run in Supabase SQL Editor
-- =============================================================================
-- Problem:
--   1) Reminder trigger rejected ANY update that included a past reminder_at,
--      even when the user only edited title/content and kept the old reminder.
--   2) Notes UPDATE RLS lacked WITH CHECK, which can block/quietly fail updates.
-- =============================================================================

-- Ensure note columns used by the app exist
ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS is_archived BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;
ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS color_tag TEXT;
ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- Only reject when reminder_at is newly set/changed to a past time.
-- Keeping an existing (possibly expired) reminder must NOT block title/content edits.
CREATE OR REPLACE FUNCTION public.validate_note_reminder()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.reminder_at IS NULL THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE'
     AND NEW.reminder_at IS NOT DISTINCT FROM OLD.reminder_at THEN
    RETURN NEW;
  END IF;

  IF NEW.reminder_at <= NOW() THEN
    RAISE EXCEPTION 'Reminder must be in the future when set';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS validate_note_reminder_before_write ON public.notes;
CREATE TRIGGER validate_note_reminder_before_write
  BEFORE INSERT OR UPDATE OF reminder_at ON public.notes
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_note_reminder();

-- Keep updated_at fresh on every edit
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS set_notes_updated_at ON public.notes;
CREATE TRIGGER set_notes_updated_at
  BEFORE UPDATE ON public.notes
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- Strengthen notes UPDATE policy (USING + WITH CHECK)
DROP POLICY IF EXISTS "Users can update own notes" ON public.notes;
CREATE POLICY "Users can update own notes"
  ON public.notes
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.notes TO authenticated;

COMMENT ON FUNCTION public.validate_note_reminder IS
  'Allows note edits with unchanged past reminders; only blocks newly set past reminders';
