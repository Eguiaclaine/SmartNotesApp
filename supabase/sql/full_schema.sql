-- =============================================================================
-- full_schema.sql
-- Smart Notes App — ALL-IN-ONE schema (copy & paste into Supabase SQL Editor)
-- =============================================================================
-- Merges: 01–14 (extensions, profiles, notes, spaces/Life Spaces, storage,
--         RLS, indexes, triggers, realtime, auth, archive, enhanced spaces,
--         password notes, note-update fix, life-spaces align)
--
-- Safe to re-run: uses IF NOT EXISTS, DROP POLICY IF EXISTS, and idempotent
-- realtime publication check.
-- Existing projects that already ran an older full_schema: also run
--   14_life_spaces_align.sql and 13_notes_update_fix.sql if needed.
--
-- BEFORE running: enable Email sign-ups in Supabase Dashboard
--   Authentication → Providers → Email → Enable sign ups
-- Password policy (see also 12_password_policy.sql):
--   Minimum length 6 only — NO uppercase / number / special-character format
--
-- After register: profile row is created by handle_new_user trigger;
-- app signs user out and shows login (no auto-redirect to dashboard).
--
-- Demo seed data is separate: supabase/demo/demo_accounts.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 01_extensions.sql
-- -----------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------------------------------------------------------
-- 02_profiles.sql
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  email TEXT,
  display_name TEXT CHECK (
    display_name IS NULL
    OR (
      char_length(trim(display_name)) > 0
      AND char_length(display_name) <= 50
    )
  ),
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.profiles IS 'Extended user profile data for Smart Notes users';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'profiles_display_name_check'
      AND conrelid = 'public.profiles'::regclass
  ) THEN
    ALTER TABLE public.profiles
      ADD CONSTRAINT profiles_display_name_check CHECK (
        display_name IS NULL
        OR (
          char_length(trim(display_name)) > 0
          AND char_length(display_name) <= 50
        )
      );
  END IF;
END;
$$;

-- -----------------------------------------------------------------------------
-- 03_notes.sql
-- -----------------------------------------------------------------------------
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

COMMENT ON TABLE public.notes IS 'NoteVault — user notes with optional reminders, archive, and Life Spaces';
COMMENT ON COLUMN public.notes.reminder_at IS 'Optional reminder; only validated when set (must be in the future)';

-- -----------------------------------------------------------------------------
-- 03b_spaces.sql (Life Spaces organizer)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.spaces (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (
    char_length(trim(name)) > 0
    AND char_length(name) <= 40
  ),
  emoji TEXT NOT NULL DEFAULT '💗',
  color_hex TEXT NOT NULL DEFAULT '#FF8FB8',
  motto TEXT,
  mood TEXT NOT NULL DEFAULT 'focus',
  weekly_goal INTEGER NOT NULL DEFAULT 5,
  is_focus BOOLEAN NOT NULL DEFAULT FALSE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.spaces IS
  'NoteVault Life Spaces — organizer boards (emoji, color, mood, motto, weekly goal, focus). Flutter SpacesProvider reads/writes this table for Notes + Life Spaces screens.';
COMMENT ON COLUMN public.spaces.mood IS 'focus | chill | boost | reset';
COMMENT ON COLUMN public.spaces.weekly_goal IS 'Target notes per week (1-50)';
COMMENT ON COLUMN public.spaces.is_focus IS 'Today''s Focus Space';

ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS motto TEXT;
ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS mood TEXT NOT NULL DEFAULT 'focus';
ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS weekly_goal INTEGER NOT NULL DEFAULT 5;
ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS is_focus BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE public.spaces ADD COLUMN IF NOT EXISTS sort_order INTEGER NOT NULL DEFAULT 0;

-- Align with Flutter SpaceMood + SpacesProvider validation (same as 14_life_spaces_align)
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

ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS is_archived BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;
ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS space_id UUID REFERENCES public.spaces (id) ON DELETE SET NULL;
ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS color_tag TEXT;

-- -----------------------------------------------------------------------------
-- 04_storage.sql
-- -----------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  (
    'profile-avatars',
    'profile-avatars',
    TRUE,
    2097152,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
  ),
  (
    'entry-images',
    'entry-images',
    TRUE,
    5242880,
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
  )
ON CONFLICT (id) DO UPDATE
SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- -----------------------------------------------------------------------------
-- 05_rls_policies.sql
-- -----------------------------------------------------------------------------
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.spaces ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can view own notes" ON public.notes;
CREATE POLICY "Users can view own notes"
  ON public.notes FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own notes" ON public.notes;
CREATE POLICY "Users can insert own notes"
  ON public.notes FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own notes" ON public.notes;
CREATE POLICY "Users can update own notes"
  ON public.notes FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own notes" ON public.notes;
CREATE POLICY "Users can delete own notes"
  ON public.notes FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view own spaces" ON public.spaces;
CREATE POLICY "Users can view own spaces"
  ON public.spaces FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own spaces" ON public.spaces;
CREATE POLICY "Users can insert own spaces"
  ON public.spaces FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own spaces" ON public.spaces;
CREATE POLICY "Users can update own spaces"
  ON public.spaces FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own spaces" ON public.spaces;
CREATE POLICY "Users can delete own spaces"
  ON public.spaces FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can upload own avatar" ON storage.objects;
CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'profile-avatars'
    AND auth.uid()::TEXT = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Anyone can view avatars" ON storage.objects;
CREATE POLICY "Anyone can view avatars"
  ON storage.objects FOR SELECT USING (bucket_id = 'profile-avatars');

DROP POLICY IF EXISTS "Users can update own avatar" ON storage.objects;
CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'profile-avatars'
    AND auth.uid()::TEXT = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Users can delete own avatar" ON storage.objects;
CREATE POLICY "Users can delete own avatar"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'profile-avatars'
    AND auth.uid()::TEXT = (storage.foldername(name))[1]
  );

