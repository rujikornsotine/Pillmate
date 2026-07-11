# AI Context

## Project Name

PillMate

---

## Project Type

Mobile Application

---

## Purpose

แอปพลิเคชันสำหรับ

- แจ้งเตือนการทานยา
- บันทึกประวัติการทานยา
- เก็บข้อมูลรายการยา
- แสดงรูปภาพยา
- ช่วยให้ผู้ใช้ไม่ลืมทานยา

---

## Technology Stack

Frontend

- Flutter
- Dart

Architecture

- Clean Architecture

State Management

- Riverpod

Database

- Hive

Notification

- flutter_local_notifications

Navigation

- go_router

Image

- image_picker

Testing

- flutter_test
- mocktail

Version Control

- Git
- GitHub

CI/CD

- GitHub Actions

---

## Architecture Rules

ใช้ Clean Architecture

```text
Presentation
 ↓
Domain
 ↓
Data
```

ห้าม

- UI เข้าถึง Database
- UI มี Business Logic
- UI เรียก Hive โดยตรง

---

## Folder Structure

```text
core/
features/
l10n/
```

ทุก Feature ต้องมี

```text
data/
domain/
presentation/
```

---

## Coding Rules

Comment

- ภาษาไทย

Class Name

- ภาษาอังกฤษ

Method Name

- ภาษาอังกฤษ

Variable Name

- ภาษาอังกฤษ

---

## State Management Rules

ใช้ Riverpod เท่านั้น

อนุญาต

- Provider
- FutureProvider
- AsyncNotifier

หลีกเลี่ยง

```dart
setState()
```

---

## Database Rules

ใช้ Hive เท่านั้น

ผ่าน Repository Pattern

```text
UI
 ↓
UseCase
 ↓
Repository
 ↓
Hive
```

---

## Testing Rules

AI ต้องสร้าง

- Unit Test
- Mock Dependency

สำหรับ

- UseCase
- Repository
- Service

Coverage

```text
80%+
```

---

## Git Rules

Branch

```text
feature/*
bugfix/*
hotfix/*
```

Commit

```text
feat:
fix:
docs:
test:
refactor:
chore:
```

---

## Feature List

### Medication

- Add Medication
- Edit Medication
- Delete Medication
- Medication Image

### Schedule

- Daily Schedule
- Weekly Schedule
- Custom Schedule

### Reminder

- Local Notification
- Snooze
- Mark As Taken

### History

- Daily History
- Monthly History
- Search History

### Dashboard

- Today's Medication
- Next Reminder
- Daily Summary

---

## AI Instructions

เมื่อ AI สร้างโค้ดใหม่

1. ใช้ Flutter + Dart เท่านั้น
2. ใช้ Riverpod ทุกครั้ง
3. ใช้ Clean Architecture
4. แยก Feature ตาม Folder Structure
5. Comment ภาษาไทย
6. Class และ Method ภาษาอังกฤษ
7. สร้าง Unit Test เสมอ
8. หลีกเลี่ยง StatefulWidget
9. Reuse Component เดิมก่อนสร้างใหม่
10. ห้ามแก้ไข Architecture ที่กำหนด
11. ห้ามเพิ่ม Dependency ใหม่โดยไม่มีเหตุผล
12. อัปเดต Documentation เมื่อเพิ่ม Feature ใหม่

---

## Definition of Done

Feature จะถือว่าเสร็จเมื่อ

- Build ผ่าน
- Analyzer ผ่าน
- Unit Test ผ่าน
- ไม่มี Warning สำคัญ
- ใช้งานได้จริง
- Documentation ถูกอัปเดต