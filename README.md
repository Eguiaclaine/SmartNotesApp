# NoteVault

NoteVault is a Flutter note-taking app with a candy pink theme, backed by **Supabase**.  
Unique feature: **Life Spaces** — themed boards with mood, motto, weekly goals, and Today’s Focus, plus an **Archive** vault.

## Features

- Supabase Authentication (Sign Up, Login, Logout)
- Profile page with editable name and profile picture upload
- Notes CRUD with title, content, and optional reminders
- **Life Spaces organizer** (templates, mood, motto, weekly goal, focus, filter)
- **Archive / restore** notes
- Search notes
- Local notification reminders
- Candy pink Material 3 theme (light only)
- Input validation and data sanitization
- Supabase Realtime sync

## Supabase setup

1. Enable Email sign-ups in Supabase Dashboard  
2. Run `supabase/sql/full_schema.sql`  
3. If Life Spaces / note edits fail on an existing project, also run:
   - `supabase/sql/14_life_spaces_align.sql`
   - `supabase/sql/13_notes_update_fix.sql`
4. Optional: `SELECT public.sync_auth_users_to_profiles();`

## Run

```bash
flutter pub get
flutter run -d chrome
# or Android emulator / APK:
# flutter run -d emulator-5554
# flutter build apk --debug
```

## Important SQL

| Issue | Run this |
|-------|----------|
| Life Spaces save / missing columns | `supabase/sql/14_life_spaces_align.sql` |
| Note edits not saving | `supabase/sql/13_notes_update_fix.sql` |
| Fresh database | `supabase/sql/full_schema.sql` |
