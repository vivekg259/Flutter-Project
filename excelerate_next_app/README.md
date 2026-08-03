# 🚀 EXCELERATE NEXT APP

A modern, fully responsive, and scalable cross-platform mobile application built using Flutter and Firebase backend services. Developed as part of the Excelerate Internship, this application bridges the communication and engagement gap between learners and program admins through seamless UI/UX design, real-time data persistence, and robust role-based architecture.

---

## 👥 Meet The Team

* **Vivek Gupta** - Project Lead & Lead Developer
* **Yash** - UI/UX Branding & QA
* **Khushi** - Figma Wireframing & Concept Design
* **Sadia** - Team Lead & Documentation
* **Chinonso & Emmanuel** - Testing & Support in Development

---

## 🚨 Problem Statement

Learners and admins currently face several pain points that affect engagement quality and impact measurement:
* **Fragmented Communication:** Important announcements sent across multiple channels get missed.
* **Lack of Discovery:** No unified platform exists for browsing open, upcoming, or closed programs.
* **Manual Tracking:** Admins rely on manual, error-prone spreadsheets for registration tracking.
* **Disconnected Feedback:** Post-event feedback is collected via generic external form links rather than event-specific prompts.
* **No Unified History:** Neither learners nor admins have centralized visibility into past participation or program outcomes.

---

## 🎯 Purpose & Objectives

To provide learners with a mobile-first hub to stay informed and registered, while empowering program managers with administrative tools to publish, track, and evaluate programs effectively.

### Key MVP Objectives:
* Provide a single dashboard for announcements, programs, and notifications.
* Enable secure, role-based authentication (Learner vs. Admin).
* Support in-app program registration and administrative approval workflows.
* Facilitate post-event feedback and detailed star-rating submissions.
* Equip admins with tools to publish programs, manage listings, track participants, and inspect aggregated feedback analytics.

---

## 👤 Target Users & Journeys

### 1. Learner Journey
Create account/Sign in ➔ Email Verification ➔ Browse programs on Home Dashboard or Programs Tab ➔ View Program Details ➔ Tap "Enroll Now" to submit registration ➔ Track status in "My Registrations" ➔ Submit program feedback (Star Ratings & Detailed Review).

### 2. Admin Journey
Sign in as Administrator ➔ Access Admin Dashboard ➔ Create & Publish new programs ➔ Approve/Reject learner registrations via Participants Tracker ➔ Delete or update existing listings via Manage Programs ➔ Review aggregated ratings and individual user reviews via Feedback Dashboard.

---

## 📱 Core Features & Capabilities

* **Authentication & Role Handling:**
  * Email & Password sign-up with real-time field validations.
  * In-app Firebase Email Verification flow.
  * Role-based access control (Learner View vs. Admin Dashboard).

* **Learner Features:**
  * **Home Dashboard:** Quick stats (Registrations & Available Programs), announcement banners, upcoming program shortcuts, and navigation links.
  * **Program Discovery & Details:** Search and filter active programs by level (Beginner, Intermediate). Inspect duration, level, seats remaining, instructor info, required skills, and course description.
  * **In-App Registration:** Submit program enrollment applications with single-tap actions; real-time status tracking (Pending, Approved).
  * **Interactive Feedback:** Star rating inputs (Content & Instructor), pace selection tags (Too Slow, Just Right, Too Fast), and detailed review validation with duplicate submission prevention.
  * **Profile Management:** View registered courses, certificates placeholder, and session controls.

* **Admin Features:**
  * **Program Lifecycle Management:** Create and publish new listings (Title, Description, Instructor, Duration, Capacity, Level, Schedule, Eligibility, Skills) or delete existing programs.
  * **Participants Tracker:** Select specific programs and inspect applicant lists; approve or reject learner registrations with instant status updates.
  * **Feedback Analytics Dashboard:** Inspect average content/instructor ratings, course pace distribution metrics, and individual text reviews per course.

---

## 🔄 Project Evolution & Changelog

### Week 1 & 2: Conceptualization & UI Implementation
* Designed wireframes and brand guidelines in Figma.
* Implemented core Flutter screens: Splash, Login/Signup, Home Dashboard, Program Listings, Details, Feedback, Updates, and Profile screens using `google_fonts: poppins`.

### Week 3: Dynamic Data & API Integration
* Transitioned from static layouts to dynamic rendering using `FutureBuilder` models.
* Integrated dynamic form controls (`GlobalKey<FormState>`) with regex validations for email formats, password lengths, dropdowns, and minimum review lengths.
* Integrated SnackBar notifications for form submissions and error handling states.

### Week 4: Final Deliverable & Full Persistence (Current)
* Integrated real-time backend persistence for user authentication, program creation, registration status, and feedback aggregation.
* Implemented email verification verification workflows.
* Built full Admin workflow tools: Program publishing, deletion confirmation, registration approval controls, and real-time feedback analytics.
* Conducted full E2E workflow testing, edge-case validation, and repository cleanup.

---

## 🛠️ Tech Stack & Dependencies

* **Framework:** Flutter (Dart)
* **Typography:** `google_fonts` (Poppins)
* **Backend & Authentication:** Firebase Auth / Firestore Persistence
* **Architecture:** Component-based UI with central state navigation and dynamic role routing.

---



## **🔗 Links & Resources**
Demo Video Walkthrough: [Watch 2-3 Min Screen Recording](https://drive.google.com/file/d/1gW0r9vRD18QPRQesHQvkcmq9O1G2KFuJ/view?usp=drivesdk)

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
