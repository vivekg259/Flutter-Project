# EXCELERATE NEXT App

## Problem Statement
Learners and admins currently face several pain points that affect engagement quality and impact measurement:
* Fragmented communication across multiple channels causes learners to miss announcements or find outdated information.
* There is no central place for learners to browse open, upcoming, or closed programs.
* Admins rely on manual, error-prone spreadsheets for registration tracking.
* Feedback is collected via generic, disconnected form links rather than being tied to specific events.
* There is no unified engagement history for either learners or admins.

## Purpose & Objectives
The purpose of the app is to give learners an easy, mobile-first way to stay informed and involved, while giving admins the tools to run and evaluate programs efficiently.

**Key MVP Objectives:**
* Provide learners a single dashboard to view announcements, programs, and relevant events.
* Allow learners to register for events directly within the app.
* Enable learners to submit specific post-event feedback right after attending.
* Give admins a way to publish announcements and manage events without needing developer support.
* Provide admins visibility into registration counts and feedback trends per event.
* Build on a scalable Flutter foundation so future features can be added without a rebuild.

## Target Users
The app utilizes role-based views for two primary user groups:
* **Learners:** Students or mentees using smartphones who want to quickly discover programs, register easily, and stay updated on events.
* **Admins:** Program coordinators using both mobile and desktop who need to quickly publish updates, track registrations, and review event feedback to improve future sessions.

## Scope & Key Features (MVP)

### 1. Authentication & Profile
* Role-based login and sign-up using email/password or college ID.
* Profile management allowing learners to view and edit basic details.
* Role-based bottom navigation bar that adapts based on the logged-in user.

### 2. Home Dashboard
* Scrollable announcement feed featuring the latest updates from admins.
* Upcoming events widget for quick-glance schedules.
* Quick actions and shortcuts to browse programs or view past registrations.

### 3. Program Discovery & Registration
* Browsable, filterable, and searchable list of active programs and events.
* Detail screens showing descriptions, schedules, eligibility, and a "Register" button.
* Short, auto-filled in-app registration forms.
* "My Registrations" screen to track upcoming and attended events.

### 4. Admin Tools & Feedback
* Post-event feedback forms for learners to leave ratings and comments tied to a specific event.
* Simple announcement composer for admins to push updates to all learner dashboards.
* Admin event management tools to create, edit, or close listings.
* Participation tracker for admins to monitor the list and number of registered learners.
* Admin dashboard for aggregating feedback submissions, average ratings, and comments.

## User Journeys
* **Learner Journey:** A learner discovers a workshop on their dashboard, taps to view details, registers in-app, receives a reminder, attends, and later submits feedback via a prompted survey form.
* **Admin Journey:** An admin creates and publishes a new event, monitors the participation tracker for sign-ups, and reviews post-event average ratings and comments to adjust the format of future sessions.

## Non-Functional Requirements
* **Usability:** Navigation requires no more than 2–3 taps to reach any core action.
* **Performance:** Dashboards and listing screens load within 2 seconds on a 4G connection.
* **Platform:** Built in Flutter for cross-platform iOS and Android support from a single codebase.
* **Security:** Enforces strict role-based access control to keep admin screens restricted.
* **Scalability:** Designed so future modules (e.g., certificates, gamification, chat) can be added without restructuring the core app.
