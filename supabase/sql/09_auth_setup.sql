-- =============================================================================
-- 09_auth_setup.sql
-- Auth alignment: profile sync, grants, and dashboard checklist
-- =============================================================================
-- IMPORTANT — enable sign-ups in Supabase Dashboard (SQL cannot toggle this):
--   1. Go to Authentication → Providers → Email
--   2. Turn ON  "Enable Email provider"
--   3. Turn ON  "Enable sign ups"
--   4. (Dev) Turn OFF "Confirm email" for instant login after register
--   5. Password policy: minimum length 6 only — NO uppercase / number / symbol rules
--      (matches NoteVault app validation; see 12_password_policy.sql)
--
-- App auth flow: register creates auth.users + profiles row via trigger,
-- then signs the user OUT and shows the login screen (no auto-dashboard).
--
-- Project: https://supabase.com/dashboard/project/cbssisrbycrnrjwmqmqz
-- =============================================================================

-- Sync all auth.users into public.profiles (run after sign-ups or manual user creation)
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

-- Run once after enabling sign-ups or importing users:
-- SELECT public.sync_auth_users_to_profiles();

-- Table grants for authenticated users (RLS still applies)
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notes TO authenticated;

-- Service role full access (Supabase default, explicit for clarity)
GRANT ALL ON public.profiles TO service_role;
GRANT ALL ON public.notes TO service_role;

COMMENT ON FUNCTION public.sync_auth_users_to_profiles IS
  'Backfill or update profiles from auth.users after sign-up is enabled';
