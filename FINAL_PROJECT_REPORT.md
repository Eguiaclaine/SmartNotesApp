Dropbox |Final Module | Final Project Submission  
RONAR MORALES 1

# Final Project Report - NoteVault App

**Submitted by:** Ronar D. Morales  
**GitHub Repository:** https://github.com/RONAR-cell/NoteProfile  
**Course:** CC106 Bachelor of Science Information System  
**Instructor:** Mrs. Divine Manalo  
**Date:** July 14, 2026

---

Dropbox |Final Module | Final Project Submission  
RONAR MORALES 2

## 1. Introduction

NoteVault is a candy-pink note-taking app created with Flutter, helping users safely manage personal notes with a customisable profile. Unique features include **Life Spaces** (organize notes into themed boards) and an **Archive** vault for stored notes.

This application includes a feature of secure user authentication which will help users to sign up and log in using **Supabase Authentication**. Every user has a unique profile page where they can edit personal information and upload profile pictures.

The primary feature of this software application is **Notes Management System** that allows users to make, read, edit, and delete their notes. Users will benefit from the safe storage and effective management of their notes using the easy-to-use and convenient interface of the application. Notes can be saved without restrictions, and reminders are optional — validation applies only when a user sets a reminder.

The application uses a consistent **candy pink** theme for a distinctive and user-friendly look.

Moreover, it is necessary to include **Local Notifications** into the features list because it will help to remind users about certain notes and tasks that they need to complete. The Android APK includes notification permissions for phone reminders.

Data is stored securely in **Supabase PostgreSQL** with Row Level Security (RLS), and notes and profiles sync in real time across devices.

---

Dropbox |Final Module | Final Project Submission  
RONAR MORALES 3

## 2. Target Audience

- Students who have the task of organizing their academic notes and reminders.
- Professionals who want to manage their personal or professional information.
- People who are in search of an easy and safe note-taking process.
- People who like taking notes in their own customized profile.

---

## 3. Key Features

- Supabase Authentication (Sign Up, Login, Logout)
- Secure User Account Management
- Profile Page with Editable User Information
- Profile Picture Upload
- Create, Read, Update, and Delete (CRUD) Notes
- **Life Spaces Organizer** (emoji + candy color boards)
- **Archive / Restore Notes**
- Search Notes
- Optional Note Reminders (validated only when set)
- Local Notification Reminders
- Candy Pink Theme
- Input Validation and Data Sanitization
- Responsive and User-Friendly Interface
- Secure Data Storage and Access Control (Supabase RLS)
- Supabase Realtime Sync
- Animated Loading Screens
- Android APK with Custom Launcher Icon

---

Dropbox |Final Module | Final Project Submission  
RONAR MORALES 4

## 4. Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend Framework** | Flutter (Dart) |
| **Backend Platform** | Supabase (Authentication, PostgreSQL Database, Storage, Realtime) |
| **State Management** | Provider |
| **Local Storage** | SharedPreferences |
| **Notifications** | flutter_local_notifications, timezone |
| **Image Selection** | image_picker |
| **UI Framework** | Material 3 |
| **Security & Validation** | Custom Validation and Sanitization Utilities, Supabase RLS |
| **Development Environment** | Visual Studio Code / Cursor |
| **Version Control** | Git & GitHub |
| **Android Build** | Flutter APK (debug) with adaptive launcher icon |

### Packages / Plugins Used

- `supabase_flutter`
- `provider`
- `shared_preferences`
- `flutter_local_notifications`
- `image_picker`
- `intl`
- `uuid`
- `flutter_dotenv`
- `timezone`
- `flutter_launcher_icons` (APK icon generation)

### Database Schema (Supabase SQL)

- `profiles` — user profile data (display name, email, avatar)
- `notes` — title, content, optional `reminder_at`
- Storage bucket: `profile-avatars`
- RLS policies, triggers, and realtime publication
- Schema files: `supabase/sql/full_schema.sql`

---

Dropbox |Final Module | Final Project Submission  
RONAR MORALES 5

## 5. Architecture / Flow Diagram

```
User → Authentication (Supabase) → Profile → Notes CRUD → Life Spaces / Archive → Notification
                              ↓
                    Supabase PostgreSQL + Realtime
                              ↓
                    Local Cache (SharedPreferences)
```

**Auth flow:** Register → account created → user signed out → login screen with success message → sign in → dashboard.

**Notes flow:** Create / edit note → save to Supabase → realtime sync → optional local reminder scheduled on device.

**Logout flow:** Settings → Log out → animated loading screen → return to login.

---

Dropbox |Final Module | Final Project Submission  
RONAR MORALES 6

## 6. Screenshots

| Login Screen | Profile Edit Screen |
|--------------|---------------------|
| *(Insert screenshot)* | *(Insert screenshot)* |

| Create Account Screen | Note CRUD Screen |
|-----------------------|------------------|
| *(Insert screenshot)* | *(Insert screenshot)* |

---

Dropbox |Final Module | Final Project Submission  
RONAR MORALES 7

| Edit Note Screen | Life Spaces Screen |
|------------------|----------------|
| *(Insert screenshot)* | *(Insert screenshot)* |

| Sign-Out Loading Screen | Android APK Launcher Icon |
|-------------------------|---------------------------|
| *(Insert screenshot)* | *(Insert screenshot)* |

---

Dropbox |Final Module | Final Project Submission  
RONAR MORALES 8

## 7. Conclusion

Currently, login, sign up, profile editing, and CRUD notes are functional with Supabase as the backend. The application supports Life Spaces, archive, optional note reminders with local notifications, realtime data sync, and a polished auth transition experience including sign-out loading.

The project is deployable as a **Flutter Android APK** (`build/app/outputs/flutter-apk/app-debug.apk`) with a custom launcher icon. The app can also be run on **Chrome (web)** for development and testing.

**Next steps** include release APK signing, push notification integration, and additional offline-first enhancements.

---

**APK Location:** `build/app/outputs/flutter-apk/app-debug.apk`  
**Supabase Schema:** `supabase/sql/full_schema.sql`  
**Run Command:** `flutter run -d chrome`
