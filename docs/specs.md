# SiteGuard — System Specifications

**Purpose:** Definitive technical specification for *SiteGuard*, a geolocation-based attendance system for security guards. This document is intended for developers, QA, DevOps, and stakeholders to implement, test, deploy, and operate the system.

---

# 1. Overview

**What it does:**
SiteGuard enables guards to check in/out at physical sites using their mobile device GPS, generate arrival codes, attach verification photos, and lets admins view and verify attendance via a web dashboard. It supports offline capture, notifications (push/SMS/email), audit logs, and exports.

**Primary actors:**

* Guard (mobile user)
* Admin / Supervisor (web user)
* System (backend services, notifications, storage)

**High-level goals:**

* Accurate, tamper-resistant geolocation verification
* Fast, reliable check-ins and reporting
* Scalable and secure backend
* Usable on low-end Android devices; responsive admin web UI

---

# 2. Core Functional Requirements (spec-style)

(Each FR has an ID and acceptance criteria.)

FR-001 — Authentication

* Guards and admins must authenticate. Support email/phone+password and OTP login.
* Acceptance: JWT issued on successful auth; refresh tokens supported.

FR-002 — Role-based Access Control

* Roles: `GUARD`, `ADMIN`, `SUPER_ADMIN`.
* Acceptance: APIs enforce role checks; UI adapts to role.

FR-003 — Site Management

* Admins create sites with: `name`, `address`, `latitude`, `longitude`, `radius_meters`, `timezone`, `notes`.
* Acceptance: CRUD APIs, UI forms, validation.

FR-004 — Check-in / Check-out

* Guards send check-in with `siteId`, `lat`, `lng`, `accuracy_meters`, optional `photo`, and device metadata.
* System validates location vs site center using Haversine.
* Acceptance: Server persists event, responds with `arrivalCode` and `accepted:true/false` plus reason if rejected.

FR-005 — Arrival Code Generation

* Generate human-readable code (4–6 chars alphanumeric) stored with event.
* Acceptance: Unique per event; returned to guard and included in admin notification.

FR-006 — Notifications

* On accepted check-in, notify configured admins via Push (FCM), SMS (Twilio/Africa’s Talking), and email (SMTP/SES).
* Acceptance: Notification log entry created with channel, status, timestamp.

FR-007 — Reporting & Export

* Admins can query attendance with filters (site, guard, date range, status) and export CSV/PDF.
* Acceptance: Paginated API, export button in UI.

FR-008 — Offline Capture / Sync

* Mobile app queues events when offline and retries when network available.
* Acceptance: Last-sync timestamp visible; queued events synced and deduplicated.

FR-009 — Verification Workflow

* Admin can mark events as `VERIFIED` or `REJECTED` with notes.
* Acceptance: Status update stored and visible in guard history.

FR-010 — Audit Logging

* All critical actions logged: login, check-in, verification, site changes.
* Acceptance: Immutable audit table with actor, action, timestamp, payload.

---

# 3. Non-functional Requirements

NFR-001 — Performance: 95% of check-in requests processed < 500ms (API latency), under baseline load.
NFR-002 — Scalability: Handle 5,000 concurrent guards; design supports horizontal scaling.
NFR-003 — Availability: 99.5% uptime monthly.
NFR-004 — Data retention: Attendance retained 7 years (configurable).
NFR-005 — Security: TLS everywhere; passwords hashed with Argon2 or bcrypt; JWTs signed with strong secret/keys.
NFR-006 — Compliance: Ensure PII handling conforms to local privacy rules; provide export/delete endpoints.
NFR-007 — Accessibility: Admin UI meets WCAG AA for core workflows.
NFR-008 — Device Support: Android 8+ and iOS 13+; minimal device requirements documented.

---

# 4. System Architecture (logical)

* **Mobile App (Flutter)**

  * UI, Location capture (geolocator), Camera, Local queue/DB (SQLite), Sync engine, Push notifications (FCM).
* **Backend API (Spring Boot — or Node/Express option)**

  * Auth service (JWT), Attendance service, Site service, Notification service, Admin/reporting endpoints.
* **Database**

  * PostgreSQL primary; use PostGIS extension optional for spatial queries.
* **Object Storage**

  * AWS S3 (or S3-compatible) for photos and media.
* **Notifications**

  * FCM for push; Twilio/Africa’s Talking for SMS; SES/sendgrid for email.
* **Admin Web**

  * Next.js React app communicating with backend APIs; server-side rendering optional.
* **Infrastructure**

  * Docker containers, Kubernetes/ECS, ALB/NGINX, RDS for Postgres, CloudWatch/Prometheus + Grafana, S3.
* **Monitoring & Logging**

  * Centralized logs (ELK/Opensearch), application metrics, uptime monitors.
* **CI/CD**

  * GitHub Actions / GitLab CI for build/test/deploy pipelines.

Sequence of a check-in (brief):

