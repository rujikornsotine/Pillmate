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
│   ├── constants/
│   ├── exceptions/
│   ├── extensions/
│   ├── services/
│   ├── theme/
│   ├── router/
│   └── widgets/
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
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── history/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── dashboard/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── l10n/
├── app.dart
└── main.dart
```

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

Boxes

```text
medications
schedules
histories
settings
```

---

# Notification Architecture

```text
NotificationService
       │
       ▼
ReminderRepository
       │
       ▼
ReminderUseCase
       │
       ▼
UI
```

Notification ต้องถูกจัดการผ่าน Service กลางเท่านั้น

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