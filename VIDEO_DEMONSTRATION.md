# Video Demonstration Script — NoteVault

**Requirement:** Item 6 — Video Demonstration (3–5 minutes)  
**Project:** NoteVault  
**Submitted by:** Ronar D. Morales  
**Course:** CC106 — Bachelor of Science in Information System  
**How to record:** Run the app on a simulator, emulator, physical device, or Chrome. Narrate while you demonstrate the **user flow** and **system functionality**.

---

## Timing Overview (~4:30)

| Time | Section | System functionality |
|------|---------|----------------------|
| 0:00 – 0:25 | Opening | Flutter app + Supabase overview |
| 0:25 – 1:00 | Sign up | Authentication + validation |
| 1:00 – 1:25 | Login | Session + Realtime |
| 1:25 – 1:55 | Profile | Profiles + Storage + RLS |
| 1:55 – 2:50 | Notes CRUD | Create / Read / Update / Delete + optional reminder |
| 2:50 – 3:40 | Life Spaces | Unique organizer + filter notes |
| 3:40 – 4:10 | Archive | Soft archive / restore |
| 4:10 – 4:30 | Logout + close | Secure sign-out + tech stack recap |

---

## Full Narration Script

### 1. Opening (0:00 – 0:25)

> “Good day. For my CC106 Final Project, I will demonstrate **NoteVault**, a candy-pink note-taking application built with **Flutter** and **Supabase**.
>
> NoteVault supports secure login, personal profiles, notes with optional reminders, **Life Spaces** as my unique organizer, and an **Archive** for notes I want to keep but hide from the main list.
>
> I will walk through the main **user flow** and highlight how the system works.”

**Do on screen:** Open the app → show login / Join screen (Android: briefly show app icon first).

---

### 2. Sign up — Authentication & validation (0:25 – 1:00)

> “First is **user registration**. I tap **Join**, enter my full name, email, and password. The app validates the email format and requires at least six characters for the password — no complex format rules.
>
> When I create the account, Supabase **Authentication** stores the user. The app then signs me out on purpose and returns me to **Sign in** with a success message. This means only a user who logs in can enter the vault.”

**Do on screen:** Join → fill form → Create my vault → loading → Sign in with success message.

**System points to mention:** Supabase Auth, input validation / sanitization.

---

### 3. Login — Session & Realtime (1:00 – 1:25)

> “Now I **sign in**. While the app connects, you see an animated loading screen.
>
> After login, I reach the **home notes screen**. The green cloud icon means **Supabase Realtime** is connected, so notes and spaces stay synced with the PostgreSQL database.”

**Do on screen:** Sign in → loading → home → briefly point at sync icon.

**System points:** Auth session, Provider state, Realtime.

---

### 4. Profile — Name & photo upload (1:25 – 1:55)

> “Next is the **profile**. I can edit my display name and save it to the **profiles** table.
>
> I can also upload a profile picture from the gallery. The image goes to **Supabase Storage**, and Row Level Security ensures I can only update my own profile.”

**Do on screen:** Open Profile → edit name → Save → upload photo → show updated avatar → back.

**System points:** `profiles` table, Storage, RLS, `image_picker`.

---

### 5. Notes CRUD — Core functionality (1:55 – 2:50)

> “The core feature is **notes CRUD** — Create, Read, Update, and Delete.
>
> I tap **New Note**, write a title and content, and save. A reminder is **optional** — I can save without one.
>
> For a second note, I can set a **reminder** for a future date and time. Only then does reminder validation run. On Android, the app can request notification permission so the phone alerts me later.
>
> I can also add a candy color tag and assign the note to a Life Space.
>
> Back on home, notes appear in a grid. I can search, open a note to **edit**, or **delete** with confirmation. Everything is stored in Supabase and cached locally for a smoother experience.”

**Do on screen:** New Note → save one without reminder → New Note with reminder + color (optional) → edit → show search briefly.

**System points:** Notes table CRUD, optional `reminder_at`, local notifications, search, local cache.

---

### 6. Life Spaces — Unique organizer (2:50 – 3:40)

> “My unique feature is **Life Spaces**. Instead of only one long list of notes, I organize notes by areas of life — for example School or Work.
>
> I open Life Spaces. I can use a **quick template**, or create my own space. When creating, I set a name, optional motto, **mood vibe** — Focus, Chill, Boost, or Reset — a **weekly note goal**, emoji, candy color, and I can turn on **Today’s Focus** so that space is highlighted on home.
>
> After saving, I go back home, filter by that space, and assign notes to it. So Life Spaces is not just a folder — it is a personalized board with mood, goals, and focus.”

**Do on screen:** Life Spaces → quick template **or** New Space (show motto / mood / goal / focus) → Create → home → filter chip → open a note assigned to that space (or assign one).

**System points:** `spaces` table, note `space_id`, filter on home, unique organizer.

---

### 7. Archive — Soft storage (3:40 – 4:10)

> “NoteVault also has an **Archive**. If I no longer need a note on the main screen, I can archive it instead of deleting it permanently.
>
> Archived notes appear in the Archive view. I can **restore** them anytime, or delete them for good when I am ready.”

**Do on screen:** Archive a note → open Archive icon → show archived note → Restore (optional).

**System points:** `is_archived` / `archived_at`, restore flow.

---

### 8. Logout & closing (4:10 – 4:30)

> “Finally, in **Settings**, I log out. The app shows a safe sign-out loading screen and returns to login.
>
> To summarize: NoteVault uses **Flutter**, **Supabase Authentication**, **PostgreSQL** with **Row Level Security**, **Realtime**, **Storage** for avatars, **Provider** for state, Life Spaces, Archive, and optional **local notifications**.
>
> Thank you for watching my demonstration.”

**Do on screen:** Settings → Log out → loading → login → end.

---

## System Functionality Checklist (say or show at least these)

- [ ] Supabase Authentication (sign up / login / logout)  
- [ ] Input validation (email, name, password min length, notes)  
- [ ] Profile edit + profile picture (Supabase Storage)  
- [ ] Notes CRUD (Create, Read, Update, Delete)  
- [ ] Optional note reminders + local notifications (Android)  
- [ ] Search notes  
- [ ] Life Spaces organizer (templates, mood, motto, weekly goal, Today’s Focus, filter)  
- [ ] Archive / restore  
- [ ] Supabase Database + Realtime sync  
- [ ] Row Level Security (brief mention)  

---

## Before You Record

1. Enable Email sign-ups in Supabase Dashboard.  
2. Run `supabase/sql/full_schema.sql` (and Life Spaces SQL if needed).  
3. Use a demo account (any email + password with 6+ characters).  
4. Keep the video **3 to 5 minutes** — follow the timing table above.  
5. Speak clearly; tap slowly so the narration matches the screen.

---

## Short “memory card” (if you forget lines)

1. Intro → NoteVault, Flutter + Supabase  
2. Join → Sign in → Home (Realtime)  
3. Profile → name + photo  
4. Notes CRUD + optional reminder  
5. Life Spaces → mood, goal, focus, filter  
6. Archive → restore  
7. Logout → Flutter, Supabase, RLS — thank you  
