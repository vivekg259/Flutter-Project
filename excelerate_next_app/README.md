# 🚀 EXCELERATE NEXT App

A modern, fully responsive, and scalable mobile application built using Flutter. This project is developed as part of the **Excelerate Internship**, aiming to bridge the communication and engagement gap between learners and program admins through seamless UI/UX design and robust architecture.

## 👥 Meet The Team
* **Vivek Gupta** (@vivekkg259) - Project Lead & Lead Developer
* **Yash** - UI/UX Branding & QA 
* **Khushi** - Figma Wireframing & Concept Design
* **Sadia** - Team Lead & Documentation
* **Chinonso & Emmanuel** - Testing & Support in Development

---

## 🚨 Problem Statement
Learners and admins currently face several pain points that affect engagement quality and impact measurement:
* **Fragmented communication** across multiple channels causes learners to miss announcements.
* **No central hub** exists for learners to browse open, upcoming, or closed programs.
* Admins rely on **manual, error-prone spreadsheets** for registration tracking.
* Feedback is collected via **generic, disconnected form links** rather than event-specific prompts.
* **No unified engagement history** for either learners or admins.

## 🎯 Purpose & Objectives
To provide learners with an easy, mobile-first way to stay informed and involved, while giving admins the tools to run and evaluate programs efficiently.

**Key MVP Objectives:**
* Provide a single dashboard for announcements, programs, and events.
* Allow in-app event registrations.
* Enable post-event feedback submission directly within the app.
* Give admins tools to publish announcements and manage events without developer support.
* Provide admins visibility into registrations and feedback trends.
* Build on a scalable Flutter foundation for future feature expansions.

## 👤 Target Users
The app utilizes role-based views for two primary user groups:
* **Learners:** Students/mentees using smartphones who want to discover programs, register easily, and stay updated.
* **Admins:** Program coordinators (mobile and desktop) who need to publish updates, track registrations, and review feedback.

## 🗺️ User Journeys
* **Learner Journey:** Discovers a workshop on the dashboard ➔ Taps to view details ➔ Registers in-app ➔ Receives a reminder ➔ Attends ➔ Submits feedback via a prompted survey.
* **Admin Journey:** Creates/publishes an event ➔ Monitors the participation tracker ➔ Reviews post-event ratings and comments to improve future sessions.

## 📱 Scope & Key Features (MVP)
**1. Authentication & Profile**
* Role-based login/sign-up (email/password or college ID).
* Profile management for basic details.
* Adaptive role-based bottom navigation bar.

**2. Home Dashboard**
* Scrollable announcement feed from admins.
* Upcoming events widget for quick-glance schedules.
* Quick actions/shortcuts to browse programs or past registrations.

**3. Program Discovery & Registration**
* Browsable, filterable, and searchable active programs/events.
* Detail screens (descriptions, schedules, eligibility, and "Register" button).
* Short, auto-filled in-app registration forms.
* "My Registrations" screen to track events.

**4. Admin Tools & Feedback**
* Post-event feedback forms for event-specific ratings/comments.
* Simple announcement composer to push updates.
* Event management tools (create, edit, close listings).
* Participation tracker for registered learners.
* Dashboard aggregating feedback submissions and average ratings.

## ⚙️ Non-Functional Requirements
* **Usability:** Navigation requires no more than 2–3 taps for core actions.
* **Performance:** Dashboards and listings load within 2 seconds (4G connection).
* **Platform:** Built in Flutter for cross-platform iOS and Android support from a single codebase.
* **Security:** Strict role-based access control for admin screens.
* **Scalability:** Designed to easily add future modules (certificates, gamification, chat).

---

## ✨ Week 2 UI Implementation Highlights

Based on the MVP scope, the Week 2 frontend prototype has been successfully developed and verified with **0 Analyzer Issues**:

1. **Splash & Login Screen:** 3-second animated logo splash screen & modern login UI with soft-shadow cards.
2. **Dashboard (Home Screen):** User statistics, real-time styled announcements, and quick links.
3. **Programs Listing:** 6 Trending industry courses with Coursera-style layout (duration, level, rating badges).
4. **Program Details:** In-depth course view featuring Requirements, Skills to gain, and Course Curriculum.
5. **Interactive Feedback Screen:** Fully functional star rating system, dynamic dropdowns, and course pace selection tags.
6. **Updates / Notifications:** Fully responsive list view with seamless scrolling and color-coded notification icons.
7. **Profile Screen:** Professional user dashboard with dummy placeholders (Test User) and options for Certificates, Subscriptions, and Settings.

**🎨 Branding & Design System Applied:**
* **Typography:** `Poppins` (Google Fonts).
* **Colors:** Deep Blue (`#003366`), Button Blue (`#0056D2`), Vibrant Orange Accent (`#FFFF6D00`).
* **UI Structure:** White cards, 12-16px border radius, soft drop-shadows (completely eliminating harsh black wireframe borders), and fully responsive handling for all screen sizes (No RenderFlex overflow).

---

## 🛠️ Tech Stack & Dependencies
* **Framework:** Flutter (Dart)
* **Fonts:** `google_fonts: ^latest`
* **Architecture:** Component-based UI with centralized routing.

---

## 🚀 How to Run the Project

1. **Clone the repository:**
   ```bash
   git clone https://github.com/vivekg259/Flutter-Project.git

2. **Navigate to the project directory:**
   ```bash
   cd excelerate_next_app
   
3. **Install dependencies:**
   ```bash
   flutter pub get
   
4. **Run the app:**
   ```bash
   flutter run

**Built with ❤️ by the Excelerate Next Team.**
