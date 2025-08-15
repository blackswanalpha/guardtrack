Got it — I’ll prepare a **UI/UX Design Document** for **SiteGuard** that is:

* **Attractive** → clean modern look, appealing color system
* **Informative** → clear data hierarchy, easy navigation
* **Modern** → flat design, responsive layouts, smooth animations
* **Visually appealing** → good use of typography, spacing, and contrast

---

# **SiteGuard – UI/UX Design Document**

---

## **1. Design Goals**

The **SiteGuard** design will focus on:

* **Clarity:** Guards should quickly check in without confusion.
* **Speed:** Critical for time-sensitive arrivals.
* **Trust:** Professional, secure branding for reliability.
* **Responsiveness:** Works on all devices, even low-end Android phones.
* **Accessibility:** Color contrast meets WCAG AA standards, large tap areas.

---

## **2. Brand Identity**

**Logo Style:** Shield + location pin icon inside (symbolizing security + GPS).
**Tagline:** *"Secure Arrival. Verified Presence."*

**Color Palette:**

| Color Name          | Hex       | Usage                                    |
| ------------------- | --------- | ---------------------------------------- |
| **Primary Blue**    | `#002B5B` | Main brand color, top bars, buttons      |
| **Accent Green**    | `#28A745` | Success states (arrival confirmed)       |
| **Warning Amber**   | `#FFC107` | Pending status, location accuracy alerts |
| **Background Gray** | `#F4F6F8` | App backgrounds                          |
| **Text Dark**       | `#1A1A1A` | Main text                                |
| **Text Light**      | `#FFFFFF` | Text on dark backgrounds                 |

**Typography:**

* **Primary Font:** *Poppins* (Clean, modern, friendly)
* **Weight Usage:**

  * Bold → headings, key actions
  * Medium → labels, subheaders
  * Regular → body text

---

## **3. UI/UX Principles Applied**

1. **Hierarchy** → Arrival button is the largest element on the guard app home screen.
2. **Feedback** → On arrival, large confirmation with green check + code.
3. **Minimalism** → Only essential fields visible per screen.
4. **Contextual Actions** → Only show “Check Out” if guard is checked in.
5. **Accessibility** → Large buttons, readable fonts, high-contrast colors.

---

## **4. Mobile Guard App – Screen Designs**

---

### **4.1 Login Page**

* **Top:** SiteGuard logo
* **Middle:**

  * Email/Phone input
  * Password input
  * Login button (full-width, rounded corners, primary blue)
* **Bottom:**

  * Forgot password link
  * Minimal background security guard silhouette

**UI Style:**

* Gradient background: Blue → lighter blue fade
* Inputs with shadow + rounded edges
* Login button with hover/press animation

---

### **4.2 Home/Dashboard**

* **Top bar:** Guard name + small profile photo
* **Center:** Assigned site cards:

  * Site name, distance, status chip (color-coded)
  * Small map preview thumbnail
* **Bottom:** Large “Arrive” button with GPS icon

**Interaction:**

* Pull-to-refresh updates site list + distances
* “Arrive” button pulses if near assigned site

---

### **4.3 Arrival Success Screen**

* Full-screen green background
* Large checkmark icon animation
* Arrival code in bold, large font
* Timestamp + location accuracy
* “Back to Dashboard” button

**Animation:** Checkmark draws itself in 0.5s, then code fades in

---

### **4.4 Attendance History**

* Clean table/list of past attendance
* Filter chip row (Today, Week, Month)
* Status colors:

  * Green → Verified
  * Amber → Pending
  * Red → Rejected
* Each record card shows:

  * Site name
  * Arrival time
  * Arrival code
  * Status badge

---

---

## **5. Admin Dashboard – Screen Designs**

---

### **5.1 Dashboard**

* **Top Nav Bar:** Logo, search, profile menu
* **Left Sidebar:** Icons + labels (Dashboard, Sites, Guards, Attendance, Reports, Settings)
* **Main Area:**

  * Metric cards: Guards on duty, Sites covered, Arrivals today, Pending verifications
  * Live map with pins of latest check-ins
  * Notification feed with latest arrivals

**Visual Style:**

* White cards with soft shadows
* Green highlights for success metrics
* Map is interactive (click pin → detail popup)

---

### **5.2 Attendance Report**

* Filters row: Date picker, site selector, guard selector, status filter
* Data table:

  * Photo thumbnail
  * Guard name
  * Site name
  * Arrival time
  * Code
  * Status badge
  * Actions (View/Verify)
* Export buttons at top-right (CSV, PDF)

---

### **5.3 Attendance Detail**

* Left: Guard photo & arrival info
* Right: Map with actual arrival location
* Below: Accuracy, Code, Timestamp, Notes
* Bottom: “Verify” (green) & “Reject” (red) buttons

---

### **5.4 Site & Guard Management**

* Data tables with search
* “Add New” floating button
* Forms with clear labels & map selector for site location

---

## **6. Micro-interactions & Animations**

* **Button Press:** Slight scale-down animation
* **Arrival Success:** Animated checkmark + code reveal
* **List Updates:** Smooth fade-in
* **Map Pins:** Drop-in animation when loaded

---

## **7. Accessibility & Usability**

* Large tap targets (minimum 48px height)
* Text contrast ratio > 4.5:1
* VoiceOver / TalkBack support for inputs and buttons
* Offline mode indication with sync icon

---

## **8. Deliverables**

This document is the **blueprint** for Figma wireframes and final UI design.
Next steps:

1. **Low-fidelity wireframes** (layout without colors/images)
2. **High-fidelity mockups** (full color, branding applied)
3. **Clickable prototype** for testing flows

---

If you want, I can now **turn this document into actual high-fidelity Figma screens** for both Guard and Admin sides — with the animations and modern styling included.

Do you want me to prepare the **Figma version** next so it’s visually complete?
