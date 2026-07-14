-- =============================================================================
-- 02_profiles.sql
-- User profiles linked to Supabase Auth
-- =============================================================================

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

-- Align display_name length with Flutter ValidationUtils (max 50 chars)
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
