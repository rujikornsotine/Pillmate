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

ยกเว้น Widget ภายในเท่านั้น

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