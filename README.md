# Smart Notes App

Smart Notes is a Flutter note-taking app backed by **Supabase**, aligned with the CC106 Final Project report by Ronar D. Morales.

## Features

- Supabase Authentication (Sign Up, Login, Logout)
- Profile page with editable name and profile picture upload
- Notes CRUD with title, content, and optional reminders
- Local notification reminders (`flutter_local_notifications`)
- Dark mode with SharedPreferences persistence
- Input validation and data sanitization utilities
- Supabase Realtime sync for notes
- Responsive Material 3 UI

## App structure

```text
lib/
  config/env.dart
  models/note.dart
  models/user_profile.dart
  providers/auth_provider.dart
  providers/notes_provider.dart
  providers/profile_provider.dart
  providers/theme_provider.dart
  screens/auth_screen.dart
  screens/notes_home_screen.dart
  screens/note_editor_screen.dart
  screens/profile_screen.dart
  screens/settings_screen.dart
  services/auth_service.dart
  services/notes_service.dart
  services/profile_service.dart
  services/notification_service.dart
  services/storage_service.dart
  services/supabase_service.dart
  utils/validation_utils.dart
  utils/date_format.dart
  utils/responsive.dart
  widgets/auth_form.dart
  widgets/note_card.dart
  widgets/password_requirements.dart
supabase/
  sql/01_extensions.sql … 08_realtime.sql
  sql/full_schema.sql
  demo/demo_accounts.sql
```

## Environment

Copy `.env.example` to `.env`:

```env
SUPABASE_URL=https://cbssisrbycrnrjwmqmqz.supabase.co
SUPABASE_ANON_KEY=sb_publishable_4Mb8G5KOh07PuJbGrJlALA_uv6hDu4q
```

## Supabase setup

### 1. Enable sign-ups (fixes `signup_disabled` error)

[Authentication → Providers → Email](https://supabase.com/dashboard/project/cbssisrbycrnrjwmqmqz/auth/providers):

- Turn **ON** — Enable Email provider
- Turn **ON** — Enable sign ups
- (Dev) Turn **OFF** — Confirm email for instant login

### 2. Run schema

Run `supabase/sql/full_schema.sql` in the SQL Editor.

### 3. Sync profiles after first sign-up

```sql
SELECT public.sync_auth_users_to_profiles();
```

### 4. Demo data (optional)

Run `supabase/demo/demo_accounts.sql`, then seed notes for a user UUID.

## Run locally

Use **Chrome** (recommended on macOS without Xcode). Plain `flutter run` may pick a broken Android emulator and spend time on Gradle.

```bash
flutter pub get
flutter run -d chrome
```

Other targets:

```bash
flutter run -d macos    # requires Xcode
flutter run -d chrome   # web (fastest for development)
```

## Packages

- `supabase_flutter` — Auth, database, storage, realtime
- `provider` — State management
- `flutter_local_notifications` + `timezone` — Reminders
- `shared_preferences` — Theme persistence
- `image_picker` — Profile photo selection
- `intl` — Date formatting
- `flutter_dotenv` — Environment config
- `uuid` — Note IDs
