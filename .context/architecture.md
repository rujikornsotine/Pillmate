# PillMate Architecture

## Overview

PillMate เป็น Mobile Application สำหรับช่วยแจ้งเตือนและติดตามการรับประทานยา

Architecture หลักของระบบใช้

- Flutter
- Clean Architecture
- Riverpod
- Hive
- Local Notification

---

# Architecture Style

ใช้ Clean Architecture

```text
Presentation
      │
      ▼
Domain
      │
      ▼
Data
```

Dependencies ต้องไหลจากบนลงล่างเท่านั้น

- Presentation → Domain
- Data → Domain

ห้าม

- Presentation เรียก Hive โดยตรง
- Presentation เรียก Notification Service โดยตรง
- UI มี Business Logic

---

# Project Structure

```text
lib/

├── core/
│   ├── constants/      # HiveBoxes, ReminderConstants
│   ├── exceptions/     # AppException
│   ├── router/         # app_router.dart (go_router)
│   ├── services/       # NotificationService, ImageStorageService
│   ├── theme/          # AppTheme
│   ├── utils/          # Result<T>, IdGenerator, TimeOfDayFormatter
│   └── widgets/        # EmptyState, ConfirmDialog, ScaffoldWithNavBar,
│                       # GradientAppHeader, StatusBadge
│
├── features/
│   │
│   ├── medication/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── reminder/
│   │   ├── data/
│   │   ├── domain/          # มี services/ สำหรับ ScheduleOccurrenceCalculator
│   │   └── presentation/
│   │
│   ├── history/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── dashboard/
│       ├── domain/          # อ่านอย่างเดียว จึงไม่มีชั้น data/
│       └── presentation/
│
├── app.dart
├── main.dart
└── notification_background_handler.dart
```

หมายเหตุ

- `dashboard` ไม่มีชั้น `data/` เพราะใช้ Repository ของ medication / reminder / history
  ผ่าน `GetTodayDosesUseCase`
- `l10n/` ยังไม่ถูกสร้าง (ยังไม่ได้ทำ localization)

---

# Layer Responsibilities

## Presentation

รับผิดชอบ

- Screen
- Widget
- Provider
- State
- User Interaction

ห้าม

- Query Database
- เขียน Business Logic

---

## Domain

รับผิดชอบ

- Entity
- Use Case
- Repository Contract

ตัวอย่าง

```text
Medication
MedicationRepository
CreateMedicationUseCase
```

Domain ต้องไม่มี dependency กับ Flutter

---

## Data

รับผิดชอบ

- Repository Implementation
- Hive Data Source
- DTO
- Mapper

ตัวอย่าง

```text
MedicationRepositoryImpl
MedicationLocalDataSource
MedicationModel
```

---

# State Management

ใช้ Riverpod เท่านั้น

ประเภทที่อนุญาต

- Provider
- FutureProvider
- AsyncNotifierProvider

หลีกเลี่ยง

- StatefulWidget
- setState()

---

# Local Database

ใช้ Hive

Boxes ที่เปิดใช้งานจริงใน `main.dart`

| Box | typeId | Model |
|---|---|---|
| `medications` | 0 | `MedicationModel` |
| `schedules` | 1 | `ScheduleModel` |
| `histories` | 2 | `MedicationHistoryModel` |

`HiveBoxes.settings` ถูกประกาศไว้แล้วแต่ยังไม่มีการใช้งาน (สำรองไว้สำหรับ feature ตั้งค่าในอนาคต)

---

# Notification Architecture

Notification ต้องถูกจัดการผ่าน `NotificationService` กลางเท่านั้น
Presentation ห้ามเรียก `NotificationService` โดยตรง

## ขาตั้งเวลาแจ้งเตือน (Schedule)

แอปไม่มี Background Task ที่รันตลอดเวลา จึงใช้วิธีตั้งเวลาแจ้งเตือนล่วงหน้าเป็นหน้าต่าง
`ReminderConstants.syncWindowDays` (7 วัน) แล้ว sync ใหม่ทุกครั้งที่เปิดแอป ทุกครั้งที่แอป
กลับมา foreground (`AppLifecycleState.resumed`) และทุกครั้งที่แก้ไขตารางยา

```text
เปิดแอป / กลับเข้าแอป / แก้ไขตารางยา
       │
       ▼
SyncRemindersUseCase
       │
       ▼
ScheduleOccurrenceCalculator   (Domain Service คำนวณมื้อยาล่วงหน้า)
       │
       ▼
ReminderRepository             (ตรวจสิทธิ์ปลุกตรงเวลาครั้งเดียวต่อตาราง)
       │
       ▼
NotificationService  →  flutter_local_notifications
```

