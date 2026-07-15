# System Workflows

## Auth Flow

1. **Register**  
   User fills full name, email, and password (minimum 6 characters).

2. **Account Created**  
   Supabase Authentication creates the account. The app keeps the user signed out initially.

3. **Redirect to Login**  
   User is sent to the Sign In screen with a success message.

4. **Sign In**  
   User enters email and password. An animated loading screen appears while the session is created.

5. **Dashboard Access**  
   After a successful login, the user enters the Notes home screen (with Realtime connected).

---

## Notes Flow

1. **Create / Edit Note**  
   User opens New Note or an existing note, enters title and content (optional: candy color tag, Life Space, reminder).

2. **Save to Supabase (Database)**  
   The note is saved to the PostgreSQL `notes` table through the Notes provider / Supabase client.

3. **Realtime Broadcast (State sync)**  
   Supabase Realtime pushes changes so the notes list stays synced across the session / devices.

4. **Optional Local Reminder**  
   If a reminder is set, it is scheduled on the native device client using `flutter_local_notifications` (no server push required).

---

## Life Spaces Flow (Unique Organizer)

1. **Open Life Spaces**  
   User opens the Life Spaces screen from home.

2. **Create Space**  
   User uses a quick template or creates a custom space (name, motto, mood, weekly goal, emoji, candy color, optional Today’s Focus).

3. **Save to Supabase**  
   Space is stored in the `spaces` table with RLS.

4. **Assign & Filter**  
   Notes can be assigned to a space; home screen filters notes by selected Life Space.

---

## Archive Flow

1. **Archive Note**  
   User archives a note from the notes list (soft hide from active feed).

2. **View Archive**  
   Archived notes appear in Archive view.

3. **Restore or Delete**  
   User can restore the note to the active board, or permanently delete it.

---

## Logout Flow

1. **Navigate to Settings Screen**  
   User opens Settings.

2. **Click Log Out**  
   User confirms logout.

3. **Trigger Animated Loading Screen**  
   App shows a sign-out loading transition.

4. **Graceful Return to the Login Screen**  
   Session ends and the user returns to Sign In safely.
