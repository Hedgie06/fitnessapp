# 🏋️ FitQuest – Your Personalized Fitness Companion

**FitQuest** is a Flutter-based fitness app designed to support users in achieving their health and wellness goals. With a focus on simplicity and personalization, FitQuest helps users track their progress, stay motivated, and build healthy habits — all in one place.

## ✨ Key Features

### 📊 BMI Calculator
- Input your **height** and **weight**
- Instantly calculate your **Body Mass Index (BMI)**
- Receive categorized results (Underweight, Normal, Overweight, etc.)

### 💧 Water & Calorie Intake Tracker
- Track your **daily water intake** in milliliters
- Log your **daily calorie intake** in kilocalories
- Monitor your progress toward daily intake goals
- Visual indicators to help maintain consistency

### 🏋️ Targeted Workout Plans
- Explore beginner-friendly workout routines organized by body focus:
  - **AB**
  - **UPPER BODY**
  - **LOWER BODY**
  - **FULL BODY**
- Each workout plan includes suggested exercises, reps, and sets

### 🖼️ Before & After Photo Comparison
- Upload photos to visually track your fitness transformation
- Compare **before vs after** images side by side
- Stay motivated by celebrating visible progress

### 🤖 AI-Powered Chatbot (Gemini API)
- Engage with a **personalized fitness chatbot** powered by the **Gemini API**
- Get fitness advice, motivation, and wellness suggestions
- Chatbot responds to natural language input and adapts to user goals
- Requires internet connection for Gemini API interaction

## 🧠 Architecture

FitQuest follows the **MVC (Model-View-Controller)** architecture for maintainable and scalable development:

- **Model** – Manages data such as user inputs, intake logs, workout history, and photo records
- **View** – Built with Flutter for a smooth, intuitive user interface
- **Controller** – Handles app logic, including calculations, progress updates, and chatbot communication

## 🛠️ Tech Stack

- **Flutter & Dart** – Cross-platform app development
- **Gemini API** – AI chatbot powered by Google’s large language model
- **SharedPreferences / SQLite** – For storing data locally
- **Image Picker** – For uploading and comparing user photos
- **HTTP** – For sending chat requests to the Gemini API


