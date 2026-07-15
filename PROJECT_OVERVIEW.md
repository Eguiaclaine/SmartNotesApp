NoteVault — Project Overview

1. Introduction
NoteVault is a dedicated note-taking application built on the Flutter development framework, designed to help users securely manage their personal thoughts and tasks alongside a customizable profile. Styled with a distinctive candy pink aesthetic, the application provides students, professionals, and creatives with a structured platform to capture, organize, and safeguard their daily ideas and reminders.

Core Architecture & Authentication
At its core, NoteVault relies on Supabase Authentication to handle user sign-ups and secure logins. Each account features a dedicated profile dashboard where users can customize their personal information and upload custom profile photos. To elevate the user experience, smooth animated transitions guide users seamlessly through the sign-in, sign-up, and sign-out screens.

Notes Management System
The application's centerpiece is a robust Notes Management System supporting full CRUD (Create, Read, Update, Delete) capabilities. Notes can be captured instantly, customized with candy-colored tags for quick visual categorization, and retrieved rapidly using an integrated search tool. While users can save notes without restrictions, they also have the option to attach task reminders; validation parameters are only triggered once a user actively sets a reminder time.

Life Spaces Organizer (Unique Feature)
To move beyond the limitations of a standard, flat list, NoteVault introduces Life Spaces. This dedicated organizer allows users to design themed boards using unique emojis and candy pink accents (e.g., School, Work, Ideas, or Personal). Notes can be assigned directly to these spaces, enabling users to filter their dashboard view by category and build a more structured, personal productivity workflow.

Archive Vault
For clutter-free organization, NoteVault includes an Archive space. Users can move completed or inactive notes out of their main feed without losing them permanently. Archived notes remain safely stored and can be restored to the active board at any time, or permanently deleted whenever the user chooses.

Personalization & Utilities
Candy Pink Theme: The signature candy pink Material 3 design establishes a bold visual identity across the entire application in a consistent light candy look.
Local Notifications: To keep users on top of time-sensitive tasks, the application schedules local reminder notifications. The compiled Android APK includes built-in permission requests to ensure seamless delivery on mobile devices.
Backend Architecture: User profiles, notes, and Life Spaces data are stored in a Supabase PostgreSQL database. Leveraging Row Level Security (RLS), the system ensures strict data isolation between accounts while enabling real-time synchronization across multiple devices.

2. Target Audience
Students looking to manage lecture highlights, study schedules, and exam deadlines categorized by academic subjects.
Professionals seeking an intuitive utility to keep track of meeting minutes, task lists, and work projects.
General Users in search of a secure, minimalist, and visually distinct notebook to store personal reminders.
Power Users who appreciate fine-grained personalization, real-time sync, and structured category management in their daily tools.

3. Key Features
Secure Authentication: User registration, login, and logout powered by Supabase.
Profile Management: Personalized user profiles with editable details and profile picture upload capabilities.
Comprehensive CRUD Operations: Full note creation, reading, updating, and deletion.
Life Spaces Organizer: Custom workspace creation utilizing emojis and signature pink accents with immediate home screen filtering.
Archive & Restore: Safe temporary storage for completed notes to prevent accidental deletion.
Fast Search: Live query matching against note titles and main body content.
Visual Color Tags: Optional candy-themed color coding for quick visual grouping.
Smart Reminders: Optional note alarms that only apply validation when explicitly activated.
Local Notifications: Native Android push alerts for scheduled task reminders.
Candy Pink Theme: Custom Candy Pink Material 3 layout with a consistent light candy pink identity.
Robust Security: Data protection via Supabase Row Level Security (RLS) rules.
Real-time Sync: Instant cross-device synchronization for notes, spaces, and profiles.
Polished UI/UX: Animated loading states and transitions across primary authentication flows.
Ready for Android: Configured Android package (APK) complete with a custom launcher icon.
