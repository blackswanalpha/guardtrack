Got it ✅ — I’ll draft **comprehensive System Requirements** for the attendance app (**SiteGuard**), covering both functional and non-functional requirements, plus hardware/software needs.

---

## **GuardTrack – System Requirements Document (SRD)**

### 1. **Introduction**

**Purpose**
SiteGuard is a geolocation-based attendance tracking system for security personnel. It ensures that guards log in, confirm their arrival on-site via GPS verification, and generate an arrival code for administrative reporting.

**Scope**

* Mobile app for security guards to check in/out.
* Admin dashboard to monitor attendance, view reports, and verify arrival.
* Geolocation validation to prevent fraudulent check-ins.
* Automatic notifications when a guard arrives.
* Data storage for audit and compliance.

---

### 2. **Functional Requirements**

#### **2.1 User Management**

* FR-1: The system shall allow guards and admins to log in with secure credentials (email/phone + password or OTP).
* FR-2: The system shall allow admins to create, edit, and deactivate guard accounts.
* FR-3: The system shall support role-based access control (Guard, Admin, Super Admin).

#### **2.2 Site Management**

* FR-4: Admin shall be able to register sites with:

  * Name
  * Address
  * Latitude/Longitude
  * Allowed radius (in meters)
* FR-5: Admin shall be able to edit or remove sites.

#### **2.3 Attendance Logging**

* FR-6: Guards shall be able to view a list of assigned sites.
* FR-7: Guards shall be able to send an **Arrival** event with:

  * GPS coordinates
  * Accuracy level
  * Optional photo/selfie
* FR-8: The system shall validate if guard location is within the allowed site radius.
* FR-9: The system shall generate a unique **arrival code** when a guard checks in successfully.
* FR-10: The system shall allow guards to log **Check-Out** when leaving.
* FR-11: The system shall store all attendance records with timestamps.

#### **2.4 Notifications**

* FR-12: Admin shall receive push notifications or SMS when a guard arrives.
* FR-13: The system shall log all notifications sent.

#### **2.5 Reporting**

* FR-14: Admin shall be able to view attendance history by:

  * Date range
  * Site
  * Guard
  * Status
* FR-15: Admin shall be able to export attendance reports to CSV/PDF.

#### **2.6 Security & Verification**

* FR-16: The system shall reject arrivals with GPS accuracy worse than 50 meters.
* FR-17: The system shall use server timestamps to prevent time spoofing.
* FR-18: The system shall store a photo (if taken) with the event for verification.
* FR-19: Admin shall be able to mark attendance as Verified or Rejected with notes.

---

### 3. **Non-Functional Requirements**

#### **3.1 Performance**

* NFR-1: The mobile app shall record attendance within 3 seconds after pressing “Arrive”.
* NFR-2: The system shall handle at least 1000 concurrent users.

#### **3.2 Security**

* NFR-3: All API calls shall be over HTTPS.
* NFR-4: JWT authentication with refresh tokens shall be used.
* NFR-5: Passwords shall be hashed using bcrypt or Argon2.

#### **3.3 Reliability**

* NFR-6: The system shall have 99.5% uptime.
* NFR-7: The mobile app shall support offline check-in and sync when online.

#### **3.4 Usability**

* NFR-8: The mobile app shall work on Android 8+ and iOS 13+.
* NFR-9: The admin dashboard shall be mobile-responsive.

---

### 4. **Hardware & Software Requirements**

#### **4.1 Mobile App (Guard)**

* **Hardware:**

  * Android device with GPS & camera, 2GB RAM minimum
  * iOS device with GPS & camera, 2GB RAM minimum
* **Software:**

  * Android 8.0+
  * iOS 13+
  * Flutter runtime

#### **4.2 Admin Dashboard**

* **Hardware:**

  * Any desktop/laptop with modern browser (Chrome, Firefox, Edge)
  * Minimum 4GB RAM
* **Software:**

  * Web browser (latest version)

#### **4.3 Server**

* **Minimum:**

  * 2 vCPU, 4GB RAM
  * 20GB SSD storage
* **Recommended:**

  * 4 vCPU, 8GB RAM
  * PostgreSQL 14+
  * AWS S3 for file storage

---

### 5. **External Integrations**

* Google Maps API (geolocation & distance calculation)
* Firebase Cloud Messaging (push notifications)
* Twilio (or Africa’s Talking) for SMS notifications
* AWS S3 (photo storage)

---

### 6. **Constraints**

* GPS availability and accuracy depends on the device and location environment.
* Internet connection is required for real-time updates, but offline mode will store data for later sync.

---

### 7. **Acceptance Criteria**

* Guard can log in, select a site, check in with GPS, and system validates location.
* Arrival code is generated and visible to guard & admin.
* Admin receives arrival notification instantly.
* Attendance records are viewable in dashboard with location, time, photo, and code.
* Reports can be exported.

---

If you want, I can now **convert this into a complete System Design document** with architecture diagrams, database ERD, and API specs so your dev team can start coding immediately.

Do you want me to prepare that next?