-- -----------------------------------------------------------------------------
-- 06_indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_notes_user_id ON public.notes (user_id);
CREATE INDEX IF NOT EXISTS idx_notes_created_at ON public.notes (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notes_user_created ON public.notes (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notes_reminder_at ON public.notes (reminder_at) WHERE reminder_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles (email);
CREATE INDEX IF NOT EXISTS idx_spaces_user_id ON public.spaces (user_id);
CREATE INDEX IF NOT EXISTS idx_spaces_user_focus ON public.spaces (user_id, is_focus);
CREATE INDEX IF NOT EXISTS idx_notes_space_id ON public.notes (space_id);
CREATE INDEX IF NOT EXISTS idx_notes_is_archived ON public.notes (user_id, is_archived);

-- -----------------------------------------------------------------------------
-- 07_functions_triggers.sql
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_notes_updated_at ON public.notes;
CREATE TRIGGER set_notes_updated_at
  BEFORE UPDATE ON public.notes
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_spaces_updated_at ON public.spaces;
CREATE TRIGGER set_spaces_updated_at
  BEFORE UPDATE ON public.spaces
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

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

COMMENT ON FUNCTION public.validate_note_reminder IS
  'Allows note edits with unchanged past reminders; only blocks newly set past reminders';

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(
      NEW.raw_user_meta_data ->> 'display_name',
      NEW.raw_user_meta_data ->> 'full_name',
      split_part(NEW.email, '@', 1)
    )
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- -----------------------------------------------------------------------------
-- 08_realtime.sql (safe to re-run)
-- -----------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'notes'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.notes;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'profiles'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
  END IF;

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

-- -----------------------------------------------------------------------------
-- 09_auth_setup.sql
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.sync_auth_users_to_profiles()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  synced_count INTEGER;
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  SELECT
    u.id,
    u.email,
    COALESCE(
      u.raw_user_meta_data ->> 'display_name',
      u.raw_user_meta_data ->> 'full_name',
      split_part(u.email, '@', 1)
    )
  FROM auth.users AS u
  ON CONFLICT (id) DO UPDATE
  SET
    email = EXCLUDED.email,
    display_name = COALESCE(EXCLUDED.display_name, public.profiles.display_name);

  GET DIAGNOSTICS synced_count = ROW_COUNT;
  RETURN synced_count;
END;
$$;

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notes TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.spaces TO authenticated;
GRANT ALL ON public.profiles TO service_role;
GRANT ALL ON public.notes TO service_role;
GRANT ALL ON public.spaces TO service_role;

COMMENT ON FUNCTION public.sync_auth_users_to_profiles IS
  'Backfill profiles from auth.users. NoteVault passwords: min 6 chars, no complexity format required.';

-- After first users register, run:
-- SELECT public.sync_auth_users_to_profiles();
-- Password policy notes: supabase/sql/12_password_policy.sql
