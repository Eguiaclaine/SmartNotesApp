# NoteVault

NoteVault is a Flutter note-taking app with a candy pink theme, backed by **Supabase**.  
Unique feature: **Life Spaces** — organize notes into themed boards (emoji + color), plus an **Archive** vault.

## Features

- Supabase Authentication (Sign Up, Login, Logout)
- Profile page with editable name and profile picture upload
- Notes CRUD with title, content, and optional reminders
- **Life Spaces organizer** (create/filter notes by space)
- **Archive / restore** notes
- Search notes
- Local notification reminders
- Candy pink Material 3 theme
- Input validation and data sanitization
- Supabase Realtime sync

## Supabase setup

1. Enable Email sign-ups in Supabase Dashboard  
2. Run `supabase/sql/full_schema.sql`  
   (or if schema already exists, also run `supabase/sql/10_spaces_archive.sql`)  
3. Optional: `SELECT public.sync_auth_users_to_profiles();`

## Run

```bash
flutter pub get
flutter run -d chrome
```

## Important SQL

If archive / Life Spaces fail at runtime, run:

`supabase/sql/10_spaces_archive.sql`
