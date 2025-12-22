🎓 StudyMate: Cloud-Based Academic Management System
StudyMate is a cross-platform mobile application designed to streamline the academic lives of students and teachers at METU-NCC. By integrating scheduling, task management, and collaborative peer-to-peer help forums, StudyMate provides a unified, real-time productivity hub.

📂 Project Structure
The repository is organized into distinct directories for code, documentation, and assets to maintain a clean development lifecycle.

Plaintext
study-mate-application/
├── documentation/
│   ├── proposal/           # Initial Project Proposal
│   ├── progress/           # Capstone Progress Reports
│   └── final/              # Final Capstone Technical Report
├── media/                  # App screenshots, GIFs, and demo videos
├── supabase/               # SQL schema, RLS policies, and Edge Functions
└── study_mate_app/         # Main Flutter Project
    ├── lib/
    │   ├── core/           # Common utilities, themes, and constants
    │   ├── features/       # Feature-first modules (Auth, Notes, Forum, etc.)
    │   ├── models/         # Data models and DTOs
    │   └── services/       # Supabase client and API wrappers
    └── pubspec.yaml        # Flutter dependencies
🛠 Technology Stack & Metrics
Core Technologies

Frontend: Flutter (Dart) - Cross-platform UI toolkit.

Backend (BaaS): Supabase (PostgreSQL) - Relational data and security.

Authentication: Supabase Auth (JWT-based).

Real-time: PostgreSQL Listen/Notify via WebSockets.

Storage: Supabase Storage buckets for PDFs and images.

Technical Metrics

Metric	Detail
Programming Languages	Dart (90%), SQL (8%), TypeScript (2%)
Lines of Code (LOC)	~4,000 – 6,000 lines
Runtime Memory	120MB – 200MB RAM (Target Android)
Database Type	PostgreSQL (v15+) with Row Level Security (RLS)
🚀 Installation & Setup
Prerequisites

Flutter SDK: v3.x or higher.

Dart: v3.x.

Supabase Account: Access to a project instance.

1. Setup the Backend

Create a new project on Supabase.com.

In the SQL Editor, execute the initialization scripts from /supabase/schema.sql to create the following tables:

profiles, todos, schedule, notes, forum_posts.

Enable Row Level Security (RLS) for all tables to protect user data.

2. Setup the Mobile App

Clone the repository:

Bash
git clone https://github.com/arishaahmad/study-mate-application.git
cd study_mate_app
Install dependencies:

Bash
flutter pub get
Configure environment variables:

Initialize the Supabase client in lib/main.dart using your Project URL and Anon Key.

3. Run the App

Bash
flutter run
👥 Team & Responsibilities
The project was divided into specialized roles to ensure high-quality full-stack delivery.

Arisha Ahmad (2751923)

Backend: Initial Supabase infrastructure, database architecture, and RLS policies.

Core Logic: Auth system, To-Do List, Pomodoro Timer, and Notes Module with cloud storage for PDFs/Images.

Faiez Rashid (2460384)

Frontend & UX: Dashboard layout, grid-based navigation, and Profile view.

Collaboration: Help Forum implementation, Inbox/Messaging system, and real-time backend synchronization.

📧 Contact & Support
For academic inquiries or technical support regarding this project, please reach out via our university emails or GitHub profiles.
