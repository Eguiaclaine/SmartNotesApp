-- =============================================================================
-- DEMO ACCOUNTS — run separately AFTER full_schema.sql + enabling Email sign-ups
-- =============================================================================
-- Prerequisite: Supabase Dashboard → Authentication → Providers → Email
--   • Enable Email provider
--   • Enable sign ups
--
-- Option A — Register via the app (recommended):
--   Use the Create Account screen with your email and password.
--
-- Option B — Create user in Dashboard, then seed data:
--   Authentication → Users → Add user
--   Then run the SELECT queries at the bottom of this file.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.seed_demo_notes_for_user(target_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  inserted_count INTEGER;
BEGIN
  IF target_user_id IS NULL THEN
    RAISE EXCEPTION 'target_user_id is required';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = target_user_id) THEN
    RAISE EXCEPTION 'User % does not exist in auth.users', target_user_id;
  END IF;

  DELETE FROM public.notes
  WHERE user_id = target_user_id
    AND title LIKE '[Demo]%';

  INSERT INTO public.notes (user_id, title, content, reminder_at, created_at)
  VALUES
    (
      target_user_id,
      '[Demo] sample task 1',
      'Create Crud Operation',
      NOW() + INTERVAL '2 days',
      NOW() - INTERVAL '1 day'
    ),
    (
      target_user_id,
      '[Demo] CRUD COMPLETE',
      'DONE!',
      NULL,
      NOW() - INTERVAL '2 days'
    );

  GET DIAGNOSTICS inserted_count = ROW_COUNT;
  RETURN inserted_count;
END;
$$;

CREATE OR REPLACE FUNCTION public.seed_demo_profile_for_user(
  target_user_id UUID,
  target_display_name TEXT DEFAULT 'Demo User'
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  SELECT id, email, target_display_name
  FROM auth.users
  WHERE id = target_user_id
  ON CONFLICT (id) DO UPDATE
  SET display_name = EXCLUDED.display_name;
END;
$$;

-- Demo credentials (register via app after sign-ups are enabled):
--   demo@smartnotes.app      / Demo1234!
--   tester@smartnotes.app    / Demo1234!
--
-- After registering, sync profiles and seed notes:
-- SELECT public.sync_auth_users_to_profiles();
-- SELECT id, email FROM auth.users WHERE email = 'demo@smartnotes.app';
-- SELECT public.seed_demo_profile_for_user('PASTE-USER-UUID', 'Demo User');
-- SELECT public.seed_demo_notes_for_user('PASTE-USER-UUID');
