-- =============================================================================
-- 10_spaces_archive.sql
-- NoteVault: Life Spaces organizer + note archive support
-- Safe to re-run after full_schema.sql
-- =============================================================================

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

COMMENT ON TABLE public.spaces IS 'NoteVault Life Spaces — unique organizer boards for notes';

ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS is_archived BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;

ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS space_id UUID REFERENCES public.spaces (id) ON DELETE SET NULL;

ALTER TABLE public.notes
  ADD COLUMN IF NOT EXISTS color_tag TEXT;

CREATE INDEX IF NOT EXISTS idx_spaces_user_id ON public.spaces (user_id);
CREATE INDEX IF NOT EXISTS idx_notes_space_id ON public.notes (space_id);
CREATE INDEX IF NOT EXISTS idx_notes_is_archived ON public.notes (user_id, is_archived);

ALTER TABLE public.spaces ENABLE ROW LEVEL SECURITY;

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

DROP TRIGGER IF EXISTS set_spaces_updated_at ON public.spaces;
CREATE TRIGGER set_spaces_updated_at
  BEFORE UPDATE ON public.spaces
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

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
