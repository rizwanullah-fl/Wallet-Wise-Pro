# SpendWise

## Description

💼 **SpendWise** is a powerful financial management application designed to help users take control of their spending, track expenses, and manage budgets effortlessly. With its user-friendly interface and versatile features, **SpendWise** is your ultimate companion for achieving financial freedom.

---

## Features

- **Track Expenses**

  - Log daily expenses quickly and easily using an intuitive input interface.
  - Categorize expenses into predefined categories like Food, Travel, Utilities, or create custom categories.
  - Use filters to view expenses by date, category, or amount for deeper insights.

- **Budget Planning**

  - Set up monthly or weekly budgets and monitor your spending progress.
  - Receive alerts when nearing or exceeding your budget limit.
  - Visualize spending trends through clear charts and graphs.

- **Currency Conversion**

  - Automatically convert expenses into your preferred currency with real-time exchange rates.
  - Support for multiple currencies for global users.
  - Offline mode lets you set custom conversion rates when connectivity is unavailable.

- **Theme Personalization**

  - Switch between light and dark themes for day or night comfort.
  - Sync the theme with your device's system settings.
  - Customize accent colors to match your personal style.

- **Customizable UI**

  - Adjust text sizes and fonts for a tailored reading experience.
  - Rearrange or hide sections of the app to focus on the features you use most.
  - Add personal notes or tags to expense entries for better organization.

- **Local Data Storage**

  - All data is securely stored offline using SQLite for privacy and accessibility without internet.
  - Automatic backups to local storage, with optional cloud sync (future feature).
  - Export your expense data to PDF or CSV for sharing or archiving.

- **Backup & Restore**

  - Securely back up all financial data, including transactions, categories, and budgets.
  - Restore backups easily in case of device changes, app reinstallation, or data loss.
  - Support for both local storage backup and cloud storage backup (upcoming feature).

---

## Flutter Setup Guide

To set up **SpendWise** on your local machine using Flutter, follow these steps:

### Prerequisites

- Install **Flutter** (latest stable version) from [Flutter's official website](https://flutter.dev/docs/get-started/install)
- Install **Android Studio** or **Visual Studio Code** for development
- Ensure you have an emulator or a physical device for testing

### Installation Steps

1. **Clone the repository:**

   ```bash
   git clone https://github.com/your-repo/wallet-wise-pro.git
   cd wallet-wise-pro
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run the application:**

   ```bash
   flutter run
   ```

4. **Build for production:**

   - Android (APK):
     ```bash
     flutter build apk
     ```
   - iOS:
     ```bash
     flutter build ios
     ```

5. **Testing:**
   Run tests to ensure functionality:

   ```bash
   flutter test
   ```

Now, you’re all set to use and develop **SpendWise**!

---

Start managing your finances smarter with **SpendWise** today! 🌟


---

## Screenshots

### **1. Home Screen**
![Home Screen](https://github.com/user-attachments/assets/da4e291d-ee17-4ac4-a05e-ce9adb3c0d76)

---

### **2. Add Expense**
![Add Expense](https://github.com/user-attachments/assets/9062469b-1851-431e-b410-bbb8be5218e4)

---

### **3. Expense List**
![Expense List](https://github.com/user-attachments/assets/c673a3c9-6e05-4fed-9cb4-c38a5ead7a42)

---

### **4. Budget Tracking**
![Budget Tracking](https://github.com/user-attachments/assets/6150a917-14c6-46b3-be13-a33043925993)

---

### **5. Settings and Theme Options**
![Settings and Theme Options](https://github.com/user-attachments/assets/09e0562a-43aa-4a62-8f0e-0b8b4305ee9b)

---

## Technical Details

- **Framework**: Flutter, Dart  
- **State Management**: GetX  
- **Database**: SQLite  
- **Supported Platforms**: Android & iOS  
