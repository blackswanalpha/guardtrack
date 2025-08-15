# GuardTrack Admin Portal

## Overview

The GuardTrack Admin Portal is a comprehensive administrative interface for managing security operations, employee attendance, site management, and reporting. This portal provides administrators with powerful tools to oversee and manage their security workforce effectively.

## Features Implemented

### 🔐 Authentication & Access
- **Custom Admin Login Screen**: Dedicated login interface with enhanced security
- **2FA Support**: Two-factor authentication for admin accounts
- **Role-based Access Control**: Automatic routing based on user roles
- **Access Admin Option**: Seamless transition from regular login to admin portal

### 📊 Admin Dashboard
- **Welcome Section**: Personalized greeting with last login information
- **Key Statistics**: Overview cards showing:
  - Total Employees (156)
  - Active Sites (24)
  - Attendance Rate (94.2%)
  - Active Alerts (7)
- **Quick Actions Panel**: Fast access to common tasks:
  - Add Employee
  - Add Site
  - Create Assignment
  - Send Notification
  - Generate Report
  - Live Tracking
- **Recent Activity Feed**: Real-time updates on system activities
- **Analytics Preview**: Attendance trends and performance metrics

### 👥 Employee Management
- **Employee List View**: Comprehensive employee directory with search and filters
- **Active/Inactive Tabs**: Separate views for current and former employees
- **Employee Analytics**: Performance metrics and statistics
- **Employee Cards**: Detailed information including:
  - Profile information
  - Role and site assignments
  - Last seen status
  - Quick action buttons
- **Bulk Operations**: Import/export functionality
- **Employee Actions**: Edit, view details, and manage employee records

### ⏰ Attendance Management
- **Today's Attendance**: Real-time attendance tracking
- **Attendance Statistics**: Present, late, and absent counts
- **History View**: Historical attendance records
- **Alerts System**: Late arrival and absence notifications
- **Live Map Integration**: Real-time guard location tracking
- **Attendance Cards**: Individual employee attendance status

### 📍 Site Management
- **Site Overview**: Statistics for total sites, active guards, and coverage
- **Site Directory**: Comprehensive list of all managed sites
- **Site Details**: Information including:
  - Site identification
  - Guard assignments
  - Coverage schedules
  - Geofence settings
- **Site Performance**: Monitoring and analytics for each location

### 📈 Reports & Analytics
- **Quick Reports**: One-click generation for:
  - Daily Attendance
  - Weekly Summary
  - Monthly Report
  - Site Performance
- **Report Categories**: Organized reporting sections:
  - Attendance Reports
  - Employee Reports
  - Site Reports
- **Recent Reports**: History of generated reports with download/share options
- **Scheduled Reports**: Automated report generation

## Technical Architecture

### File Structure
```
lib/features/admin/
├── presentation/
│   ├── pages/
│   │   ├── admin_dashboard_page.dart
│   │   ├── admin_main_navigation_page.dart
│   │   ├── employee_management_page.dart
│   │   ├── attendance_management_page.dart
│   │   ├── site_management_page.dart
│   │   └── reports_page.dart
│   └── widgets/
│       ├── admin_stats_card.dart
│       ├── admin_quick_actions.dart
│       └── admin_recent_activity.dart
```

### Authentication Flow
1. User clicks "Access Admin Portal" on regular login
2. Redirected to custom admin login screen
3. Enhanced authentication with 2FA support
4. Role verification (admin/superAdmin only)
5. Automatic routing to admin dashboard

### Navigation System
- **Bottom Navigation**: 5 main sections (Dashboard, Employees, Attendance, Sites, Reports)
- **Role-based Routing**: Automatic detection and routing for admin users
- **Consistent UI**: Maintains GuardTrack design system and branding

## Mock Data & Testing

### Admin Login Credentials (Mock)
- **Email**: Any email containing "admin" (e.g., admin@company.com)
- **Password**: Any password with 6+ characters
- **2FA Code**: Any 6-digit code (e.g., 123456)

### Sample Data
- **Employees**: 156 total (142 active, 14 inactive)
- **Sites**: 24 active locations with various coverage levels
- **Attendance**: Real-time mock data with different statuses
- **Reports**: Sample report history with various types

## UI/UX Design

### Color Scheme
- **Primary**: Deep blue (#1A237E) for admin branding
- **Secondary**: Standard GuardTrack colors maintained
- **Status Colors**: Green (success), Amber (warning), Red (error)

### Components
- **Cards**: Consistent card-based layout for information display
- **Statistics**: Visual representation with icons and trend indicators
- **Navigation**: Intuitive bottom navigation with clear icons
- **Actions**: Quick action buttons with appropriate icons and colors

## Future Enhancements

### Planned Features (Not Yet Implemented)
1. **Assignment Management Module**: Task assignment and tracking
2. **Notifications Module**: Push notification management
3. **Settings & Admin Tools**: System configuration
4. **Support & Help Module**: Help center and support tickets
5. **Advanced Analytics**: Charts and detailed reporting
6. **Real-time Map View**: Live guard tracking with Google Maps
7. **Bulk Operations**: Advanced import/export functionality
8. **User Role Management**: Granular permission controls

### Technical Improvements
- **API Integration**: Connect to real backend services
- **Real-time Updates**: WebSocket integration for live data
- **Offline Support**: Caching and offline functionality
- **Performance Optimization**: Lazy loading and pagination
- **Testing**: Comprehensive unit and integration tests

## Getting Started

### Prerequisites
- Flutter SDK
- GuardTrack base application
- Admin user account

### Running the Admin Portal
1. Launch the GuardTrack application
2. On the login screen, tap "Access Admin Portal"
3. Enter admin credentials with 2FA
4. Navigate through the admin dashboard and modules

### Development
The admin portal is fully integrated into the existing GuardTrack codebase and follows the same architectural patterns and conventions.

## Support

For technical support or feature requests related to the admin portal, please refer to the main GuardTrack documentation or contact the development team.