1. Guard taps “Arrive” → app collects GPS + photo + device metadata.
2. App POST /api/attendance/arrive with JWT.
3. Backend authenticates, computes distance to site, validates accuracy, generates arrival code, stores event, stores photo to S3, triggers notifications, returns response.
4. Admin receives notification and can verify via dashboard.

---

# 5. Data Model (tables and key fields)

**users**

* id (UUID, PK)
* name (text)
* email (text, nullable)
* phone (text)
* password\_hash (text)
* role (enum)
* status (active/inactive)
* created\_at, updated\_at

**sites**

* id (UUID, PK)
* name
* address
* lat (double)
* lng (double)
* radius\_meters (int)
* timezone (text)
* created\_by (FK users.id)
* created\_at, updated\_at

**attendance\_events**

* id (UUID, PK)
* user\_id (FK users.id)
* site\_id (FK sites.id)
* event\_type (enum: ARRIVAL, CHECKOUT, CHECKPOINT)
* occurred\_at (timestamptz) — server-assigned
* reported\_lat (double)
* reported\_lng (double)
* accuracy\_meters (double)
* arrival\_code (varchar)
* photo\_url (text)
* status (enum: PENDING, VERIFIED, REJECTED)
* device\_info (jsonb) — e.g., deviceId, osVersion
* reason (text) — for rejected/pending notes
* created\_at, updated\_at

**notifications**

* id (UUID)
* attendance\_event\_id (FK)
* channel (enum: PUSH, SMS, EMAIL)
* to (text)
* payload (jsonb)
* status (SENT, FAILED)
* error\_message (text)
* sent\_at

**audit\_log**

* id (UUID)
* actor\_user\_id (FK)
* action (text)
* target\_type (text)
* target\_id (UUID)
* payload (jsonb)
* timestamp

Indexes: create indexes on `attendance_events(user_id)`, `attendance_events(site_id, occurred_at)`, `sites(lat,lng)` (use GiST if using PostGIS).

---

# 6. API Specification (HTTP/REST, JSON)

Base path: `/api/v1`

**Auth**

* `POST /api/v1/auth/login`

  * Body: `{ "identifier": "email|phone", "password": "..." }`
  * Response: `{ "accessToken": "...", "refreshToken": "...", "expiresIn": 3600, "user": {id,name,role} }`

* `POST /api/v1/auth/refresh`

  * Body: `{ "refreshToken": "..." }` → returns new access token.

**Sites**

* `POST /api/v1/sites` (ADMIN)

  * Body: `{ name,address,lat,lng,radius_meters,timezone }`
* `GET /api/v1/sites`

  * Query: `?assignedToUserId=&nearLat=&nearLng=&radius=`
* `GET /api/v1/sites/{id}`

**Attendance**

* `POST /api/v1/attendance/arrive` (GUARD)

  * Body:

  ```json
  {
    "siteId": "uuid",
    "lat": 12.345,
    "lng": -7.89,
    "accuracy": 12.5,
    "photoBase64": "optional base64",
    "deviceInfo": { "deviceId": "xxx", "os": "Android 12" }
  }
  ```

  * Responses:

    * 200 OK (accepted):

      ```json
      { "accepted": true, "arrivalCode":"A4F3", "eventId":"uuid", "message":"Within radius" }
      ```
    * 200 OK (rejected):

      ```json
      { "accepted": false, "reason":"Out of radius", "distanceMeters": 345.2 }
      ```
    * 401 Unauthorized / 400 Bad Request

* `POST /api/v1/attendance/checkout` — similar body.

* `GET /api/v1/attendance` (ADMIN)

  * Query: `?siteId=&userId=&from=&to=&status=&page=&size=`

* `GET /api/v1/attendance/{id}` — returns full event object.

* `POST /api/v1/attendance/{id}/verify` (ADMIN)

  * Body: `{ "status":"VERIFIED"|"REJECTED", "notes":"..." }`

**Notifications**

* `GET /api/v1/notifications?since=` — admin view of notification log.

**Reports**

* `GET /api/v1/reports/attendance/export?siteId=&from=&to=&format=csv|pdf` — returns file.

**Errors / Status Codes**

* 200 OK, 201 Created, 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 409 Conflict, 500 Internal Server Error. Include structured error: `{ "errorCode":"ATT_001", "message":"..." }`.

---

# 7. Security Specification

* Transport: HTTPS/TLS 1.2+ required. HSTS enabled.
* Auth: JWT (RS256 recommended) with short expiry (e.g., 15m) and refresh tokens (rotating).
* Password storage: Argon2id or bcrypt with secure parameters.
* Input validation & sanitization on all APIs.
* Rate limiting: 100 requests/min per user, stricter on auth endpoints.
* Device trust: optionally use SafetyNet / Play Integrity (Android) to detect rooted devices.
* Access control: RBAC checks server-side for every operation.
* Secrets: store in secrets manager (AWS Secrets Manager / vault).
* Backups: nightly DB backups and weekly offsite snapshot retention (configurable).
* Data deletion: support GDPR-style user data deletion on request.

