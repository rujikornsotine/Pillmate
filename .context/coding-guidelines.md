# PillMate Coding Guidelines

## General Rules

- Source Code ต้องอ่านง่าย
- หลีกเลี่ยง Code Duplication
- เขียนโค้ดให้เข้าใจง่ายที่สุด
- ใช้ SOLID Principle

---

# Language Rules

Comment

✅ ภาษาไทย

Class

✅ ภาษาอังกฤษ

Method

✅ ภาษาอังกฤษ

Variable

✅ ภาษาอังกฤษ

File Name

✅ snake_case

ตัวอย่าง

```text
medication_repository.dart
```

---

# Naming Convention

## Class

```dart
MedicationRepository
```

---

## Variable

```dart
medicationName
```

---

## Constant

```dart
maxReminderCount
```

---

## Enum

```dart
MedicationStatus
```

---

# Widget Rules

แยก Widget ย่อยเมื่อ

- เกิน 100 lines
- ใช้งานซ้ำ

ตัวอย่าง

```dart
MedicationCard
ReminderCard
```

---

# Screen Rules

1 Screen = 1 File

ตัวอย่าง

```text
home_screen.dart
```

---

# State Management Rules

ใช้ Riverpod

อนุญาต

```dart
Provider
FutureProvider
AsyncNotifier
```

ไม่อนุญาต

```dart
setState()
```

ยกเว้น local UI state ภายในหน้าจอเดียวที่ไม่กระทบ business logic เช่น สถานะปุ่มกำลังบันทึก
หรือค่าที่ผู้ใช้กำลังกรอกในฟอร์ม กรณีนี้ใช้ `ConsumerStatefulWidget` ได้

ตัวอย่างที่ใช้จริง

```text
today_doses_screen.dart      // เก็บ set ของมื้อที่กำลังบันทึก กันกดปุ่มซ้ำ
medication_history_screen.dart  // เก็บค่าตัวกรองและคำค้นหา
```

ห้ามใช้ `setState()` เก็บข้อมูลที่มาจาก Repository — ข้อมูลจาก Repository ต้องผ่าน provider เสมอ

---

# Repository Pattern

อนุญาต

```text
UI
 ↓
UseCase
 ↓
Repository
 ↓
Data Source
```

ไม่อนุญาต

```text
UI
 ↓
Hive
```

---

# Error Handling

ใช้ Result Pattern

ตัวอย่าง

```dart
Result<T>
```

ห้าม

```dart
throw Exception();
```

จาก Repository ไป UI

---

# Logging

Development

```dart
debugPrint()
```

Production

ใช้ Logging Service

ห้าม

```dart
print()
```

---

# Documentation

ทุก Public Method ต้องมี Comment

ตัวอย่าง

```dart
/// เพิ่มข้อมูลยาใหม่
Future<void> createMedication()
```

---

# Testing

ทุก UseCase ต้องมี Unit Test

ทุก Repository ต้องมี Unit Test

Target

```text
80%+
```

Mock ด้วย `mocktail` และวาง test ไว้ในโครงสร้างเดียวกับ `lib/`

```text
lib/features/medication/domain/usecases/create_medication_usecase.dart
test/features/medication/domain/usecases/create_medication_usecase_test.dart
```

ชื่อ test เขียนเป็นภาษาไทยให้อ่านเป็นประโยคได้

```dart
test('คืนค่า failure เมื่อ repository บันทึกไม่สำเร็จ', () async { ... });
```

คำสั่ง

```bash
flutter test
```

```bash
flutter test --coverage
```

---

# Lint

ใช้ `flutter_lints` ผ่าน `analysis_options.yaml`

ก่อนเปิด Pull Request ต้องรัน

```bash
flutter analyze
```

เกณฑ์ผ่าน

```text
ไม่มี error และไม่มี warning
```

หนี้ lint ที่ค้างอยู่ตอนนี้: `prefer_initializing_formals` ระดับ info จำนวน 26 รายการ
ใน constructor ของ UseCase / Repository / DataSource (ดู TASK-801)

---

# Git Convention

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
refactor:
test:
docs:
chore:
```

ตัวอย่าง

```text
feat: add medication schedule
fix: resolve reminder issue
```

---

# Pull Request Rules

ต้องมี

- Summary
- Scope
- Testing Result

---

# Performance Rules

หลีกเลี่ยง

```dart
ListView ใน SingleChildScrollView
```

ใช้

```dart
ListView.builder()
```

---

# Security Rules

ห้ามเก็บ

- Password
- Secret Key
- Token

ภายใน Source Code

ให้ใช้

```text
.env
```

หรือ Secure Storage

หมายเหตุ: ปัจจุบันแอปทำงานแบบ local-only ไม่มีการเรียก API ภายนอกและไม่มี secret ในโปรเจกต์
กฎข้อนี้มีไว้รองรับตอนเพิ่ม Cloud Sync ในอนาคต