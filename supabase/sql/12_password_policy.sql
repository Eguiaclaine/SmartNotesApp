-- =============================================================================
-- 12_password_policy.sql
-- NoteVault auth password policy (no complexity format)
-- =============================================================================
-- Passwords are managed by Supabase Auth (auth.users), not a custom SQL table.
-- This script documents and aligns the project policy with the Flutter app:
--
--   • NO required uppercase / lowercase / number / special-character format
--   • Minimum length only: 6 characters (Supabase Auth default)
--
-- Dashboard checklist (SQL cannot change Auth password strength UI settings):
--   1. Authentication → Providers → Email
--   2. Enable Email provider + sign ups
--   3. Set minimum password length to 6 (or leave default)
--   4. Do NOT enable extra strength / complexity rules if your project has them
--
-- Optional: after changing Auth settings, sync any orphan users into profiles:
--   SELECT public.sync_auth_users_to_profiles();
-- =============================================================================

COMMENT ON FUNCTION public.sync_auth_users_to_profiles IS
  'Backfill profiles from auth.users. NoteVault passwords: min 6 chars, no complexity format required.';
