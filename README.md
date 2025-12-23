# 🎓 StudyMate: Cloud-Based Academic Management System

**StudyMate** is a cross-platform mobile application designed to streamline the academic lives of students and teachers at **METU-NCC**. By integrating scheduling, task management, and collaborative peer-to-peer help forums, StudyMate provides a unified, real-time productivity hub.

---

## 📂 Project Structure
The repository is organized into distinct directories for code, documentation, and assets to maintain a clean development lifecycle.

```text
study-mate-application/
├── documentation/
│   ├── proposal/           # Initial Project Proposal
│   ├── progress/           # Capstone Progress Reports
│   └── final/              # Final Capstone Technical Report
├── media/                  # App screenshots and demo videos
├── supabase/               # SQL schema, RLS policies, and Edge Functions
└── study_mate_app/         # Main Flutter Project
    ├── lib/
    │   ├── features/       # Feature-first modules (Auth, Notes, Forum, etc.)
    │   └── services/       # Supabase client and API wrappers
    └── pubspec.yaml        # Flutter dependencies

Category,Detail,Technical Description & Responsibilities
Languages,"Dart, SQL, TS",Dart: Frontend (Flutter). SQL: DB Schema. TS: Edge Functions.
Lines of Code,"~4,000 – 6,000","Total codebase including widgets, logic, and backend scripts."
Database Type,PostgreSQL,Relational DB (v15+) with Row Level Security (RLS).
Runtime RAM,120MB – 200MB,Optimized for 60fps performance on Android devices.
Dev RAM,8GB – 16GB,Required for IDEs and mobile emulators.
Database Data Types Used

UUID: Primary keys for secure user identification.

TEXT / JSONB: Used for notes and complex forum metadata.

TIMESTAMP: Used for class schedules and to-do deadlines.

BLOB (Storage): URLs for PDF and Image attachments.

🚀 Installation & Setup
1. Backend Setup (Supabase)

Create a project at Supabase.com.

Run scripts in /supabase/schema.sql to initialize tables.

Enable RLS to ensure users can only see their own data.

2. Frontend Setup (Flutter)

Clone the repo: git clone https://github.com/arishaahmad/study-mate-application.git

Install dependencies: flutter pub get

Add your URL and Anon Key in lib/main.dart.

Run the app: flutter run

👥 Team & Responsibilities
Member	Focus Areas	Key Implementation
Arisha Ahmad	Backend & Productivity	Supabase Auth, To-Do, Pomodoro, Notes (PDF/Images)
Faiez Rashid	UI & Collaboration	Dashboard, Help Forum (Real-time), Inbox, Schedule

📧 Contact
Arisha Ahmad: [2751923]
Faiez Rashid: [2460384]

