# Akilesiya (አቅሌስያ)

**Sunday School Management System for Ethiopian Orthodox Tewahedo Church**

*"የነገዋ ቤተ ክርስቲያን ዛሬ ትገነባለች" - Building Tomorrow's Church Today*

---

## What is Akilesiya?

Akilesiya is a Flutter-based mobile and desktop application designed to help Ethiopian Orthodox Tewahedo Church Sunday Schools manage their students, teachers, attendance, grades, and learning materials digitally.

Originally developed for **Amde Haymanot Sunday School** at St. Mary's Cathedral in Jimma Diocese, the app provides tools for administrators, teachers, students, and parents to track spiritual education progress.

---

## Core Features

### For Students
- **Profile Management** - View and edit personal information
- **Learning Materials** - Access articles, books, and video content
- **Attendance History** - View personal attendance records
- **Grade Tracking** - See academic performance
- **Activity Log** - Track participation in church activities

### For Teachers
- **Attendance Taking** - Mark student attendance with Ethiopian calendar support
- **Grade Management** - Enter and manage student grades
- **Student Notes** - Keep private notes about student development
- **Content Upload** - Share learning materials with students
- **Class Roster** - View and manage student lists

### For Administrators
- **User Management** - Add, edit, and manage users (students, teachers, parents)
- **Attendance Reports** - Generate attendance statistics and reports
- **Grade Reports** - View academic performance across classes
- **Family Management** - Link students to their parents/guardians
- **Permission Management** - Assign roles and permissions to users
- **Content Moderation** - Manage learning materials and posts
- **Audit Logs** - Track changes and system activities

### For System Administrators
- **Multi-School Management** - Manage multiple Sunday Schools (multi-tenant system)
- **School Registration** - Create and configure new schools
- **Platform Analytics** - View system-wide statistics
- **User Promotion** - Promote users to admin roles
- **System Settings** - Configure platform-wide settings

---

## Technical Features