---

# 8. Anti-spoofing & Fraud Mitigation

* Validate `accuracy_meters` and reject if > configurable threshold (default 50m).
* Haversine distance check: require `distance <= radius_meters + 20m tolerance` (configurable).
* Use server timestamp for `occurred_at`. Do not trust client time.
* Require photo/selfie: correlate face with stored guard photo (optional face-match later).
* Maintain device\_id and detect rapid location jumps or impossible movements.
* Flag suspicious events for manual review (e.g., repeated rejections then accept).
* Optional: device attestation to detect emulators/rooted devices.

---

# 9. Offline Behavior & Sync Rules

* Mobile app stores queued events in local SQLite with status: `QUEUED`, `SENT`, `FAILED`.
* On network restore, app retries POST, with exponential backoff.
* Deduplication: server-side idempotency key: client includes `clientEventId` (UUID v4) per event; server returns 409 if duplicate.
* Conflict resolution: server authoritative — if server rejects due to distance, app shows error and marks event `REJECTED_REMOTE`.

---

# 10. Deployment & Infrastructure

**Environment tiers:** `dev`, `staging`, `prod`.

**Containers:** Docker images for Backend API and Next.js.
**Orchestration:** Kubernetes (EKS/GKE) or ECS.
**Database:** RDS PostgreSQL Multi-AZ recommended.
**Storage:** S3 with lifecycle rules (move old photos to Glacier).
**Domain & SSL:** Use managed certs (AWS ACM).
**CI/CD:** Build → test → push image → deploy to staging → smoke tests → promote to prod.

**Scaling Policy:**

* Backend: auto-scale based on CPU & request latency.
* Database: read replicas for reporting (read-heavy queries).

**Cost considerations:** Optimize photo size, use caching, and limit notification retries.

---

# 11. Monitoring, Logging and Alerting

* **Metrics:** request latency, error rates, check-ins per minute, queue size, notification failures.
* **Logging:** structured JSON logs to central log store. Mask PII.
* **Tracing:** distributed tracing (OpenTelemetry) for performance debugging.
* **Alerts:** on high error rate (>1% 5xx), high notification failure rate, DB replication lag, available disk low.
* **SLOs/SLAs:** 99.5% uptime, 95% check-in API under 500ms.

---

# 12. Testing Strategy

* **Unit tests:** services, validation logic, auth.
* **Integration tests:** DB, S3 mocks, notification stubs.
* **API contract tests:** OpenAPI/Swagger tests.
* **End-to-end tests:** mobile app flows (check-in offline/online), admin verification.
* **Security tests:** dependency checks, pen tests for prod.
* **Load tests:** simulate 5k concurrent guards and burst check-ins.

---

# 13. Migration & Versioning

* Use migration tool (Flyway/Liquibase) for DB schema changes.
* API versioning header or path (`/api/v1/...`) — keep backward compatibility for at least one previous minor version.
* Media files: immutable path with eventId folder.

---

# 14. OpenAPI / Swagger

* Provide Swagger spec for all endpoints; generate server SDKs and client SDKs (TypeScript, Kotlin, Dart) as part of release pipeline.

---

# 15. Deliverables & Roadmap (minimal viable set)

**MVP (Phase 1):**

* Guard mobile app: login, view sites, arrive (GPS + photo), offline queue.
* Backend: auth, sites, attendance, arrival code, notifications (push), admin dashboard list & verify.
* DB, S3, CI/CD pipeline, basic monitoring.

**Phase 2:**

* SMS & email notifications, exports, advanced filtering, facial verification optional, device attestation.

**Phase 3+:**

* Patrol points, checkpoints schedule, advanced analytics, SLA grade exports, multi-tenant support.

---

# 16. Appendix

**Haversine formula (server)**

* Provided as pseudo:

```
earthRadius = 6371000 // meters
dLat = radians(lat2-lat1)
dLng = radians(lng2-lng1)
a = sin(dLat/2)^2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dLng/2)^2
c = 2 * atan2(sqrt(a), sqrt(1-a))
distance = earthRadius * c
```

**Arrival code generation**

* Use cryptographically secure RNG, uppercase alphanumeric, avoid ambiguous chars (I/O, 0/O). Example: length 5 from `ABCDEFGHJKLMNPQRSTUVWXYZ23456789`.

**Idempotency**

* Client includes `Idempotency-Key` header or `clientEventId` in body for event POSTs.

---

If you want, I can:

* Generate the **OpenAPI (Swagger) spec** next for the endpoints listed.
* Produce **DB migration scripts** (Postgres SQL) for the tables above.
* Create **a minimal starter repo** (Flutter mobile + Spring Boot backend) scaffolded to this spec.

Which one would you like me to produce now?
