# 4. Tech Stack

## Core Technologies

| Layer | Technology |
|-------|------------|
| Frontend Framework | Flutter (Dart) |
| Backend Platform | Supabase (Authentication, PostgreSQL Database, Storage, Realtime) |
| State Management | Provider |
| Local Storage | SharedPreferences |
| Notifications | flutter_local_notifications, timezone |
| Image Selection | image_picker |
| UI Framework | Material 3 (Candy Pink light theme) |
| Security & Validation | Custom Validation and Sanitization Utilities, Supabase RLS |
| Development Environment | Visual Studio Code / Android Studio |
| Version Control | Git & GitHub |
| Android Build | Flutter APK (debug) with adaptive launcher icon |

## Packages / Plugins Used

- `supabase_flutter`
- `provider`
- `shared_preferences`
- `flutter_local_notifications`
- `image_picker`
- `intl`
- `uuid`
- `flutter_dotenv`
- `timezone`
- `google_fonts`
- `flutter_launcher_icons` (for native APK icon generation)

## Database Schema (Supabase SQL)

- **profiles:** Manages user profile data (display name, email, avatar URL).
- **notes:** Manages note text assets (title, content, optional `reminder_at` timestamp, archive fields, optional Life Space assignment, candy color tags).
- **spaces:** Manages Life Spaces (name, emoji, color, motto, mood, weekly goal, Today’s Focus).
- **Storage Bucket:** Dedicated `profile-avatars` bucket for image hosting.
- **Backend Security:** Configured with strict RLS policies, automated triggers, and realtime replication publications.
- **Schema Blueprint Location:** `supabase/sql/full_schema.sql`

---

# 5. Architecture / Flow Diagram

## High-level user flow

```
User
  │
  ▼
Authentication (Supabase Auth)
  │  Join / Sign in / Sign out
  ▼
Flutter Client (Provider state)
  │
  ├── Profile (edit name + upload photo → Supabase Storage)
  ├── Notes CRUD (create / read / update / delete + search + optional reminder)
  ├── Life Spaces (templates, mood, motto, weekly goal, Today’s Focus, filter)
  └── Archive (archive / restore notes)
  │
  ▼
Supabase PostgreSQL + Realtime
  (profiles · notes · spaces · RLS)
  │
  ▼
Local Cache (SharedPreferences)
  + Local notifications (optional note reminders)
```

## Short caption for the report

> NoteVault architecture: the user authenticates through Supabase, then uses Profile, Notes CRUD, Life Spaces, and Archive in the Flutter client. Data syncs with Supabase PostgreSQL, Storage, and Realtime, while SharedPreferences caches data locally and local notifications handle optional reminders. The app uses a candy pink Material 3 light theme only (no dark mode).

## One-line flow (for slides)

```
User → Supabase Auth → Profile / Notes CRUD / Life Spaces / Archive / Notifications
                              │
                              ▼
                 Supabase PostgreSQL + Realtime + Storage
                              │
                              ▼
                 Local Cache (SharedPreferences)
```