### Ethiopian Calendar Support
- Full integration with Ethiopian (Ge'ez) calendar using `abushakir` package
- Dual calendar display (Gregorian and Ethiopian)
- Ethiopian date picker for attendance and events
- Church holiday recognition

### Multi-Language Support
The app includes localization files for:
- Amharic (አማርኛ)
- English
- Oromo (Afaan Oromoo)
- Tigrinya (ትግርኛ)

### Offline Functionality
- Local data storage using `shared_preferences` and `flutter_secure_storage`
- Sync provider for managing online/offline states
- Background synchronization when internet is available

### User Interface
- Dark mode theme (midnight gold aesthetic)
- Responsive design for mobile, tablet, and desktop
- Smooth animations using `animate_do` and `flutter_staggered_animations`
- Loading states with shimmer effects
- Custom fonts (Google Fonts - Poppins, Noto Sans Ethiopic)

---

## Technology Stack

### Frontend
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod, Provider
- **Navigation:** GoRouter
- **UI:** Material Design 3

### Backend
- **API:** Node.js REST API
- **Base URL:** `http://akilesiya.amdehaymanot.com/api`
- **Authentication:** JWT tokens
- **Storage:** Cloudinary for images and media

### Key Dependencies
```yaml
# Core
flutter_riverpod: ^2.5.1
go_router: ^16.0.0
provider: ^6.1.2

# UI & Fonts
google_fonts: ^6.3.0
animate_do: ^4.2.0
shimmer: ^3.0.0
font_awesome_flutter: ^10.8.0
iconsax: ^0.0.8

# Data & Storage
shared_preferences: ^2.2.2
flutter_secure_storage: ^9.2.4
cached_network_image: ^3.3.1

# Media
image_picker: ^1.1.2
youtube_player_flutter: ^9.0.0
video_player: ^2.8.6
cloudinary_public: ^0.23.1

# Ethiopian Calendar
abushakir: ^1.0.0
ethiopian_datetime_picker: ^0.0.2+1

# Charts & Visualization
syncfusion_flutter_charts: ^30.1.41
fl_chart: ^1.1.1

# Documents
flutter_quill: ^11.4.2
pdf: ^3.10.4
printing: ^5.11.0

# Utilities
intl: ^0.20.2
connectivity_plus: ^6.1.4
url_launcher: ^6.3.0
```

---

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

---

## Main Screens

### User Screens
- Splash Screen
- Start Screen (Welcome)
- Login
- Sign Up
- Home Screen (with bottom navigation)
- Profile Screen
- Settings Screen
- Learning Screen
- About Us

### Admin Screens
- Admin Hub
- User Management
- Student List
- Post Management
- Permission Management
- Family Management
- Profile Template Builder
- Screen Time Dashboard
- Print Data/Reports
- Audit Logs

### Teacher/Role-Based Screens
- Attendance Manager
- Attendance Summary
- Attendance Detail
- Grade Management
- All Members Screen
- Member Development Hub
- Admin Notes (Student Development Notes)
- Activity Screen
- Family View
- Family Detail
- Plan Management
- Library Management
- Learning Admin Hub
- Star Rating Management

### System Admin Screens
- System Dashboard
- Schools List
- School Detail
- Create School
- Edit School
- User Management
- User Detail
- Promote Admin
- Platform Analytics
- System Settings
- Audit Logs

---

## User Roles

The app implements role-based access control with the following roles:

1. **Student** - Access to learning materials, view own attendance and grades
2. **Teacher** - Manage attendance, grades, and student notes
3. **Admin** - School-level administration, user management, reports
4. **System Admin** - Platform-level management, multi-school oversight

---

## Key Functionalities

### Attendance Management
- Take attendance with Ethiopian calendar
- Filter by session (morning/afternoon)
- Filter by attendance type (learning, hymn learning, awudemihiret, special)
- Mark status: present, absent, late, permission
- View attendance history and statistics
- Generate attendance reports

### Grade Management
- Enter and manage student grades
- Track academic performance over time
- Generate grade reports
- Export to PDF

### Learning Content
- Upload and manage articles
- YouTube video integration
- Book library with reviews
- Rich text editor (Quill) for content creation
- Cloudinary integration for media storage

### Family Management
- Link students to parents/guardians
- View family relationships
- Family-based reporting

### Reports & Analytics
- Attendance reports (daily, weekly, monthly, yearly)
- Grade reports
- Student development reports
- Platform analytics (for system admins)
- PDF export functionality

---

## Installation

### Prerequisites
- Flutter SDK 3.2.0 or higher
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Node.js backend (separate repository)

### Setup

1. **Clone the repository**
```bash
git clone https://github.com/DawitTemesgen1/akilesiya-.git
cd akilesiya
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure environment**
Create a `.env` file in the project root:
```env
API_BASE_URL=http://akilesiya.amdehaymanot.com/api
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

4. **Run the app**
```bash
flutter run
```

### Build for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

---

## Project Structure

```
lib/
├── admin only/          # Admin-specific screens
├── role based/          # Role-based screens (teachers, etc.)
├── system admin/        # System administrator screens
├── users screen/        # General user screens
├── services/            # API services and business logic
├── providers/           # State management (Riverpod/Provider)
├── models/              # Data models
├── constants/           # App constants
├── l10n/                # Localization files
└── widgets/             # Reusable widgets
```

---

## Configuration

### App Name
The app is named "አቅሌስያ" (Akilesiya) in the splash screen and throughout the UI.

### Theme
- Primary Color: Dark blue (#012564)
- Accent Color: Gold (#FFD700)
- Dark Mode: Midnight gold theme with premium aesthetics
- Custom fonts via Google Fonts

### Localization
Localization files are located in `lib/l10n/`:
- `app_en.arb` - English
- `app_am.arb` - Amharic
- `app_om.arb` - Oromo
- `app_ti.arb` - Tigrinya

---

## API Integration

The app communicates with a Node.js backend API. Key services include:

- **AuthService** - Login, registration, user authentication
- **ApiService** - Base HTTP client with token management
- **AdminService** - Admin operations
- **SystemAdminService** - System-level operations
- **LearningService** - Learning content management
- **TenantService** - Multi-school management

---

## Development Status

This is an active development project. The codebase includes:
- ✅ Complete authentication system
- ✅ Multi-tenant architecture
- ✅ Attendance management with Ethiopian calendar
- ✅ Grade management
- ✅ User management and role-based access
- ✅ Learning content system
- ✅ Offline support
- ✅ Multi-language support
- ✅ Report generation and PDF export

---

## Contact

- **Website:** [akilesiya.amdehaymanot.com](http://akilesiya.amdehaymanot.com)
- **Repository:** [github.com/DawitTemesgen1/akilesiya-](https://github.com/DawitTemesgen1/akilesiya-)

---

## License

This project is licensed under the MIT License.

---

## Acknowledgments

Developed for the Ethiopian Orthodox Tewahedo Church Sunday School system, specifically for Amde Haymanot Sunday School at St. Mary's Cathedral, Jimma Diocese.

---

© 2024 Akilesiya. All rights reserved.
