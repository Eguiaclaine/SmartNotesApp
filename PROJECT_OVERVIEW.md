# NoteVault — Project Overview

**Submitted by:** Ronar D. Morales  
**Course:** CC106 Bachelor of Science in Information System  
**GitHub Repository:** https://github.com/Eguiaclaine/NotesVault

---

## 1. Introduction

**NoteVault** is a note-taking application created using the Flutter development framework, assisting its users in safely managing their personal notes alongside a customizable user profile. Built with a distinctive **candy pink** visual theme, this application is designed for individuals such as students and professionals who require a dependable platform to save important notes, reminders, and organized collections of ideas.

### Core Architecture & Authentication

This application features a secure user authentication system that allows users to sign up and log in using **Supabase Authentication**. Every user has a unique profile page where they can edit personal information and upload profile pictures. Smooth animated loading screens guide users through sign-in, sign-up, and sign-out transitions for a polished experience.

### Notes Management System

The primary feature of this software application is a comprehensive **Notes Management System** that allows users to create, read, update, and delete (CRUD) their notes. Users benefit from the safe storage and effective management of their notes through an easy-to-use, intuitive interface. Notes can be saved without restrictions, and reminders are optional—validation applies only when a user explicitly sets a reminder time. Users can also **search** notes quickly and apply candy color tags for visual organization.

### Life Spaces Organizer (Unique Feature)

Beyond standard note-taking, NoteVault introduces **Life Spaces**—a unique organizer that lets users create themed boards with custom emoji and candy pink color accents (for example: School, Work, Ideas, or Personal). Notes can be assigned to a Life Space and filtered by space on the home screen, giving users a personal productivity structure that goes beyond a flat notes list.

### Archive Vault

NoteVault includes an **Archive** feature so users can store notes they no longer need in active view without permanently deleting them. Archived notes can be restored at any time or permanently deleted when the user is ready.

### Personalization & Utilities

- **Candy Pink Theme:** The app’s signature candy pink Material 3 design creates a modern, consistent visual identity across all screens.
- **Local Notifications:** Implemented to keep users on track with time-sensitive tasks. The Android APK includes built-in notification permissions to handle native phone reminders seamlessly.
- **Backend Architecture:** Data is stored securely in **Supabase PostgreSQL** utilizing **Row Level Security (RLS)**. Notes, Life Spaces, and profile data sync in real time across multiple devices.

---

## 2. Target Audience

- **Students** who need to organize academic notes, schedules, and assignment reminders into Life Spaces.
- **Professionals** looking to manage personal workflows or day-to-day professional details with archive and search.
- **General Users** searching for a minimalist, safe, and efficient note-taking workspace with a distinctive visual style.
- **Power Users** who appreciate personal identity customization, themed organizers, and archive management within their utility apps.

---

## 3. Key Features

- Supabase Authentication (Sign Up, Login, Logout)
- Secure User Account Management
- Profile Page with Editable User Information
- Profile Picture Upload Capabilities
- Full Create, Read, Update, and Delete (CRUD) Notes Operations
- **Life Spaces Organizer** (emoji + candy color boards; filter notes by space)
- **Archive / Restore Notes** (safe storage without immediate permanent delete)
- **Search Notes** by title and content
- Optional Candy Color Tags on notes
- Optional Note Reminders (validated only when explicitly set)
- Local Notification Reminders
- Candy Pink Theme (light-only branding)
- Input Validation and Data Sanitization Utilities
- Responsive and User-Friendly Interface
- Secure Data Storage and Access Control via Supabase RLS
- Supabase Realtime Sync for Notes, Profiles, and Life Spaces
- Animated Loading Screens (Sign In, Sign Up, Sign Out flows)
- Native Android APK with a Custom Launcher Icon
