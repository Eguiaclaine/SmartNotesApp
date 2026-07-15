# Gemini Prompt — NoteVault Architecture Diagram

Use this file to generate an architecture diagram for your **project report** (Architecture Diagram / data-flow visualization).

Copy the prompt below into **Gemini** (or another image generator).  
Important: NoteVault has **no dark mode**. Do not include Dark Mode, Theme Provider, or theme preference.

---

## Ready-to-paste Gemini prompt

```
Create a clean system architecture diagram for a mobile/web app called "NoteVault".

Title at the top:
"NoteVault — System Architecture"

Style:
- Modern software architecture diagram, dark background, rounded rectangles, high contrast
- Three horizontal layers stacked vertically, similar to a Flutter + Supabase SaaS architecture poster
- Clear labels, neat arrows, professional for a college CC106 final project report
- Use purple for the Flutter client layer, blue for the Supabase backend layer, and charcoal/gray for the on-device layer
- Do NOT include dark mode, theme toggle, Theme Provider, or theme preference anywhere

LAYER 1 — Top box labeled:
"Flutter Client (Frontend) — Dart · Material 3 · Candy Pink Theme · Android APK / Web"

Inside Layer 1, three rows:

Row A — "Screens (UI Layer)" — four pink/purple boxes:
1. Auth screens — Join / Sign in
2. Notes screens — CRUD + search + optional reminders
3. Life Spaces + Archive — unique organizer & archive vault
4. Profile screen — edit info + photo upload

Row B — "Provider — State Management" — four green boxes:
1. Auth provider — session / sign in / sign up / sign out
2. Notes provider — notes list, CRUD, search, archive
3. Spaces provider — Life Spaces, focus, weekly goals
4. Profile provider — display name + avatar

Row C — dark bar across the bottom of Layer 1:
"Input validation & sanitization"

LAYER 2 — Middle box labeled:
"Supabase Backend (Cloud BaaS)"

Inside Layer 2, three blue service boxes side by side:
1. Auth service — email + password, JWT session, register / login / logout
2. PostgreSQL database — profiles, notes, spaces tables · Row Level Security (RLS)
3. Storage — profile pictures · secure access policies

Below those, a teal/cyan bar:
"Realtime subscriptions — live sync for notes, spaces, and profiles"

Footer bar of Layer 2:
"Row-level security — each user accesses only their own data"

LAYER 3 — Bottom box labeled:
"On-device Storage (Local)"

Three gray boxes side by side:
1. SharedPreferences — local cache of notes/spaces · user settings (NO theme preference)
2. Local notifications — flutter_local_notifications · note reminders
3. image_picker — gallery photo selection for profile upload

Connections / arrows:
- Draw arrows from Provider boxes up to UI screens
- Draw a bidirectional dotted teal arrow between Flutter Client and Supabase labeled "API / Realtime"
- Draw a vertical dotted line from Supabase down toward On-device Storage
- Show Auth service pointing to PostgreSQL
- Show image_picker connecting toward Supabase Storage (upload flow)

Footer text under the whole diagram:
"Flutter Client ↔ Supabase Auth + Database + Storage + Realtime | Local cache & notifications"

Important exclusions:
- No dark mode box
- No Theme provider
- No light/dark toggle
- Do not write Riverpod — use Provider
- App theme is candy pink light only
```

---

## Shorter alternate prompt (if Gemini truncates)

```
Draw a 3-layer architecture diagram titled "NoteVault — System Architecture" on a dark background.

Top (purple): Flutter Client — Screens: Auth, Notes CRUD, Life Spaces + Archive, Profile. State: Auth / Notes / Spaces / Profile Providers. Bottom bar: Input validation & sanitization. Candy pink Material 3 theme. NO dark mode.

Middle (blue): Supabase — Auth service, PostgreSQL (profiles, notes, spaces + RLS), Storage (avatars), Realtime subscriptions.

Bottom (gray): SharedPreferences cache, local notifications, image_picker.

Show API/Realtime arrows between Flutter and Supabase. Label: Flutter ↔ Supabase Auth + DB + Storage + Realtime.
```

---

## What to check after Gemini generates the image

- [ ] Title says **NoteVault**
- [ ] State management says **Provider** (not Riverpod)
- [ ] **Life Spaces** and **Archive** appear
- [ ] Database mentions **profiles, notes, spaces**
- [ ] **No dark mode / Theme provider / theme preference**
- [ ] Realtime + RLS mentioned
- [ ] Candy pink / light theme only (optional label)

---

## Where this fits in your submission

**Requirement 5 — Architecture Diagram:** export Gemini’s image as PNG/PDF and include it in your project report with a short caption, for example:

> Figure: NoteVault system architecture showing Flutter client, Provider state management, Supabase Auth/Database/Storage/Realtime, and on-device cache with local notifications.