ทุกชั้นต้องรายงานความล้มเหลวขึ้นไปเสมอ ห้ามกลืน error

- `NotificationService` ดัก `PlatformException` เฉพาะรหัส `exact_alarms_not_permitted`
  เพื่อถอยไปตั้งแบบไม่ตรงเวลา ส่วน error อื่น `rethrow`
- `ReminderRepository` ห่อเป็น `Result.failure`
- `SyncRemindersUseCase` ตั้งตารางที่เหลือต่อจนครบแล้วรายงานข้อผิดพลาดแรกที่เจอ
- `app.dart` แสดง SnackBar เมื่อ sync ไม่สำเร็จ

## สิทธิ์การแจ้งเตือน

Android 14 (API 34) ขึ้นไปไม่อนุญาต `SCHEDULE_EXACT_ALARM` ให้อัตโนมัติอีกต่อไป
(โปรเจกต์นี้ `targetSdk = 36`) ถ้าสั่งปลุกตรงเวลาโดยยังไม่ได้รับสิทธิ์ ปลั๊กอินจะโยน
`exact_alarms_not_permitted` และการแจ้งเตือนทุกรายการจะล้มเหลว

```text
ReminderPermissionBanner  (แสดงเหนือทุกแท็บ ซ่อนเองเมื่อสิทธิ์ครบ)
       │  อธิบายเหตุผลด้วย ConfirmDialog ก่อนเสมอ
       ▼
RequestExactAlarmPermissionUseCase / RequestNotificationPermissionUseCase
       │
       ▼
ReminderRepository
       │
       ▼
NotificationService  →  พาผู้ใช้ไปหน้าตั้งค่าของระบบ
```

กฎที่ต้องรักษาไว้

- ห้ามพาผู้ใช้ออกไปหน้าตั้งค่าของระบบโดยไม่อธิบายเหตุผลก่อน (สิทธิ์ปลุกตรงเวลาไม่ใช่ dialog
  ในแอป แต่เป็นการเปลี่ยนหน้าจอออกไปทั้งหน้า ระบบไม่ได้อธิบายอะไรให้)
- ห้ามขอสิทธิ์ปลุกตรงเวลาเองอัตโนมัติทุกครั้งที่เปิดแอป
- ถ้าไม่ได้รับสิทธิ์ ต้องยังตั้งแจ้งเตือนต่อแบบ `inexactAllowWhileIdle` ไม่ใช่ไม่ตั้งเลย
- `ReminderPermissionStatus` แยก `notificationsEnabled` กับ `exactAlarmsAllowed` เพราะ
  ผลกระทบต่างกัน (ไม่ขึ้นเลย กับ ขึ้นแต่ไม่ตรงเวลา)

`ScaffoldWithNavBar` (core) รับ banner จากภายนอกเป็น `Widget?` เพื่อไม่ให้ core ผูกกับ
Feature ใด Feature หนึ่ง โดยมี `app_router.dart` เป็นผู้ประกอบร่าง

## ขารับ Action จากการแจ้งเตือน

```text
NotificationService (actionEvents stream)
       │
       ▼
app.dart  (แอปเปิดอยู่)  /  notification_background_handler.dart  (แอปปิดอยู่)
       │
       ▼
RecordMedicationIntakeUseCase
       │
       ▼
MedicationHistoryRepository  →  Hive
```

พฤติกรรมที่กำหนดใน `ReminderConstants`

- `actionMarkAsTaken` — บันทึกสถานะ `taken`
- `actionSnooze` — บันทึกสถานะ `snoozed` และเลื่อนแจ้งเตือนออกไป `snoozeDelay` (15 นาที)
- `actionOpen` — แตะที่ตัวการแจ้งเตือน เปิดแอปแล้วแสดง popup ยืนยันการทานยา
- `followUpDelay` — เตือนซ้ำใน 15 นาที ถ้ายังไม่ยืนยันการทาน

---

# Error Handling

ทุก Repository ต้องคืนค่า

```text
Result<T>
```

ตัวอย่าง

Success

```dart
Result.success(data)
```

Failure

```dart
Result.failure(message)
```

ห้ามโยน Exception ไป UI Layer

---

# Dependency Injection

ใช้ Riverpod Providers

ไม่ใช้

- get_it
- injectable

---

# Testing Strategy

Unit Test

- Use Case
- Repository
- Service

Widget Test

- Screen
- Widget

Coverage

```text
80%+
```

---

# Future Expansion

รองรับ

- Cloud Sync
- Authentication
- Multi Device
- Smart Watch
- Doctor Report Export