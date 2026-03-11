# Memories AI 🧠

![Screenshot 2](assets/Gemini_Generated_Image_ycrbo8ycrbo8ycrb.png)

Memories AI is an intelligent platform built with Flutter that allows users to record, capture, and analyze their memories using the power of AI (OpenAI) and a robust backend (Supabase). This repository contains two main applications: the mobile app for users, and a web dashboard for administration and insights.

## 🎥 Demos
- **App Demo:** [Watch on YouTube](https://youtu.be/c4jWuRKjiuY)
- **Dashboard Demo:** [Watch on YouTube](https://youtu.be/gIeYM776RmA)

## 📱 App

The `app` directory contains the web application. It allows users to:
- **Record Memories:** Capture voice recordings to save personal memories.
- **Analyze Memories:** Use AI to transcribe and extract context, people, and insights from recorded memories.
- **Memories & People List:** View a timeline of past memories and a list of identified people within those memories.
- **Authentication:** Secure login and session management powered by Supabase.

### How to Run the App

1. Navigate to the `app` directory:
   ```bash
   cd app
   ```
2. Set up your environment variables by copying the example file:
   ```bash
   cp .env.example .env
   ```
3. Fill in the `.env` file with your **Supabase** and **OpenAI** credentials.
4. Get the dependencies:
   ```bash
   flutter pub get
   ```
5. Run the application:
   ```bash
   flutter run
   ```

---

## 💻 Dashboard

The `dashboard` directory contains the web-based administration panel built with Flutter Web. It provides advanced visualization and management features:
- **Insights & Network Graph:** Visualize relationships between people and overall insights extracted from the users' memories.
- **Data Management:** View and manage lists of memories, people, conversations, and devices.
- **Authentication:** Secure staff access using Supabase Auth.

### How to Run the Dashboard

1. Navigate to the `dashboard` directory:
   ```bash
   cd dashboard
   ```
2. Set up your environment variables by copying the example file:
   ```bash
   cp .env.example .env
   ```
3. Fill in the `.env` file with your **Supabase** and **OpenAI** credentials.
4. Get the dependencies:
   ```bash
   flutter pub get
   ```
5. Run the application (typically on Chrome for web):
   ```bash
   flutter run -d chrome
   ```

## 🛠️ Tech Stack
- **Frontend:** Flutter & Dart
- **UI Components:** [shadcn_ui](https://pub.dev/packages/shadcn_ui) for beautiful and customizable widgets.
- **Backend & Auth:** [Supabase](https://supabase.com/) - A complete dump of the database schema (tables, types, references) can be found in the [`database.sql`](database.sql) file at the root of the project.
- **AI Integration:** [OpenAI](https://openai.com/) (GPT and Whisper for analysis and transcription)
- **State Management:** BLoC / Cubit architecture.
- **Routing:** GoRouter

![Screenshot 1](assets/Gemini_Generated_Image_asb5k8asb5k8asb5.png)

## 📄 License
This project is open-source but **non-commercial**. You are free to view, learn from, and modify the code for personal or educational purposes, but you may not use it for commercial gains or monetize it in any form without explicit permission.

Please see the [LICENSE](LICENSE) file for more details. We use the **Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)** license.
