# 🚀 EXCELERATE NEXT APP

A modern, fully responsive, and scalable mobile application built using Flutter. This project is developed as part of the **Excelerate Internship**, aiming to bridge the communication and engagement gap between learners and program admins through seamless UI/UX design and robust architecture.

## 👥 Meet The Team
* **Vivek Gupta**  - Project Lead & Lead Developer
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

<img width="887" height="587" alt="{4FAB04A8-A23E-4248-960D-796CB6B553E2}" src="https://github.com/user-attachments/assets/63c35c3d-217c-4cdf-8bb6-e30a498e2cec" />

## 📸 Week 2 UI Implementation Highlights

* **Splash & Login Screen:** 3-second animated logo splash screen & modern login UI with soft-shadow cards.
* **Dashboard (Home Screen):** User statistics, real-time styled announcements, and quick links.
* **Programs Listing:** 6 Trending industry courses with Coursera-style cards (duration, level, rating badges).
* **Program Details:** In-depth course view featuring Requirements, Skills to Gain, and Course Curriculum.
* **Interactive Feedback Screen:** Fully functional star rating system, dynamic dropdowns, and course pace selection tags.
* **Updates / Notifications:** Fully responsive list view with color-coded notification icons.
* **Profile Screen:** User dashboard displaying certificates, subscriptions, and settings placeholders.

---

## 🔄 Week 3 Updates & Changelog (API & Data Integration)

During Week 3, the application transitioned from static UI layouts to a fully dynamic, data-driven prototype featuring mock API/JSON fetching, dynamic form validation, and asynchronous UX handling.

### 1. Dynamic Data Fetching (Program Listing & Details)
* **JSON/API Integration:** Replaced static hardcoded course texts on the **Program Listing** and **Program Details** screens with asynchronous data services fetching structured JSON payloads.
* **Async UI Rendering:** Implemented `FutureBuilder` patterns to parse external JSON models (Course Title, Instructor, Duration, Level, Rating, Skills, and Curriculum).

### 2. Dynamic UX & State Handling
* **Loading Indicators:** Added central `CircularProgressIndicator` views while fetching local or remote JSON payloads.
* **Error Handling & Fallbacks:** Built error-handling states (displaying user-friendly retry prompts) in the event of failed data requests or bad JSON formatting.

### 3. Interactive Forms & Input Validation
* **Course Feedback & Registration Forms:** Upgraded form controls using Flutter’s `Form` widget and explicit `GlobalKey<FormState>`.
* **Field Validation Rules:**
  * **Email Validation:** Checks for non-empty input and valid regex email structure (`user@domain.com`).
  * **Password / Text Fields:** Enforces minimum character length requirements and non-empty checks.
  * **Course Dropdowns & Ratings:** Ensures valid course selections and rating inputs prior to form submission.
* **Feedback Submission Feedback:** Added clear `SnackBar` notifications confirming successful validation and mock API payload submission.

---
---

## 🛠️ Tech Stack & Dependencies
* **Framework:** Flutter (Dart)
* **Fonts:** `google_fonts: poppins
* **Architecture:** Component-based UI with centralized routing.

---

## **🔗 Links & Resources**
Demo Video Walkthrough: [Watch 2-3 Min Screen Recording](https://drive.google.com/file/d/1mhUHH_wMDr1xI_buHh9M7VPLHi1OGiT8/view?usp=drivesdk)

Figma Design File: [View Wireframes & Interactive Prototype](https://www.figma.com/proto/vsp7UVupcBbweynP0Xk3cB/Learning-app-prototype?node-id=0-1&t=4GhFpWVouJyeajPz-1)

Internship Platform: [Excelerate Virtual Internship](https://experience.4excelerate.org/opportunities/Global%20Internships?category=Internship&tab=1)

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
