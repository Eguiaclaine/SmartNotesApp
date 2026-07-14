# 6. Video Demonstration (3–5 Minutes)

**Project:** NoteVault App  
**Submitted by:** Ronar D. Morales  
**Course:** CC106 — Bachelor of Science in Information System  
**Platform:** Android APK / Chrome (web)

---

## What to Show

Record the app running on a **physical Android phone** or **emulator/simulator** (or Chrome for web). Speak naturally while you tap through each screen — like you are explaining the app to your instructor.

**Total time:** about 3 to 5 minutes.

---

## Video Script (Narration Guide)

### Opening — App intro (0:00 – 0:30)

> “Good day. For my CC106 Final Project, I will demonstrate **NoteVault** — a candy-pink note-taking app I built with **Flutter** and **Supabase**, including Life Spaces organizer and Archive.
>
> If you are watching on Android, you can see our custom app icon on the home screen. When I open the app, it loads with a short splash screen, then takes me to the login page.”

**On screen:** Open the app → show launcher icon (Android) → login screen.

**Technical point:** Flutter app, Supabase initialization, Material 3 UI.

---

### Sign up & validation (0:30 – 1:15)

> “First, I will show **user registration**. I tap **Create an account** and fill in my full name, email, and password.
>
> Notice the **password requirements** below the field — the app checks length, uppercase, lowercase, numbers, and special characters. This is our **input validation** working before data is sent to the server.
>
> After I register, the app does **not** go straight to the dashboard. It signs me out on purpose and returns me to login with a success message — so only registered users who log in can access their notes.”

**On screen:** Register → show password rules → submit → loading screen (“Creating your account…”) → login screen with green success message.

**Technical points:** Supabase Authentication, custom validation & sanitization, secure sign-up flow.

---

### Login & loading transition (1:15 – 1:45)

> “Now I sign in with the account I just created. While it connects, you will see an animated **loading screen** — this also appears when signing out later.
>
> Once logged in, I land on the **Notes home screen**. The green sync icon in the app bar means **Supabase Realtime** is connected, so my notes stay updated from the database.”

**On screen:** Login → loading (“Signing you in…”) → notes home → point at sync icon.

**Technical points:** Supabase Auth session, Provider state management, Realtime subscription.

---

### Profile — edit name & upload photo (1:45 – 2:30)

> “Next is the **profile feature**. I tap the profile icon and edit my display name. The name is limited to 50 characters and validated before saving.
>
> I can also tap the camera button to **upload a profile picture** from the gallery. The image is stored in **Supabase Storage**, and the profile row in our **PostgreSQL** database is updated through Row Level Security — so each user can only change their own profile.”

**On screen:** Profile → edit name → Save → pick photo → upload → show updated avatar.

**Technical points:** Supabase `profiles` table, Storage bucket `profile-avatars`, RLS, `image_picker`.

---

### Notes CRUD (2:30 – 3:45)

> “The main feature is **notes CRUD** — Create, Read, Update, and Delete.
>
> I tap **New Note**, enter a title and content, and save. No reminder is required — I can save the note right away.
>
> If I want a reminder, I tap **Set Reminder**, pick a date and time in the future, and save. The reminder is only validated when I turn it on. On Android, the app also asks for **notification permission** so the phone can alert me later.
>
> Back on the home screen, my note appears in the grid. I can tap it to **edit**, change the text, or remove the reminder. I can also **delete** a note — the app asks to confirm first.
>
> All of this is saved to **Supabase** and synced in real time. Notes are also cached locally with **SharedPreferences** for a smoother experience.”

**On screen:** New note → save without reminder → create second note with reminder → edit → delete one note.

**Technical points:** CRUD on `notes` table, optional `reminder_at`, local notifications, Realtime sync, local cache.

---

### Dark mode & settings (3:45 – 4:15)

> “In **Settings**, I can toggle **dark mode**. The choice is saved on the device using **SharedPreferences**, so it stays even after I close the app.
>
> Here is also the **Log out** button. When I tap it and confirm, the app shows a **sign-out loading screen** and safely returns me to the login page.”

**On screen:** Settings → toggle dark mode → show UI in dark theme → log out → loading (“Signing you out safely…”) → login screen.

**Technical points:** ThemeProvider, SharedPreferences, auth sign-out flow, animated loading screen.

---

### Closing (4:15 – 5:00)

> “To summarize: NoteVault uses **Flutter**, **Supabase**, **Provider**, Life Spaces organizer, Archive, and **local notifications** for optional reminders.
>
> Security is handled through validation, sanitization, and Supabase **Row Level Security**. Thank you for watching my demonstration.”

**On screen:** Quick recap — login screen or home screen, then end recording.

---

## Checklist Before Submitting

- [ ] Video is **3 to 5 minutes** long  
- [ ] App runs on **simulator, emulator, or physical device**  
- [ ] You **narrate** each step in your own words  
- [ ] You showed **sign up, login, profile, notes CRUD, dark mode, and logout**  
- [ ] You mentioned at least these technical features:
  - Supabase Authentication  
  - Supabase Database & Realtime  
  - Profile picture upload (Storage)  
  - Notes CRUD  
  - Input validation  
  - Local notifications (optional reminders)  
  - Dark mode with SharedPreferences  
  - Row Level Security (brief mention)  

---

## Suggested Demo Account (Optional)

Create a test account before recording so login is smooth:

- **Email:** `demo@smartnotes.app` (or your own test email)  
- **Password:** A strong password that passes all requirements (e.g. `Demo1234!`)

Run `supabase/sql/full_schema.sql` in Supabase and enable **Email sign-ups** in the dashboard before recording.

---

## Recording Tips

1. Use **screen recording** on your phone or emulator.  
2. Speak clearly — pretend you are presenting to Mrs. Manalo.  
3. Do one smooth run; edit only if you make a big mistake.  
4. On Android, show the **custom app icon** briefly at the start.  
5. Keep the video focused on the app — no long silent pauses.
