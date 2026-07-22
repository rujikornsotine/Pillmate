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
│   └── widgets/        # EmptyState, ConfirmDialog, ScaffoldWithNavBar
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
`ReminderConstants.syncWindowDays` (7 วัน) แล้ว sync ใหม่ทุกครั้งที่เปิดแอปหรือแก้ไขตารางยา

```text
เปิดแอป / แก้ไขตารางยา
       │
       ▼
SyncRemindersUseCase
       │
       ▼
ScheduleOccurrenceCalculator   (Domain Service คำนวณมื้อยาล่วงหน้า)
       │
       ▼
ReminderRepository
       │
       ▼
NotificationService  →  flutter_local_notifications
```

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